//
//  Relay.swift
//  
//
//  Created by Shunya Yamada on 2021/07/17.
//

import Combine

public protocol Relay: Publisher where Failure == Never {
    func accept(_ event: Self.Output)
}
