//
//  TimeLineEvent.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import Foundation

public class TimeLineEvent: Codable, Hashable, Equatable {
    
    struct Activity: Codable {
        let identifier: String
        let date: Date
        let value: Double
        
        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case date = "issueDate", identifier = "id", value
        }
        // swiftlint:enable nesting
    }
    
    struct DeferredDetails: Codable {
        let receiverAccount: String?
        let issueDate: Date?
        let frequency: String?
        let periodicEventId: String?
        let schedulingDate: Date?
        let alertType: String?
        
        func shouldPresentDetails() -> Bool {
            if issueDate != nil, frequency != nil, frequency != "" {
                return true
            }
            return false
        }
    }
    
    struct Merchant: Codable {
        let name: String?
        var logo: String? {
            guard let code = code else { return nil }
            return TimeLine.dependencies.merchantIconEngine.loadIcon(for: code)
        }
        let code: String?
        let mcc: String?
    }
    
    struct Product: Codable {
        let type: String?
        let code: String?
        let displayNumber: String?
        let alias: String?
        
        var typeString: String? {
            guard let thisType = code else { return nil }
            return TimeLine.dependencies.textsEngine.getTypeString(for: thisType)
        }
    }
    
    enum TransactionType: String, Codable {
        case deferredTransfer = "100"
        case periodicTransfer = "101"
        case bill = "102"
        case cardSubscription = "103"
        case mortage = "104"
        case loan = "105"
        case insurance = "106"
        case pensionPlan = "107"
        case cardSettlement = "108"
        case bizum = "109"
        case receivedTransfer = "111"
        case receivedBizum = "112"
        case payroll = "200"
        case newProduct = "300"
        case productRemoved = "301"
        case expiration = "302"
        case maturity = "303"
        case personalEvent = "900"
        case externalEvent = "901"
        case externalEventBegins = "902"
        case externalEventEnds = "903"
        case externalEventExpires = "904"
        case customEvent = "905"
        case masterEvent = "906"
        case unknown = "000"
        case noEvent = "-1"
    }
    
    struct Transaction: Codable {
        var identifier: String {
            (self.issueDate?.description ?? "") + (self.description ?? "") + self.transactionTypeString
        }
        let transactionTypeString: String
        let description: String?
        let issueDate: Date?
        var type: TransactionType {
            return TransactionType(rawValue: transactionTypeString) ?? .unknown
        }
        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case transactionTypeString = "type", issueDate = "date", description
        }
        // swiftlint:enable nesting
        
        func getCTAs() -> [CTAAction]? {
            return TimeLine.dependencies.ctasEngine.getCTAs(for: type.rawValue)
        }
        
        func getDisclaimer() -> String? {
            return TimeLine.dependencies.textsEngine.getDisclaimer(for: type.rawValue)
        }
    }
    
    struct Category: Codable {
        let code: String?
        let name: String?
        let logo: String?
    }
    
    enum PredictionIndicator: String, Codable {
        case prediction = "1"
        case real = "0"
    }
    
    struct Calculation: Codable {
        let value: Int?
        let unit: String?
        
        func getCalcultaionUnitString() -> String? {
            guard let thisunit = unit else { return nil }
            return TimeLine.dependencies.textsEngine.getCalcultaionUnitString(for: thisunit)
        }
    }
    
    let identifier: String
    var date: Date {
        self.transaction.issueDate ?? Date()
    }
    let amount: Amount?
    let merchant: Merchant?
    let product: Product?
    let transaction: Transaction
    let category: Category?
    let calculation: Calculation?
    let deferredDetails: DeferredDetails?
    let CTA: [String]?
    var activity: [Activity]?
    let previousEvent: String?
    let comingEvent: String?
    let iban: String?
    let predictionIndicator: PredictionIndicator?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "movementId", amount, merchant, product, transaction, category, calculation, deferredDetails, CTA, activity, previousEvent, comingEvent, iban, predictionIndicator = "periodicity"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transaction.identifier)
    }
    
    public static func == (lhs: TimeLineEvent, rhs: TimeLineEvent) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(transaction: TimeLineEvent.Transaction) {
        self.transaction = transaction
        self.merchant = nil
        self.product = nil
        self.amount = nil
        self.category = nil
        self.calculation = nil
        self.deferredDetails = nil
        self.CTA = nil
        self.identifier = ""
        self.previousEvent = ""
        self.comingEvent = ""
        self.iban = nil
        self.predictionIndicator = nil
    }
    
    func getPreviousEvent() -> String? {
        return previousEvent?.asEventCode()
    }
    
    func getComingEvent() -> String? {
        return comingEvent?.asEventCode()
    }
}

extension TimeLineEvent {
    
    var logo: String? {
        return merchant?.logo
    }
    
    var type: TimeLineEvent.TransactionType {
        return transaction.type
    }
}

extension TimeLineEvent: DateParseable {
    
    static var formats: [String: String] {
        return [
            "activity.issueDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "date": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "deferredDetails.issueDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "deferredDetails.schedulingDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "transaction.date": "yyyy-MM-dd"
        ]
    }
}
