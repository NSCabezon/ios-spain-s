//
//  MockCard.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreDomain

public struct MockCard: CardRepresentable {
    public var boxType: UserPrefBoxType = .card
    @Stub public var ownershipType: String?
    @Stub public var detailUI: String?
    @Stub public var isVisible: Bool
    @Stub public var productIdRepresentable: String
    @Stub public var trackId: String
    @Stub public var currencyRepresentable: CurrencyRepresentable?
    @Stub public var productSubtypeRepresentable: ProductSubtypeRepresentable?
    @Stub public var contractRepresentable: ContractRepresentable?
    @Stub public var visualCode: String?
    @Stub public var stampedName: String?
    @Stub public var description: String?
    @Stub public var creditLimitAmountRepresentable: AmountRepresentable?
    @Stub public var currentBalanceRepresentable: AmountRepresentable?
    @Stub public var availableAmountRepresentable: AmountRepresentable?
    @Stub public var dailyATMMaximumLimitAmountRepresentable: AmountRepresentable?
    @Stub public var dailyCurrentLimitAmountRepresentable: AmountRepresentable?
    @Stub public var alias: String?
    @Stub public var productIdentifier: String?
    @Stub public var inactive: Bool?
    @Stub public var isCreditCard: Bool
    @Stub public var isPrepaidCard: Bool
    @Stub public var isDebitCard: Bool
    @Stub public var isContractBlocked: Bool
    @Stub public var pan: String?
    @Stub public var expirationDate: String?
    @Stub public var baseUrl: String?
    @Stub public var isContractCancelled: Bool
    @Stub public var isContractHolder: Bool
    @Stub public var isContractActive: Bool
    @Stub public var allowsDirectMoney: Bool?
    @Stub public var isOwnerSuperSpeed: Bool
    @Stub public var ownershipTypeDesc: OwnershipTypeDesc?
    @Stub public var ownshipType: String?
    @Stub public var PAN: String?
    @Stub public var cardTypeDescription: String?
    @Stub public var cardContractStatusType: CardContractStatusType?
    @Stub public var statusDescription: String?
    @Stub public var eCashInd: Bool
    @Stub public var contractDescription: String?
    @Stub public var indVisibleAlias: Bool?
    @Stub public var situation: CardContractStatusType?
    @Stub public var cardType: String?
    @Stub public var formattedPAN: String?
    @Stub public var temporallyOff: Bool
    @Stub public var isTemporallyOff: Bool?
    @Stub public var dailyMaximumLimit: AmountRepresentable?
    @Stub public var atmLimitRepresentable: AmountRepresentable?
    @Stub public var isContractInactive: Bool
    @Stub public var isBeneficiary: Bool
    
    public init() {}
}
