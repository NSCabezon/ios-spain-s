//
//  MockCard.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreDomain
import UnitTestCommons

struct MockCard: CardRepresentable {
    var isContractInactive: Bool = false
    var isBeneficiary: Bool = false
    var boxType: UserPrefBoxType = .card
    @Stub var ownershipType: String?
    @Stub var detailUI: String?
    @Stub var isVisible: Bool
    @Stub var productIdRepresentable: String
    @Stub var trackId: String
    @Stub var currencyRepresentable: CurrencyRepresentable?
    @Stub var productSubtypeRepresentable: ProductSubtypeRepresentable?
    @Stub var contractRepresentable: ContractRepresentable?
    @Stub var visualCode: String?
    @Stub var stampedName: String?
    @Stub var description: String?
    @Stub var creditLimitAmountRepresentable: AmountRepresentable?
    @Stub var currentBalanceRepresentable: AmountRepresentable?
    @Stub var availableAmountRepresentable: AmountRepresentable?
    @Stub var dailyATMMaximumLimitAmountRepresentable: AmountRepresentable?
    @Stub var dailyCurrentLimitAmountRepresentable: AmountRepresentable?
    @Stub var alias: String?
    @Stub var productIdentifier: String?
    @Stub var inactive: Bool?
    @Stub var isCreditCard: Bool
    @Stub var isPrepaidCard: Bool
    @Stub var isDebitCard: Bool
    @Stub var isContractBlocked: Bool
    @Stub var pan: String?
    @Stub var expirationDate: String?
    @Stub var baseUrl: String?
    @Stub var isContractCancelled: Bool
    @Stub var isContractHolder: Bool
    @Stub var isContractActive: Bool
    @Stub var allowsDirectMoney: Bool?
    @Stub var isOwnerSuperSpeed: Bool
    @Stub var ownershipTypeDesc: OwnershipTypeDesc?
    @Stub var ownshipType: String?
    @Stub var PAN: String?
    @Stub var cardTypeDescription: String?
    @Stub var cardContractStatusType: CardContractStatusType?
    @Stub var statusDescription: String?
    @Stub var eCashInd: Bool
    @Stub var contractDescription: String?
    @Stub var indVisibleAlias: Bool?
    @Stub var situation: CardContractStatusType?
    @Stub var cardType: String?
    @Stub var formattedPAN: String?
    @Stub var temporallyOff: Bool
    @Stub var isTemporallyOff: Bool?
    @Stub var dailyMaximumLimit: AmountRepresentable?
    @Stub var atmLimitRepresentable: AmountRepresentable?
}
