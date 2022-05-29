//
//  ExpenseItem.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 29/04/2020.
//

import Foundation
import CoreFoundationLib

public enum ExpenseType {
    case reducedDebt
    case transferReceived
    case transferEmitted
    case bizumReceived
    case bizumEmitted
    case subscription
    case receipt
    
    func subtitleKeyFor(_ grammar: GrammarNumber) -> String {
        switch self {
        case .transferReceived, .transferEmitted:
            return (grammar == .singular) ? "analysis_label_accounts_one" : "analysis_label_accounts_other"
        case .receipt:
            return (grammar == .singular) ? "analysis_label_issuing_one" : "analysis_label_issuing_other"
        case .reducedDebt:
            return (grammar == .singular) ? "analysis_label_instalments_one" : "analysis_label_instalments_other"
        case .subscription:
            return (grammar == .singular) ? "analysis_label_subscriptions_one" : "analysis_label_subscriptions_other"
        default:
            return ""
        }
    }
    
    func titleKey() -> String {
        switch self {
        case .transferReceived:
            return "analysis_label_receiveTransfer"
        case .transferEmitted:
            return "analysis_label_transfers"
        case .receipt:
            return "analysis_label_receipts"
        case .reducedDebt:
            return "analysis_label_debt"
        case .subscription:
            return "analysis_item_subscriptions"
        case .bizumEmitted:
            return "analysis_label_bizum"
        case .bizumReceived:
            return "analysis_label_receiveBizum"
        }
    }
}

public struct ExpenseItem: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self.expenseType {
        case .bizumReceived, .bizumEmitted:
            return AccessibilityAnalysisArea.areaMovement2.rawValue
        case .receipt:
            return AccessibilityAnalysisArea.areaMovement4.rawValue
        case .reducedDebt:
            return AccessibilityAnalysisArea.areaDebt.rawValue
        case .subscription:
            return AccessibilityAnalysisArea.areaMovement3.rawValue
        case .transferReceived, .transferEmitted:
            return AccessibilityAnalysisArea.areaMovement1.rawValue
        }
    }
    
    var expenseType: ExpenseType
    var count: Int
    var amountString: NSAttributedString
    var issuerCount: Int
    var customSubtitle: String?
    var title: LocalizedStylableText {
        return localized(expenseType.titleKey())
    }
    var subtitle: LocalizedStylableText {
        return getSubtitleFor(expenseType, issuersCount: issuerCount)
    }
    
    func getSubtitleFor(_ expenseType: ExpenseType, issuersCount: Int) -> LocalizedStylableText {
        let numberToString = String(issuersCount)
        if issuersCount > 1 {
            return localized(expenseType.subtitleKeyFor(.plural), [StringPlaceholder(.number, numberToString)])
        } else if issuersCount == 1 {
            return localized(expenseType.subtitleKeyFor(.singular), [StringPlaceholder(.number, numberToString)])
        }
        return LocalizedStylableText.empty
    }
}
