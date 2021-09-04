//
//  DemandBuffer.swift
//  
//
//  Created by Shunya Yamada on 2021/09/04.
//

import Combine
import Foundation

/// 上流の `Publisher` に繋がっている下流の `Subscriber` の要求をバッファして管理する.
///
/// 流れてきた値やイベントをバッファして、下流の `Subscriber` からの要求に応じて任意の結果を流す.
class DemandBuffer<S: Subscriber> {
    // 排他的処理を行うためのロックを行うクラス.
    // `NSRecursiveLock` は `lock()` 中にさらに `lock()` を呼ぶ場合に発生するデッドロックを回避できる.
    private let lock = NSRecursiveLock()
    private let subscriber: S
    
    // 流れてきたイベントをバッファとして保持.
    private var buffer = [S.Input]()
    // 上流の `Publisher` が `completed` 済みかどうか判別するために保持.
    private var completion: Subscribers.Completion<S.Failure>?
    private var demandState = Demand()
    
    /// 下流の `Subscriber` から新しい `DemandBuffer` を初期化する.
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    /// 上流の値をバッファして、下流の `Subscriber` からの要求が来た時に後で値を流す.
    func buffer(value: S.Input) -> Subscribers.Demand {
        // `precondition()` で前提条件をチェックする、条件にあっていない場合はランタイムエラーにする.
        precondition(completion == nil, "`Completion` 済みの `Publisher` です")
        
        lock.lock()
        defer {
            lock.unlock()
        }
        
        // リクエストされた要求に応じて分岐.
        switch demandState.requested {
        case .unlimited:
            // 下流に流す値の数に制限がない場合はそのまま流す.
            return subscriber.receive(value)
        default:
            // バッファに値を保存して、下流に流す.
            buffer.append(value)
            return flush()
        }
    }
    
    /// 上流の `Completion` のイベントでバッファを完了させる.
    func complete(completion: Subscribers.Completion<S.Failure>) {
        precondition(self.completion == nil, "既に `Completion` のイベントが流れています")
        
        self.completion = completion
        _ = flush()
    }
    
    /// 下流から新しい要求が来たことをバッファに知らせる.
    func demand(_ demand: Subscribers.Demand) -> Subscribers.Demand {
        return flush(adding: demand)
    }
    
    /// 下流からの要求を基に、バッファしたイベントを下流に流す.
    ///
    /// - Parameter newDemand: 新しく要求を流したい場合に指定する、`nil` の場合は特に変更を行わない.
    ///
    /// - Note: 下流からの要求を満たした後に、`completion` のイベントが流れた場合は
    ///         バッファはクリアされて、`completion` のイベントが下流の `Subscriber` に流される.
    private func flush(adding newDemand: Subscribers.Demand? = nil) -> Subscribers.Demand {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if let newDemand = newDemand {
            // 要求の状態を更新する.
            demandState.requested += newDemand
        }
        
        // バッファしたものを流す準備ができていない場合は、すぐにリターンする.
        guard demandState.requested > 0 || newDemand == Subscribers.Demand.none else {
            return .none
        }
        
        // バッファしたものを下流に流して、保持している状態を更新していく.
        while !buffer.isEmpty && demandState.processed < demandState.requested {
            demandState.requested += subscriber.receive(buffer.remove(at: 0))
            demandState.processed += 1
        }
        
        if let completion = completion {
            // `completion` のイベントが送られている場合.
            buffer = []
            demandState = .init()
            self.completion = nil
            subscriber.receive(completion: completion)
            return .none
        }
        
        // 下流に送ったものを割り出して、保持している状態を更新.
        let sentDemand = demandState.requested - demandState.sent
        demandState.sent += sentDemand
        return sentDemand
    }
}

private extension DemandBuffer {
    /// 下流からの要求の状態を表すモデル.
    struct Demand {
        var processed: Subscribers.Demand = .none
        var requested: Subscribers.Demand = .none
        var sent: Subscribers.Demand = .none
    }
}

extension Subscription {
    func requestIfNeeded(_ demand: Subscribers.Demand) {
        guard demand > .none else {
            return
        }
        request(demand)
    }
}
