//
//  CardTransactionDetailConfiguration.swift
//  Cards
//
//  Created by Alvaro Royo on 30/9/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol CardTransactionDetailViewConfigurationProtocol {
    var showAmountBackground: Bool { get }
    
    func getShareable(from: CardTransactionEntity) -> String?
    func getConfiguration(from: CardTransactionEntity) -> [CardTransactionDetailViewConfiguration]
}

public struct CardTransactionDetailViewConfiguration {
    public var left: CardTransactionDetailView?
    public var right: CardTransactionDetailView?
    
    public init(left: CardTransactionDetailView?, right: CardTransactionDetailView?) {
        self.left = left
        self.right = right
    }
    
    public init(left: CardTransactionDetailViewRepresentable?, right: CardTransactionDetailViewRepresentable?) {
        if let unwrappedLeft = left {
            self.left = CardTransactionDetailView(title: unwrappedLeft.title,
                                                  value: unwrappedLeft.value)
        }
        if let unwrappedEight = right {
            self.right = CardTransactionDetailView(title: unwrappedEight.title,
                                                   value: unwrappedEight.value)
        }
    }
}

extension CardTransactionDetailViewConfiguration: CardTransactionDetailViewConfigurationRepresentable {
    public var leftRepresentable: CardTransactionDetailViewRepresentable? {
        return left
    }
    
    public var rightRepresentable: CardTransactionDetailViewRepresentable? {
        return right
    }
}

public struct CardTransactionDetailView: CardTransactionDetailViewRepresentable {
    public var title: String
    public var value: NSAttributedString?
    public var viewType: CardTransactionDetailViewType = .fees
    
    public init(title: String, value: NSAttributedString?) {
        self.title = title
        self.value = value
    }
    
    public init(title: String, value: String) {
        self.init(title: title, value: NSAttributedString(string: value))
    }
}

