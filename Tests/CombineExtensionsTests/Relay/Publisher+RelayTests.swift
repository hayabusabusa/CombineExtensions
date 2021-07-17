//
//  Publisher+RelayTests.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import Combine
import EntwineTest
import XCTest

@testable import CombineExtensions

final class PublisherRelayTests: XCTestCase {
    
    func testBindToRelay() {
        var cancelables = Set<AnyCancellable>()
        
        let scheduler = TestScheduler(initialClock: 0)
        let passthroughRelay = PassthroughRelay<Int>()
        let testablePublisher: TestablePublisher<Int, Never> = scheduler.createRelativeTestablePublisher([
            (100, .input(1)),
            (200, .input(2)),
            (300, .input(3))
        ])
        
        testablePublisher.bind(to: passthroughRelay)
            .store(in: &cancelables)
        
        let results = scheduler.start {
            return testablePublisher
        }
        
        let expected: TestSequence<Int, Never> = [
            (200, .subscription),
            (300, .input(1)),
            (400, .input(2)),
            (500, .input(3))
        ]
        XCTAssertEqual(expected, results.recordedOutput)
    }
}
