//
//  PassthroughRelay.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import Combine

public final class PassthroughRelay<Output>: Relay {
    private let subject = PassthroughSubject<Output, Never>()
    
    public init() {}
    
    public func accept(_ event: Output) {
        subject.send(event)
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
}
