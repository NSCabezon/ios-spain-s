//
//  CardTransactionDetailViewRepresentable.swift
//  Pods
//
//  Created by Hernán Villamil on 21/4/22.
//

import Foundation

public enum CardTransactionDetailViewType {
    case operationDate
    case annotationDate
    case liquidation
    case fees
}

public protocol CardTransactionDetailViewRepresentable {
    var title: String { get }
    var value: NSAttributedString? { get }
    var viewType: CardTransactionDetailViewType { get set }
}
