//
//  FlatMapLatestTests.swift
//  
//
//  Created by Shunya Yamada on 2021/08/15.
//

import Combine
import EntwineTest
import XCTest

@testable import CombineExtensions

final class FlatMapLatestTests: XCTestCase {
    
    /// `flatMapLatest` で合成する前のストリームが破棄されていることを確認する.
    func testFlatMapLatest() {
        var subscriptions = 0
        var cancellations = 0
        var cancellables = Set<AnyCancellable>()
        let source = PassthroughSubject<Void, Never>()
        
        // `flatMap` の場合は以前のストリームが破棄されず、どんどん一つのストリームにマージされていく.
        source.flatMapLatest { _ -> AnyPublisher<String, Never> in
            return Timer.publish(every: 0.5, on: RunLoop.main, in: .default)
                .map { "\($0)" }
                .handleEvents(receiveSubscription: { _ in subscriptions += 1 },
                              receiveCancel: { cancellations += 1 })
                .eraseToAnyPublisher()
        }
        .sink(receiveValue: { _ in })
        .store(in: &cancellables)
        
        source.send(())
        source.send(())
        source.send(())
        
        XCTAssertEqual(subscriptions, 3)
        XCTAssertEqual(cancellations, 2)
    }
}
