//
//  RecoverableDecode.swift
//  
//
//  Created by Shunya Yamada on 2021/08/15.
//
//  https://qiita.com/lovee/items/eb7883d5a51e38bae9a5

import Combine

public extension Publishers {
    
    // Operator は基本的に `Publishers` にまとめられているので、独自の Operator を型として定義する.
    // また Operator は `Publisher` なので、`Publisher` に適合する必要がある.
    // この `RecoverableDecode` は必ず上流の `Publisher` からつながる Operator になるので、上流の型を表す `Upstream` が必須になる.
    // Operator 内でデコードも行うので、`.decode()` に渡す Decoder も受け取る.
    
    // `Output` はデコードした型になるので `Decodable` である必要があり、入力値として入ってくる `Decoder.Input` も `Upstream.Output` と同じでないといけない.
    @available(iOS 14.0, *)
    struct RecoverableDecode<Upstream: Publisher, Decoder: TopLevelDecoder, Output: Decodable>: Publisher where Decoder.Input == Upstream.Output {
        public typealias Failure = Upstream.Failure
        
        /// 上流の `Publisher`.
        private let upstream: Upstream
        /// デコードのための `Decoder`.
        private let decoder: Decoder
        /// デコード失敗時に流す値.
        private let defaultValue: Output
        
        public init(upstream: Upstream,
                    decoder: Decoder,
                    defaultValue: Output) {
            self.upstream = upstream
            self.decoder = decoder
            self.defaultValue = defaultValue
        }
        
        // `S` は下流の購読者のこと.
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            upstream
                .flatMap ({ value in
                    return Just(value)
                        .decode(type: Output.self, decoder: decoder)
                        .catch { _ in
                            Just(defaultValue)
                        }
                })
                .subscribe(subscriber)
        }
    }
}

public extension Publisher {
    
    // メソッドチェーン用のメソッド.
    @available(iOS 14.0, *)
    func recoverableDecode<Output: Decodable, Decoder: TopLevelDecoder>(_ output: Output.Type, from decoder: Decoder, onErrorJustReturn defaultValue: Output) -> Publishers.RecoverableDecode<Self, Decoder, Output> where Decoder.Input == Self.Output {
        return Publishers.RecoverableDecode(upstream: self, decoder: decoder, defaultValue: defaultValue)
    }
}
