//
//  LoanFilterOutsider.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/3/21.
//
import UI
import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public typealias LoanFilterRepresentable = TransactionFiltersRepresentable & TransactionFiltersDisposal

public protocol LoanFilterOutsider {
    func send(_ filters: LoanFilterRepresentable)
}

struct DefaultLoanFilterOutsider: LoanFilterOutsider {
    private let subject = PassthroughSubject<LoanFilterRepresentable, Never>()
    public var publisher: AnyPublisher<LoanFilterRepresentable, Never>
    
    init() {
        publisher = subject.eraseToAnyPublisher()
    }
    
    public func send(_ filters: LoanFilterRepresentable) {
        subject.send(filters)
    }
}
