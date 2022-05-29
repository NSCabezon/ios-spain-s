//
//  FundsFilterOutsider.swift
//  Funds
//

import UI
import CoreDomain
import OpenCombine
import CoreFoundationLib

public typealias FundsFilterRepresentable = TransactionFiltersRepresentable & TransactionFiltersDisposal

public protocol FundsFilterOutsider {
    func send(_ filters: FundsFilterRepresentable)
}

struct DefaultFundsFilterOutsider: FundsFilterOutsider {
    private let subject = PassthroughSubject<FundsFilterRepresentable, Never>()
    public var publisher: AnyPublisher<FundsFilterRepresentable, Never>
    
    init() {
        publisher = subject.eraseToAnyPublisher()
    }
    
    public func send(_ filters: FundsFilterRepresentable) {
        subject.send(filters)
    }
}
