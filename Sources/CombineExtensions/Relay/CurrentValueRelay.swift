//
//  CurrentValueRelay.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import Combine

public final class CurrentValueRelay<Output>: Relay {
    private let subject: CurrentValueSubject<Output, Never>
    
    public var value: Output {
        return subject.value
    }
    
    public init(_ value: Output) {
        self.subject = CurrentValueSubject<Output, Never>(value)
    }
    
    public func accept(_ event: Output) {
        subject.send(event)
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, Output == S.Input {
        subject.subscribe(subscriber)
    }
}
