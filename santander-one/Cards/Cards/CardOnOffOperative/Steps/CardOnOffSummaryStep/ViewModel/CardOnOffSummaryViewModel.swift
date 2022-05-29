//
//  CardOnOffSummaryViewModel.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import CoreFoundationLib
import Operative

final class CardOnOffSummaryViewModel {
    private var operativeData: CardOnOffOperativeData
    
    init(operativeData: CardOnOffOperativeData) {
        self.operativeData = operativeData
    }
    
    var cardLabel: String {
        return "\(cardAlias) \(cardNumber)"
    }
    
    var operationDate: String {
        let date = Date().toString(format: TimeFormat.dd_MMM_yyyy_point_HHmm.rawValue)
        return "\(date)h"
    }
    
    var summaryDescription: String {
        return operativeData.option == .turnOn ? localized("summary_title_on") : localized("summary_title_offCard")
    }
    
    var summaryExtraInfo: String {
        return operativeData.option == .turnOn ? localized("summary_info_cardOn") : localized("summary_info_offCard")
    }
}

private extension CardOnOffSummaryViewModel {
    var cardAlias: String {
        guard let cardName = self.operativeData.selectedCard?.alias else { return "" }
        return "\(cardName) |"
    }
    
    var cardNumber: String {
        guard let number = self.operativeData.selectedCard?.shortContract else { return "" }
        return number
    }
}
