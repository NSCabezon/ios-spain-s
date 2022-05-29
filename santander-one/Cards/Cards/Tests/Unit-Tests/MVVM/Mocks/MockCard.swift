//
//  MockCard.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreDomain

struct MockCard: CardRepresentable {
    var isContractInactive: Bool
    var isBeneficiary: Bool
    var ownershipType: String?
    var detailUI: String?
    var isVisible: Bool
    var productIdRepresentable: String
    var trackId: String
    var currencyRepresentable: CurrencyRepresentable?
    var productSubtypeRepresentable: ProductSubtypeRepresentable?
    var contractRepresentable: ContractRepresentable?
    var visualCode: String?
    var stampedName: String?
    var description: String?
    var creditLimitAmountRepresentable: AmountRepresentable?
    var currentBalanceRepresentable: AmountRepresentable?
    var availableAmountRepresentable: AmountRepresentable?
    var dailyATMMaximumLimitAmountRepresentable: AmountRepresentable?
    var dailyCurrentLimitAmountRepresentable: AmountRepresentable?
    var alias: String?
    var productIdentifier: String?
    var inactive: Bool? = false
    var isCreditCard: Bool = false
    var isPrepaidCard: Bool = false
    var isDebitCard: Bool = false
    var isContractBlocked: Bool = false
    var pan: String?
    var expirationDate: String?
    var baseUrl: String?
    var isContractCancelled: Bool
    var isContractHolder: Bool
    var isContractActive: Bool
    var allowsDirectMoney: Bool?
    var isOwnerSuperSpeed: Bool
    var ownershipTypeDesc: OwnershipTypeDesc?
    var ownshipType: String?
    var PAN: String?
    var cardTypeDescription: String?
    var cardContractStatusType: CardContractStatusType?
    var statusDescription: String?
    var eCashInd: Bool
    var contractDescription: String?
    var indVisibleAlias: Bool?
    var situation: CardContractStatusType?
    var cardType: String?
    var formattedPAN: String?
    var boxType: UserPrefBoxType
    var temporallyOff: Bool?
    var isTemporallyOff: Bool?
    var dailyMaximumLimit: AmountRepresentable?
    var atmLimitRepresentable: AmountRepresentable?
    
    
    init() {
        self.productIdRepresentable = ""
        self.isVisible = true
        self.trackId = ""
        self.productIdentifier = ""
        alias = "test card"
        isContractCancelled = false
        isContractHolder = false
        isContractActive = false
        isOwnerSuperSpeed = false
        eCashInd = false
        boxType = .card
        isBeneficiary = true
        isContractInactive = false
    }
    
    init(productIdentifier: String) {
        self.productIdRepresentable = ""
        self.isVisible = true
        self.trackId = ""
        self.productIdentifier = productIdentifier
        isContractCancelled = false
        isContractHolder = false
        isContractActive = false
        isOwnerSuperSpeed = false
        eCashInd = false
        boxType = .card
        isBeneficiary = true
        isContractInactive = false
    }
}
