//
//  AutoComplete.swift
//
//
//  Created by Dongseok Lee on 2023/05/29.
//

public final class AutoComplete {
    
    private let model: GPT2

    public init() throws {
        model = try GPT2(strategy: .greedy)
    }
    
    public func generate(from text: String) -> String {
        return model.generate(text: text)
    }
}
