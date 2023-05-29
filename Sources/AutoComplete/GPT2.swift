//
//  GPT2.swift
//  CoreMLGPT2
//
//  Created by Julien Chaumond on 19/07/2019.
//  Copyright © 2019 Hugging Face. All rights reserved.
//

import Foundation
import CoreML


class GPT2 {
    
    enum DecodingStrategy {
        /// At each time step, we select the most likely next token
        case greedy
        /// Sample only from the top-k most-probable tokens (k is a hyper-parameter).
        case topK(Int)
        /// Sample from the top tokens with a cumulative probability just above a threshold (nucleus/top-p).
        case topP(Double)
    }
    
    /*
     Because of GPT model size is too big, i cannot add model to github
     You should download model on https://github.com/huggingface/swift-coreml-transformers/tree/master/Resources
     Or generate by yourself
     */
    private let model: gpt2_64_12_2
    
    public let tokenizer = GPT2Tokenizer()
    public let seqLen = 64
    private let strategy: DecodingStrategy
    
    init(strategy: DecodingStrategy = .greedy) throws {
        self.strategy = strategy
        model = try gpt2_64_12_2(configuration: .init())
    }
    
    /// Main prediction loop:
    /// Predict next token from array of previous tokens.
    /// - featurization
    /// - model inference
    /// - Decoding according to the model's `strategy`
    func predict(tokens: [Int]) -> Int {
        let maxTokens = (tokens.count > seqLen)
            ? Array(tokens[..<seqLen])
            : tokens
        
        /// Pad input_ids on the right, up to `seqLen`:
        let input_ids = MLMultiArray.from(
            maxTokens + Array(repeating: 0, count: seqLen - maxTokens.count)
        )
        let position_ids = MLMultiArray.from(
            Array(0..<seqLen)
        )
        
        do {
            let output = try model.prediction(input_ids: input_ids, position_ids: position_ids)
            
            let outputLogits = MLMultiArray.slice(
                output.output_logits,
                indexing: [.select(0), .select(maxTokens.count - 1), .slice, .select(0), .select(0)]
            )
            
            switch strategy {
            case .greedy:
                let nextToken = Math.argmax(outputLogits)
                return nextToken.0
            case .topK(let k):
                let logits = MLMultiArray.toDoubleArray(outputLogits)
                let topk = Math.topK(arr: logits, k: k)
                let sampleIndex = Math.sample(indexes: topk.indexes, probs: topk.probs)
                return sampleIndex
            case .topP(_):
                fatalError("topP is not implemented yet")
            }
        } catch let error {
            print(error)
            return 0
        }
    }
    
    
    /// Main generation.
    ///
    /// Will generate next `nTokens`.
    ///
    func generate(text: String) -> String {
        var tokens = tokenizer.encode(text: text)
        let nTokens = tokens.count
        var newTokens: [Int] = []
        for i in 0..<nTokens {
            let (nextToken, time) = Utils.time {
                return predict(tokens: tokens)
            }
            
            tokens.append(nextToken)
            newTokens.append(nextToken)
            print("🦄 <\(time)s>", i, nextToken, tokens.count)
        }
        return tokenizer.decode(tokens: newTokens)
    }
}
