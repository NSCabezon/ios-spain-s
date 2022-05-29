//
//  CardBlockSummaryViewModel.swift
//  Cards
//
//  Created by Laura González on 31/05/2021.
//

import Foundation
import Operative
import CoreFoundationLib

final class CardBlockSummaryViewModel {
    private var operativeData: CardBlockOperativeData
    
    init(operativeData: CardBlockOperativeData) {
        self.operativeData = operativeData
    }
    
    private var cardAlias: String {
        guard let cardName = self.operativeData.selectedCard?.alias else { return "" }
        return "\(cardName) |"
    }
    
    private var cardNumber: String {
        guard let number = self.operativeData.selectedCard?.shortContract else { return "" }
        return number
    }
    
    private var cardAmount: String {
        guard let amount = self.operativeData.selectedCard?.currentBalance.getAbsFormattedAmountUI(),
              let isCredit = self.operativeData.selectedCard?.isCreditCard,
              isCredit
        else { return "" }
        return "(\(amount))"
    }
    
    var cardLabel: String {
        return "\(cardAlias) \(cardNumber) \(cardAmount)"
    }
    
    var blockReason: String {
        switch self.operativeData.blockReason?.option {
        case .lost:
            return localized("blockCard_input_loss")
        case .cardDeterioration:
            return localized("blockCard_input_wear")
        case .stolen:
            return localized("blockCard_input_stole")
        case .none:
            return ""
        }
    }
    
    var extraComment: String? {
        guard let comment = self.operativeData.comment, !comment.isEmpty else { return nil }
        return comment
    }
    
    var operationDate: String {
        let date = Date().toString(format: TimeFormat.dd_MMM_yyyy_point_HHmm.rawValue)
        return "\(date)h"
    }
    
    var deliveryAddress: String {
        guard let address = self.operativeData.deliveryAddress?.camelCasedString else {
            return localized("summary_text_registeredAddress")
        }
        return address
    }
}
