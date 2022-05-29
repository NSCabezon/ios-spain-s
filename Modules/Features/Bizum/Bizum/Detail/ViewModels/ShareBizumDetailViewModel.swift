//
//  ShareBizumDetailViewModel.swift
//  Bizum
//
//  Created by Laura González on 01/12/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class ShareBizumDetailViewModel {
    private let bizumTransfer: BizumTransactionEntity
    private let userName: String?
    
    init(bizumTransfer: BizumTransactionEntity, userName: String?) {
        self.bizumTransfer = bizumTransfer
        self.userName = userName
    }
    
    var bizumType: BizumOperationTypeEntity? {
        return bizumTransfer.type ?? .none
    }
    
    var transferTitle: LocalizedStylableText {
        return bizumTransfer.getTransferTitle(name: self.userName ?? "")
    }
    
    var amountText: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 28.8)
        let amountEntity = AmountEntity(value: Decimal(bizumTransfer.amount))
        return MoneyDecorator(amountEntity, font: font).getFormatedCurrency()
    }
    
    var concept: String {
        guard let conceptText = bizumTransfer.concept else {
            return localized("bizum_label_notConcept").text
        }
        return bizumTransfer.concept ?? ""
    }
    
    var transferDate: String {
        return bizumTransfer.dateWithHour
    }
}
