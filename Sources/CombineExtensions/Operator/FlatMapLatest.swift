//
//  FlatMapLatest.swift
//  
//
//  Created by Shunya Yamada on 2021/07/18.
//

import Combine

public extension Publisher {
    func flatMapLatest<T: Publisher>(_ transform: @escaping (Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> {
        return map(transform).switchToLatest()
    }
}
