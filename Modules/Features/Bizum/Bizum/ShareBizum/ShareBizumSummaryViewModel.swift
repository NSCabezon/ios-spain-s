//
//  ShareBizumSummaryViewModel.swift
//  Bizum
//
//  Created by Laura González on 10/12/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class ShareBizumSummaryViewModel {
    
    private let bizumOperativeType: BizumOperativeType?
    private let bizumAmount: AmountEntity?
    private let bizumConcept: String?
    private var userName: String? = ""
    private let simpleMultipleType: BizumSimpleMultipleType?
    private let bizumContacts: [BizumContactEntity]?
    private let sentDate: Date?
    private let dependenciesResolver: DependenciesResolver?
    
    init(bizumOperativeType: BizumOperativeType?,
         bizumAmount: AmountEntity?,
         bizumConcept: String?,
         simpleMultipleType: BizumSimpleMultipleType?,
         bizumContacts: [BizumContactEntity]?,
         sentDate: Date?,
         dependenciesResolver: DependenciesResolver?) {
        self.bizumOperativeType = bizumOperativeType
        self.bizumAmount = bizumAmount
        self.bizumConcept = bizumConcept
        self.simpleMultipleType = simpleMultipleType
        self.bizumContacts = bizumContacts
        self.sentDate = sentDate
        self.dependenciesResolver = dependenciesResolver
    }
    
    var transferTitle: LocalizedStylableText? {
        let placeholder = [StringPlaceholder(.name, self.userName?.camelCasedString ?? "")]
        switch bizumOperativeType {
        case .sendMoney:
            return localized("bizum_label_shareWith", placeholder)
        case .requestMoney:
            return localized("bizum_label_shareRequestWith", placeholder)
        case .donation:
            return localized("bizum_label_shareDonation", placeholder)
        case .none:
            return localized("bizum_label_shareWith", placeholder)
        }
    }
    
    var sentDateTitle: String {
        switch bizumOperativeType {
        case .sendMoney:
            return "bizumDetail_label_sentDate"
        case .requestMoney:
            return "bizumDetail_label_applicationDate"
        case .donation:
            return "bizumDetail_label_sentDate"
        case .none:
            return ""
        }
    }
    
    var amountText: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 28.8)
        guard let amount = bizumAmount else { return nil }
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16.2)
        return decorator.getFormatedCurrency()
    }
    
    var concept: String {
        guard let conceptText = bizumConcept, conceptText != "" else {
            return localized("bizum_label_notConcept").text
        }
        return conceptText
    }
    
    var type: BizumSimpleMultipleType? {
        return self.simpleMultipleType
    }
    
    var contacts: [BizumContactEntity]? {
        return self.bizumContacts
    }

    func setUserName(_ userName: String?) {
        self.userName = userName
    }
    
    var sentDateFormatted: String? {
        guard let dependenciesResolver = self.dependenciesResolver,
              let sentDate = self.sentDate else {
            return nil
        }
        let dateString = dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: sentDate,
                                       outputFormat: .dd_MMM_yyyy_hyphen_HHmm_h)?
            .lowercased() ?? ""
        return dateString
    }
}
