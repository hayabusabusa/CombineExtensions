//
//  ViewController.swift
//  Example
//
//  Created by Shunya Yamada on 2021/07/17.
//

import Combine
import CombineExtensions
import UIKit

class ViewController: UIViewController {
    
    private var cancelables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let relay = PassthroughRelay<Int>()
        
        relay.sink { value in
            print(value)
        }
        .store(in: &cancelables)
        
        relay.accept(1)
        relay.accept(2)
    }
}

