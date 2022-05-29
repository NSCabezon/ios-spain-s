//
//  CardTransactionConfiguration.swift
//  CoreDomain
//
//  Created by Hernán Villamil on 11/4/22.
//
import CoreFoundation

public protocol CardTransactionViewItemRepresentable {
    var card: CardRepresentable { get }
    var transaction: CardTransactionRepresentable { get }
    var cardDetail: CardDetailRepresentable? { get }
    var transactionDetail: CardTransactionDetailRepresentable? { get }
    var configuration: CardTransactionDetailConfigRepresentable? { get }
    var contract: EasyPayContractTransactionRepresentable? { get }
    var feeData: FeeDataRepresentable? { get set }
    var easyPay: EasyPayRepresentable? { get set }
    var isFractioned: Bool { get set  }
    var showAmountBackground: Bool { get }
    var minEasyPayAmount: Double? { get set }
    var viewConfigurationRepresentable: [CardTransactionDetailViewConfigurationRepresentable] { get set }
    var error: String? { get set }
    var offerRepresentable: OfferRepresentable? { get set }
    var shouldPresentFractionatedButton: Bool? { get set }
}
