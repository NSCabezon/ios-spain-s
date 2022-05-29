//
//  CardTransactionFilterOutsider.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

protocol CardTransactionFilterOutsider {
    func send(_ element: CardTransactionFiltersRepresentable)
}

final class DefaultCardTransactionFilterOutsider: CardTransactionFilterOutsider {
    private let subject = PassthroughSubject<CardTransactionFiltersRepresentable, Never>()
    public var publisher: AnyPublisher<CardTransactionFiltersRepresentable, Never>
    
    init() {
        publisher = subject.eraseToAnyPublisher()
    }
    
    public func send(_ element: CardTransactionFiltersRepresentable) {
        subject.send(element)
    }
}
