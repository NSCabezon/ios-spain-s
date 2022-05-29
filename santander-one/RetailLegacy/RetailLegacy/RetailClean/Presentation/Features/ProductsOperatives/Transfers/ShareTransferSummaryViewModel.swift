//
//  ShareTransferSummaryViewModel.swift
//  RetailClean
//
//  Created by Laura González on 16/11/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import UI

final class ShareTransferSummaryViewModel {
    private let operativeData: OnePayTransferOperativeData
    private let dependencies: PresentationComponent
    
    init(operativeData: OnePayTransferOperativeData, dependencies: PresentationComponent) {
        self.operativeData = operativeData
        self.dependencies = dependencies
    }
    
    var originAccountImage: String {
        guard let url = operativeData.baseUrl else { return "" }
        return url + (operativeData.productSelected?.accountEntity.buildImageRelativeUrl() ?? "")
    }
    
    var destinationAccountImage: String? {
        guard let entityCode = operativeData.iban?.ibanElec.substring(4, 8) else { return nil }
        guard let contryCode = operativeData.iban?.countryCode else { return nil }
        guard let baseUrl = operativeData.baseUrl else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var nameTitle: LocalizedStylableText {
        return localized("share_text_picture", [StringPlaceholder(.name, operativeData.summaryUserName?.camelCasedString ?? "")])
    }
    
    var amountText: NSAttributedString? {
        guard let amountEntity = operativeData.amount?.entity else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32.0)
        let amount = MoneyDecorator(amountEntity, font: font, decimalFontSize: 18.0)
        return amount.getFormatedCurrency()
    }
    
    var conceptText: String? {
        if let transferConcept = operativeData.concept, !transferConcept.isEmpty {
            return transferConcept
        } else {
            switch operativeData.time {
            case .periodic?, .day?:
                return localized("onePay_label_genericProgrammed").text
            case .now?, .none:
                return localized("onePay_label_notConcept").text
            }
        }
    }
    
    var sentDateText: String {
        switch operativeData.time {
        case .periodic(let startDate, _, _, _)?:
            return dependencies.timeManager.toString(date: startDate, outputFormat: .dd_MM_yyyy) ?? ""
        case .day, .now:
            return dependencies.timeManager.toString(date: operativeData.issueDate, outputFormat: .dd_MM_yyyy) ?? ""
        case .none:
            return ""
        }
    }
    
    var destinationAccountText: String {
        return operativeData.iban?.ibanShort(asterisksCount: 1, lastDigitsCount: 4) ?? ""
    }
    
    var originAccountText: String {
        if let accountNumberFotmat = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: AccountNumberFormatterProtocol.self) {
            let originAccountNumber = accountNumberFotmat.accountNumberFormat(operativeData.productSelected?.accountEntity)
            return originAccountNumber

        } else {
            return operativeData.productSelected?.getIban()?.ibanShort(asterisksCount: 1, lastDigitsCount: 4) ?? ""
        }
    }
}
