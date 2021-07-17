//
//  Publisher+Relay.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import Combine

public extension Publisher where Self.Failure == Never {
    func bind<T: Relay>(to relay: T) -> AnyCancellable where Self.Output == T.Output {
        sink { event in
            relay.accept(event)
        }
    }
}
