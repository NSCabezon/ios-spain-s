//
//  Amount.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 01/07/2019.
//

import Foundation

public struct Amount: Codable {
    
    var value: Double {
        Double(stringValue) ?? 0
    }
    let currencyCode: String
    let stringValue: String
    
    init(value: Double, currencyCode: String) {
        self.stringValue = "\(value)"
        self.currencyCode = currencyCode
    }
    
    enum CodingKeys: String, CodingKey {
        case stringValue = "value", currencyCode = "currency"
    }
}

extension NSAttributedString {
    
    convenience init(_ amount: Amount, locale: Locale = Locale(identifier: TimeLine.dependencies.configuration?.language ?? "en"), isPast: Bool = true, showAsterisk: Bool = true, color: UIColor, integerFont: UIFont, fractionFont: UIFont) {
        let str = String(amount, locale: locale, isPast: isPast, showAsterisk: showAsterisk)
        let attributedMessage = NSMutableAttributedString(string: str)
        let strArray = str.components(separatedBy: locale.decimalSeparator ?? ".")

        let allRange = (attributedMessage.string as NSString).range(of: str, options: NSString.CompareOptions.caseInsensitive)
        let intRange = (attributedMessage.string as NSString).range(of: strArray.first ?? "", options: NSString.CompareOptions.caseInsensitive)
        let decimalRange = (attributedMessage.string as NSString).range(of: strArray.last ?? "", options: NSString.CompareOptions.backwards)
        let symbol = TimeLine.dependencies.configuration?.native?.symbol(for: amount.currencyCode) ?? amount.currencyCode
        let currensySymbolRange = (attributedMessage.string as NSString).range(of: symbol, options: NSString.CompareOptions.caseInsensitive)
        
        let intAttributes: [NSAttributedString.Key: Any] = [.font: integerFont]
        let decimalAttributes: [NSAttributedString.Key: Any] = [.font: fractionFont]
        
        attributedMessage.addAttributes(decimalAttributes, range: decimalRange)
        attributedMessage.addAttributes(intAttributes, range: intRange)
        attributedMessage.addAttributes(decimalAttributes, range: currensySymbolRange)
        
        let allAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        attributedMessage.addAttributes(allAttributes, range: allRange)
        
        self.init(attributedString: attributedMessage)
    }
    
}

extension String {
    
    init(_ amount: Amount, locale: Locale = Locale(identifier: TimeLine.dependencies.configuration?.language ?? Locale.current.languageCode ?? "en"), isPast: Bool = true, showAsterisk: Bool) {
        
        
        let newPrice = NSNumber(value: amount.value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.maximumFractionDigits = isPast ? 2 : 0
        formatter.minimumFractionDigits = isPast ? 2 : 0
        if let result = formatter.string(from: newPrice) {
            let amountWithCurrency = result + (TimeLine.dependencies.configuration?.native?.symbol(for: amount.currencyCode) ?? "")
            if showAsterisk == true {
                self.init(amountWithCurrency + (!isPast ? "*" : ""))
            } else {
                self.init(amountWithCurrency)
            }
        } else {
            self.init(amount.value)
        }
    }
}
