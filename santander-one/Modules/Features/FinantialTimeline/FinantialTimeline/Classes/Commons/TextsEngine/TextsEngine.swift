//
//  TextsEngine.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation
import CoreFoundationLib

class TextsEngine {
    
    private let locale: Locale
    private let baseDate: Date
    private var texts: [TimeLineConfiguration.Text] = []
    private var productCodes: [String: [String: String]] = [:]
    private var calculationUnits: [String: [String: String]] = [:]
    private var languageCode: String {
        let language = self.locale.languageCode
        let code = GeneralString().languageKey
        guard code != "general_language_key" else { return language ?? "es" }
        return language ?? code
    }
    private var generatedTexts: [TimeLineEvent: LocalizedStylableText] = [:]
    private var generatedTextsWithoutAmount: [TimeLineEvent: LocalizedStylableText] = [:]
    private var groupedMonthsDisclaimer: [String: String] = [:]
    private let lock = NSLock()

    init(baseDate: Date, locale: Locale) {
        self.baseDate = baseDate
        self.locale = locale
    }
    
    func setupTexts(_ texts: [TimeLineConfiguration.Text], productCodes: [String: [String: String]], calculationUnits: [String: [String: String]], groupedMonthsDisclaimer: [String: String]) {
        self.texts = texts
        self.productCodes = productCodes
        self.calculationUnits = calculationUnits
        self.groupedMonthsDisclaimer = groupedMonthsDisclaimer
    }
    
    func getAnalyticsName(for event: TimeLineEvent?) -> String {
        guard let thisEvent = event, let texts = texts.first(where: { $0.transactionType == thisEvent.transaction.type.rawValue }) else { return "" }
        return texts.analyticsReference ?? ""
    }
    
    func getTransactionName(for event: TimeLineEvent?) -> String {
        return getTransactionName(for: event, with: languageCode)
    }
    
    func getTransactionName(for event: TimeLineEvent?, with language: String) -> String {
        guard let thisEvent = event, let texts = texts.first(where: { $0.transactionType == thisEvent.transaction.type.rawValue }) else { return "" }
        return texts.transactionName[language] ?? texts.transactionName["en"] ?? ""
    }
    
    func getDetailText(for event: TimeLineEvent) -> LocalizedStylableText {
        guard let text = generatedTextsWithoutAmount[event] else {
            let builtText = getText(for: event, isDetail: true)
            generatedTextsWithoutAmount[event] = builtText
            return builtText
        }
        return text
    }
    
    func getText(for event: TimeLineEvent) -> LocalizedStylableText {
        guard let text = generatedTexts[event] else {
            let builtText = getText(for: event, isDetail: false)
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                self.lock.lock()
                self.generatedTexts[event] = builtText
                self.lock.unlock()
            }
            return builtText
        }
        return text
    }
    
    private func getText(for event: TimeLineEvent, isDetail: Bool) -> LocalizedStylableText {
        guard let texts = texts.first(where: {
            $0.transactionType == event.transaction.transactionTypeString ||
            $0.transactionType == event.transaction.type.rawValue ||
            $0.transactionType == TimeLineEvent.TransactionType.unknown.rawValue
        })
        else {
            return LocalizedStylableText(text: "", styles: nil)
        }
        let languageTexts: [[String: String]]
        if event.date < baseDate {
            languageTexts = texts.previous[languageCode]?.randomElement() ?? texts.previous["en"]?.randomElement() ?? []
        } else {
            languageTexts = texts.coming[languageCode]?.randomElement() ?? texts.coming["en"]?.randomElement() ?? []
        }
        let productType = event.product?.typeString
        let calculationUnit = event.calculation?.unit.flatMap({ calculationUnits[languageCode]?[$0]  })
        let builder = TextBuilder(event: event, productType: productType, calculationUnit: calculationUnit, baseDate: baseDate, locale: locale, isDetail: isDetail)
        for dictionary in languageTexts {
            builder.addText(dictionary["text"])
            builder.add(for: \.transaction.description, value: dictionary["transactionDescription"], notValue: dictionary["!transactionDescription"])
            builder.add(for: \.transaction.issueDate, value: dictionary["transactionIssueDate"], notValue: dictionary["!transactionIssueDate"])
            builder.add(for: \.amount?.value, value: dictionary["amount"], notValue: dictionary["!amount"])
            if let remDays = builder.remainingDaysInt(), remDays > 1 {
                builder.add(for: \.transaction.issueDate, value: dictionary["remainingDays"], notValue: nil)
            } else {
                builder.add(for: \.transaction.issueDate, value: nil, notValue: dictionary["!remainingDays"])
            }
            builder.add(for: \.merchant?.name, value: dictionary["merchantName"], notValue: dictionary["!merchantName"])
            builder.add(for: \.product?.typeString, value: dictionary["productType"], notValue: dictionary["!productType"])
            builder.add(for: \.product?.alias, value: dictionary["productAlias"], notValue: dictionary["!productAlias"])
            builder.add(for: \.product?.displayNumber, value: dictionary["productDisplayNumber"], notValue: dictionary["!productDisplayNumber"])
            builder.add(for: \.category?.name, value: dictionary["categoryName"], notValue: dictionary["!categoryName"])
            builder.add(for: \.iban, value: dictionary["iban"])
            builder.add(for: \.calculation, value: dictionary["calculation"])
        }
        let builtText = builder.build()
        return builtText
    }
    
    func getEventIsPast(for event: TimeLineEvent) -> Bool {
        return baseDate.days(to: event.date) < 0
    }

    func getCalcultaionUnitString(for unit: String) -> String? {
        guard let element = calculationUnits[unit],
        let strUnit = element[GeneralString().languageKey]
        else { return nil }
        
        return strUnit
    }
    
    func getTypeString(for type: String) -> String? {
        guard let element = productCodes[type],
        let strType = element[GeneralString().languageKey]
            else { return nil }
        
        return strType
    }
    
    func getAllTransactionType() -> [String] {
        var transactionTypeList = [String]()
        let language = GeneralString().languageKey
        texts.forEach { (text) in
            guard let name = text.transactionName[language] else { return }
            transactionTypeList.append(name)
        }
        
        return transactionTypeList
    }
    
    func getAllTransactionText() -> [TimeLineConfiguration.Text] {
        return texts
    }
    
    func getDisclaimer(for type: String) -> String? {
        guard let texts = texts.first(where: { $0.transactionType == type }),
        let disclaimers = texts.disclaimer,
        let localizedDisclaimer = disclaimers[GeneralString().languageKey] else { return nil }
        return localizedDisclaimer
    }
    
    func getGroupedMonthsDisclaimer() -> String {
        guard let disclaimer = groupedMonthsDisclaimer[GeneralString().languageKey] else { return TimeLineDetailString().chartDisclaimer }
        return disclaimer
    }
}
