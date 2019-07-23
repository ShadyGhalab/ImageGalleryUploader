//
//  Event+Extensions.swift
//  MobileTests
//
//  Created by Shady Mustafa on 18.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
//

import ReactiveSwift

internal extension Signal.Event {
    var isValue: Bool {
        if case .value = self {
            return true
        }
        return false
    }
    
    var isFailed: Bool {
        if case .failed = self {
            return true
        }
        return false
    }
    
    var isInterrupted: Bool {
        if case .interrupted = self {
            return true
        }
        return false
    }
}
