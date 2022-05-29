//
//  EcommerceViewModel.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 17/2/21.
//

import CoreFoundationLib
import UI

public struct EcommerceLastPurchaseInfo: Equatable {
    let code: String
    let remainingTime: Int?
}

public struct EcommerceViewModel {
    let ecommerceData: EcommerceOperationDataEntity?
    let date: Date
    let remainingTime: Int?
    private let maxTime = PushNotificationMaxTime.ecommerce * 60
    
    init(ecommerceData: EcommerceOperationDataEntity, date: Date, remainingTime: Int?) {
        self.ecommerceData = ecommerceData
        self.date = date
        self.remainingTime = remainingTime
    }
    
    var time: EcommerceTimeViewModel? {
        guard let remainingTime = self.remainingTime else { return nil }
        return EcommerceTimeViewModel(totalTime: maxTime,
                                      remainingTime: remainingTime)
    }
    
    var formattedTime: String {
        return dateToString(date: date, outputFormat: .HH_mm_h) ?? ""
    }
    
    var totalAmount: NSAttributedString? {
        guard let ecommerceData = self.ecommerceData else {
            return NSAttributedString()
        }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 36)
        let amount = MoneyDecorator(ecommerceData.amount, font: font, decimalFontSize: 20)
        return amount.formatAsMillions()
    }
    
    var panShort: LocalizedStylableText {
        guard let ecommerceData = self.ecommerceData else {
            return LocalizedStylableText(text: "", styles: [])
        }
        return localized("cardInfo_label_panShort", [StringPlaceholder(.value, ecommerceData.cardNumber)])
    }
    
    var tradeName: String {
        guard let ecommerceData = self.ecommerceData else {
            return ""
        }
        return ecommerceData.commerceName.uppercased()
    }
    
    var identifier: String {
        guard let ecommerceData = self.ecommerceData else {
            return ""
        }
        return totalAmount?.string ?? "" + ecommerceData.cardNumber + ecommerceData.commerceName + date.toString(format: TimeFormat.yyyyMMddHHmmss.rawValue)
    }
}
