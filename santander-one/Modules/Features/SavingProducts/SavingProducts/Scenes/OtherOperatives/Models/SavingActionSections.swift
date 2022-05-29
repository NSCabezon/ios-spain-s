//
//  SavingActionSection.swift
//  SavingProducts

import CoreFoundationLib
import CoreDomain

extension SavingsActionSection {
    public var title: String? {
        switch self {
        case .settings:
            return localized("productOption_text_moreOperations")
        case .queries:
            return localized("option_title_queries")
        case .offer:
            return localized("option_title_offer")
        }
    }
}
