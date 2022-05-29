//
//  TextBuilder.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 22/07/2019.
//

import UIKit
import CoreFoundationLib

private enum TimelinePlaceholder: String {
    case amount = "{{AMOUNT}}"
    case transactionDescription = "{{TRANSACTIONDESCRIPTION}}"
    case transactionIssueDate = "{{TRANSACTIONISSUEDATE}}"
    case remainingDays = "{{REMAININGDAYS}}"
    case merchantName = "{{MERCHANTNAME}}"
    case productType = "{{PRODUCTTYPE}}"
    case productAlias = "{{PRODUCTALIAS}}"
    case categoryName = "{{CATEGORYNAME}}"
    case productDisplayNumber = "{{PRODUCTDISPLAYNUMBER}}"
    case calculation = "{{CALCULATION}}"
    case iban = "{{IBAN}}"
}

class TextBuilder {
    
    private let locale: Locale
    private let event: TimeLineEvent
    private let value = NSMutableString(string: "")
    private let baseDate: Date
    private let productType: String?
    private let calculationUnit: String?
    private var isPastEvent: Bool {
        return baseDate.days(to: event.date) < 0
    }
    private let isDetail: Bool
    private let emptyString = ""
    
    init(event: TimeLineEvent, productType: String?, calculationUnit: String?, baseDate: Date, locale: Locale, isDetail: Bool) {
        self.event = event
        self.productType = productType
        self.calculationUnit = calculationUnit
        self.baseDate = baseDate
        self.locale = locale
        self.isDetail = isDetail
    }
    
    func add<T>(for keyPath: KeyPath<TimeLineEvent, T?>, value: String?, notValue: String? = nil) {
        guard self.event[keyPath: keyPath] != nil else {
            guard let notValue = notValue else { return }
            append(notValue)
            return
        }
        guard let value = value else { return }
        append(value)
    }
    
    func addText(_ text: String?) {
        guard let string = text else { return }
        append(string)
    }
    
    func build() -> LocalizedStylableText {
        
        
        return applyStyles(to: value as String, [StringPlaceholder(TimelinePlaceholder.amount.rawValue, amount()),
                                                   StringPlaceholder(TimelinePlaceholder.transactionDescription.rawValue, transactionDescription()),
                                                   StringPlaceholder(TimelinePlaceholder.transactionIssueDate.rawValue, transactionIssueDate()),
                                                   StringPlaceholder(TimelinePlaceholder.remainingDays.rawValue, remainingDays()),
                                                   StringPlaceholder(TimelinePlaceholder.merchantName.rawValue, merchantName()),
                                                   StringPlaceholder(TimelinePlaceholder.productType.rawValue, productTypeValue()),
                                                   StringPlaceholder(TimelinePlaceholder.productAlias.rawValue, productAlias()),
                                                   StringPlaceholder(TimelinePlaceholder.categoryName.rawValue, categoryName()),
                                                   StringPlaceholder(TimelinePlaceholder.productDisplayNumber.rawValue, productDisplayNumber()),
                                                   StringPlaceholder(TimelinePlaceholder.iban.rawValue, iban()),
                                                   StringPlaceholder(TimelinePlaceholder.calculation.rawValue, calculation())])
    }
    
    func remainingDaysInt() -> Int? {
        guard let issueDate = event.transaction.issueDate else { return nil }
        let remainingDays = baseDate.days(to: issueDate) < 0 ? 1 : baseDate.days(to: issueDate)
        return remainingDays
    }
}

extension TextBuilder {
    
    func append(_ text: String) {
        let string = "\(text) "
        value.append(string)
    }
    
    func amount() -> String {
        
        if isDetail {
            return emptyString
        }
        
        guard let amount = event.amount else { return emptyString }
        
        return String(amount, locale: locale, isPast: isPastEvent, showAsterisk: isDetail)
    }
    
    func transactionDescription() -> String {
        return event.transaction.description ?? emptyString
    }
    
    func transactionIssueDate() -> String {
        return event.transaction.issueDate?.string(format: .yyyyMMdd) ?? emptyString
    }
    
    func remainingDays() -> String {
        guard let issueDate = event.transaction.issueDate else { return emptyString }
        let remainingDays = baseDate.days(to: issueDate) < 0 ? 1 : baseDate.days(to: issueDate)
        return String(remainingDays == 0 ? remainingDays + 1 : remainingDays)
    }
    
    func merchantName() -> String {
        return event.merchant?.name ?? emptyString
    }
    
    func productTypeValue() -> String {
        return productType ?? emptyString
    }
    
    func productAlias() -> String {
        return event.product?.alias ?? emptyString
    }
    
    func categoryName() -> String {
        return event.category?.name ?? emptyString
    }
    
    func productDisplayNumber() -> String {
        return event.product?.displayNumber ?? emptyString
    }
    
    func iban() -> String {
        guard let text = event.iban else { return emptyString }
        let shortIban = "*" + text.suffix(4)
        return shortIban
    }
    
    func calculation() -> String {
        let calculation: String?
        if let calculationUnit = calculationUnit, let value = event.calculation?.value {
            calculation = String(value) + " " + calculationUnit
        } else {
            calculation = nil
        }
        
        return calculation ?? emptyString
    }
}
