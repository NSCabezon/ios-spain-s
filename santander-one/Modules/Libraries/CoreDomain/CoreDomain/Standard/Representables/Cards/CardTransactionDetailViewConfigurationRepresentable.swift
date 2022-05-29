//
//  CardTransactionDetailViewConfigurationRepresentable.swift
//  Pods
//
//  Created by Hernán Villamil on 21/4/22.
//

import Foundation

public protocol CardTransactionDetailViewConfigurationRepresentable {
    var leftRepresentable: CardTransactionDetailViewRepresentable? { get }
    var rightRepresentable: CardTransactionDetailViewRepresentable? { get }
}
