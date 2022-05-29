//
//  TimeLineConfiguration.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

class TimeLineConfiguration: Codable {
    
    struct Properties: Codable {
        let showMonthsSelector: Bool //Unused
        let showDetails: Bool
        let showDetailGraph: Bool //Unused
        let previousEventsPages: Int
        let comingEventsPages: Int
    }
    
    typealias TextsByLanguage = [[[String: String]]]
    
    struct Text: Codable {
        let transactionType: String
        let transactionName: [String: String]
        let disclaimer: [String: String]?
        let coming: [String: TextsByLanguage]
        let previous: [String: TextsByLanguage]
        let CTA: [String]?
        let analyticsReference: String?
        var type: TimeLineEvent.TransactionType {
            return TimeLineEvent.TransactionType(rawValue: transactionType) ?? .unknown
        }
    }
    
    let textProductCodes: [String: [String: String]]
   
    let timelineProperties: Properties
    let textTransactions: [Text]
    let groupedMonthsDisclaimer: [String: String]
    let merchantIconBaseUrl: String?
    // let merchantIcons: [String: String]
    var CTAs: [String: CTAStructure] {
        return [:]
    }
    var textCalculationUnitCodes: [String: [String: String]] {
       return [:]
   }
}


// MARK: - Others

public struct CTAStructure: Codable {
    public let name: [String: String]
    let icon: Icon
    public let action: Action
    let analyticsReference: String?
}

public struct Icon: Codable {
    let URL: String
    let svg: String
}

public struct Action: Codable {
    let type: String?
    let destinationURL: String?
    public let delegateReference: String?
    let composedDescription: ComposedDescription?
}

public struct ComposedDescription: Codable {
    let english: [[String: String]]
    let spanish: [[String: String]]
    
    enum CodingKeys: String, CodingKey {
        case english = "en", spanish = "es"
    }
}


extension ComposedDescription {
    func getShareFormat() -> String? {
        let composed = getComposed(with: GeneralString().languageKey)
        
        guard let text = composed[0]["text"],
            let transactionDescription = composed[1]["transactionDescription"]?.replacingOccurrences(of: "%transactionDescription%", with: "%@"),
            let transactionIssueDate = composed[2]["transactionIssueDate"]?.replacingOccurrences(of: "%transactionIssueDate%", with: "%@"),
            let amount = composed[3]["amount"]?.replacingOccurrences(of: "%amount%", with: "%@") else { return nil }
        
        return "\(text)\(transactionDescription)\(transactionIssueDate)\(amount)"
    }
    
    private func getComposed(with language: String) -> [[String: String]] {
        switch language {
        case "es":
            return self.spanish
        default:
            return self.english
        }
    }
}
