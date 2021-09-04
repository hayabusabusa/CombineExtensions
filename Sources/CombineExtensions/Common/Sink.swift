//
//  Sink.swift
//  
//
//  Created by Shunya Yamada on 2021/09/04.
//

import Combine

/// 上流の `Publisher` と下流の `Subscriber` からの要求の整合性を取るために
/// 基本となる `DemandBuffer` を利用する `Sink`.
class Sink<Upstream: Publisher, Downstream: Subscriber>: Subscriber {
    typealias TransformOutput = (Upstream.Output) -> Downstream.Input?
    typealias TransformFailure = (Upstream.Failure) -> Downstream.Failure?
    
    private let transformOutput: TransformOutput?
    private let transformFailure: TransformFailure?
    
    private(set) var buffer: DemandBuffer<Downstream>
    // 上流の `Publisher` が作成する `Subscription`.
    private var upstreamSubscription: Subscription?
    
    /// 上流の `Publisher` を購読する新しい `Sink` を初期化して、下流からの要求を `DemandBuffer` を使って満たす.
    ///
    /// - Parameters:
    ///   - upstream: 上流の `Publisher`
    ///   - downstream: 下流の `Subscriber`
    ///   - transformOutput: 上流の `Publisher` の `Output` を下流の `Subscriber` の `Input` に型を変換する.
    ///   - transformFailure: 上流の `Publisher` の `Failure` を下流の `Subscriber` の `Failure` に型を変換する.
    ///
    /// - Note: デフォルトの `Subscribers.Sink` を利用している場合は、上記2つの変換関数を必ず使用する必要がある.
    ///         そうしない場合は `Subscribers.Sink` のサブクラスを作って、独自の `Sink` を作成しなければならない.
    init(upstream: Upstream,
         downstream: Downstream,
         transformOutput: TransformOutput? = nil,
         transformFailure: TransformFailure? = nil) {
        self.buffer = DemandBuffer(subscriber: downstream)
        self.transformOutput = transformOutput
        self.transformFailure = transformFailure
        // 上流の `Subscriber` として自身を登録する.
        upstream.subscribe(self)
    }
    
    deinit {
        cancelUpstream()
    }
    
    func demand(_ demand: Subscribers.Demand) {
        let newDemand = buffer.demand(demand)
        upstreamSubscription?.requestIfNeeded(newDemand)
    }
    
    func receive(subscription: Subscription) {
        // `Subscription` を受けた時に何をするか.
        upstreamSubscription = subscription
    }
    
    func receive(_ input: Upstream.Output) -> Subscribers.Demand {
        // 値を受け取った時に何をするか.
        guard let transform = transformOutput else {
            fatalError("❌ 上流の `Publisher` の `Output` を変換する関数が提供されていません")
        }
        
        guard let transformedInput = transform(input) else {
            return .none
        }
        return buffer.buffer(value: transformedInput)
    }
    
    func receive(completion: Subscribers.Completion<Upstream.Failure>) {
        // `Completion` を受けた時に何をするか.
        switch completion {
        case .finished:
            // バッファも完了させる.
            buffer.complete(completion: .finished)
        case .failure(let error):
            guard let transform = transformFailure else {
                fatalError("❌ 上流の `Publisher` の `Failure` を変換する関数が提供されていません")
            }
            
            guard let transformedError = transform(error) else {
                return
            }
            buffer.complete(completion: .failure(transformedError))
        }
    }
    
    func cancelUpstream() {
        upstreamSubscription?.cancel()
    }
}
