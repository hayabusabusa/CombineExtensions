//
//  PassthroughRelayTests.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import EntwineTest
import XCTest

@testable import CombineExtensions

final class PassthroughRelayTests: XCTestCase {
    
    func testAcceptNoEvent() {
        let scheduler = TestScheduler(initialClock: 0)
        let passthroughRelay = PassthroughRelay<Int>()
        let testableSubscriber = scheduler.createTestableSubscriber(Int.self, Never.self)
        
        passthroughRelay.subscribe(testableSubscriber)
        
        scheduler.resume()
        
        let expected: TestSequence<Int, Never> = [
            (0, .subscription),
        ]
        XCTAssertEqual(expected, testableSubscriber.recordedOutput)
    }
    
    func testAcceptMultipleEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let passthroughRelay = PassthroughRelay<Int>()
        let testableSubscriber = scheduler.createTestableSubscriber(Int.self, Never.self)
        
        passthroughRelay.subscribe(testableSubscriber)
        
        scheduler.schedule(after: 100) {
            passthroughRelay.accept(1)
        }
        scheduler.schedule(after: 200) {
            passthroughRelay.accept(2)
        }
        
        scheduler.resume()
        
        let expected: TestSequence<Int, Never> = [
            (0, .subscription),
            (100, .input(1)),
            (200, .input(2)),
        ]
        XCTAssertEqual(expected, testableSubscriber.recordedOutput)
    }
}
