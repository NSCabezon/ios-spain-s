//
//  CardTransactionConfiguration.swift
//  Pods
//
//  Created by Hernán Villamil on 11/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class CardTransactionViewConfiguration {
    var detail: CardDetailRepresentable 
    var configuration: CardTransactionDetailConfigRepresentable
    var contract: EasyPayContractTransactionRepresentable?
    var feeData: FeeDataRepresentable
    
    init(detail: CardDetailRepresentable,
         configuration: CardTransactionDetailConfigRepresentable,
         contract: EasyPayContractTransactionRepresentable?,
         feeData: FeeDataRepresentable) {
        self.detail = detail
        self.configuration = configuration
        self.contract = contract
        self.feeData = feeData
    }
}

extension CardTransactionViewConfiguration: CardTransactionViewConfigurationRepresentable {}
