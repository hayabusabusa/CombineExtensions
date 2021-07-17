//
//  CurrentValueRelayTests.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import EntwineTest
import XCTest

@testable import CombineExtensions

final class CurrentValueRelayTests: XCTestCase {
    
    func testAcceptNoEvent() {
        let scheduler = TestScheduler(initialClock: 0)
        let currentValueRelay = CurrentValueRelay<Int>(0)
        let testableSubscriber = scheduler.createTestableSubscriber(Int.self, Never.self)
        
        currentValueRelay.subscribe(testableSubscriber)
        
        scheduler.resume()
        
        let expected: TestSequence<Int, Never> = [
            (0, .subscription),
            (0, .input(0)),
        ]
        XCTAssertEqual(expected, testableSubscriber.recordedOutput)
    }
    
    func testValueWhenAcceptNoEvent() {
        let currentValueRelay = CurrentValueRelay<Int>(0)
        
        let expected: Int = 0
        XCTAssertEqual(expected, currentValueRelay.value)
    }
    
    func testAcceptMultipleEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let currentValueRelay = CurrentValueRelay<Int>(0)
        let testableSubscriber = scheduler.createTestableSubscriber(Int.self, Never.self)
        
        currentValueRelay.subscribe(testableSubscriber)
        
        scheduler.schedule(after: 100) {
            currentValueRelay.accept(1)
        }
        scheduler.schedule(after: 200) {
            currentValueRelay.accept(2)
        }
        
        scheduler.resume()
        
        let expected: TestSequence<Int, Never> = [
            (0, .subscription),
            (0, .input(0)),
            (100, .input(1)),
            (200, .input(2)),
        ]
        XCTAssertEqual(expected, testableSubscriber.recordedOutput)
    }
    
    func testValueWhenAcceptMultipleEvents() {
        let currentValueRelay = CurrentValueRelay<Int>(0)
        currentValueRelay.accept(1)
        currentValueRelay.accept(2)
        
        let expected: Int = 2
        XCTAssertEqual(expected, currentValueRelay.value)
    }
}
