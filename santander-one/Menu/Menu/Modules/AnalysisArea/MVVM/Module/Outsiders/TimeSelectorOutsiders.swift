//
//  TimeSelectorOutsiders.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 3/2/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol TimeSelectorOutsider {
    func send(_ timeSelected: TimeSelectorRepresentable)
}

struct DefaultTimeSelectorOutsider: TimeSelectorOutsider {
    private let subject = PassthroughSubject<TimeSelectorRepresentable, Never>()
    public var publisher: AnyPublisher<TimeSelectorRepresentable, Never>
    
    init() {
        publisher = subject.eraseToAnyPublisher()
    }
    
    public func send(_ timeSelected: TimeSelectorRepresentable) {
        subject.send(timeSelected)
    }
}
