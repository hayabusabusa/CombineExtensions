//
//  RecoverableDecodeTests.swift
//  
//
//  Created by Shunya Yamada on 2021/08/15.
//

import Combine
import XCTest

@testable import CombineExtensions

@available(iOS 14.0, *)
final class RecoverableDecodeTests: XCTestCase {
    
    func testRecoverableDecode() {
        let json = """
        {
            "value": "TEST"
        }
        """
        .data(using: .utf8)!
        let invalidJSON = """
        {
            "test": "TEST"
        }
        """
        .data(using: .utf8)!
        
        var cancellables = Set<AnyCancellable>()
        
        XCTContext.runActivity(named: "Emits decodable data") { _ in
            var output: Output?
            
            let expectation = XCTestExpectation(description: "Wait until value received")
            [json].publisher
                .recoverableDecode(Output.self, from: JSONDecoder(), onErrorJustReturn: Output(value: "DEFAULT"))
                .sink(receiveValue: { value in
                    output = value
                    expectation.fulfill()
                })
                .store(in: &cancellables)
            wait(for: [expectation], timeout: 0.5)
            
            XCTAssertEqual(output, Output(value: "TEST"))
        }
        
        XCTContext.runActivity(named: "Emits default value on error") { _ in
            var output: Output?
            
            let expectation = XCTestExpectation(description: "Wait until value received")
            [invalidJSON].publisher
                .recoverableDecode(Output.self, from: JSONDecoder(), onErrorJustReturn: Output(value: "DEFAULT"))
                .sink(receiveValue: { value in
                    output = value
                    expectation.fulfill()
                })
                .store(in: &cancellables)
            wait(for: [expectation], timeout: 0.5)
            
            XCTAssertEqual(output, Output(value: "DEFAULT"))
        }
    }
}

@available(iOS 14.0, *)
private extension RecoverableDecodeTests {
    
    struct Output: Decodable, Equatable {
        let value: String
    }
}
