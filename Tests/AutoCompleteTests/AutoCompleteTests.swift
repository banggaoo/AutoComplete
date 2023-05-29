//
//  AutoComplete.swift
//
//
//  Created by Dongseok Lee on 2023/05/29.
//

import XCTest
@testable import AutoComplete

final class AutoCompleteTests: XCTestCase {
    func testGenerate() throws {
        let autoComplete = try AutoComplete()
        [
            "My wifi is",
            "What's good with",
            "What kind"
        ].forEach {
            let token = autoComplete.generate(from: $0)
            print(token)

            XCTAssertTrue(token.isEmpty == false)
        }
    }
}
