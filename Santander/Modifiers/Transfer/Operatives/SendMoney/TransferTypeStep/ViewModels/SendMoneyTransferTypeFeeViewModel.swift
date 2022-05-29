//
//  SendMoneyTransferTypeFeeViewModel.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import CoreFoundationLib
import CoreDomain

final class SendMoneyTransferTypeFeeViewModel {
    private let amount: AmountRepresentable
    let status: OneStatus
    let accessibilitySuffix: String?
    
    init?(amount: AmountRepresentable?,
          status: OneStatus,
          accessibilitySuffix: String? = nil) {
        guard let amount = amount else { return nil }
        self.amount = amount
        self.status = status
        self.accessibilitySuffix = accessibilitySuffix
    }
}

extension SendMoneyTransferTypeFeeViewModel {
    var formattedAmount: NSAttributedString? {
        let primaryFont = UIFont.typography(fontName: .oneH300Regular)
        let decimalFont = UIFont.typography(fontName: .oneB400Regular)
        let decorator = AmountRepresentableDecorator(self.amount,
                                                     font: primaryFont,
                                                     decimalFont: decimalFont)
        return decorator.getFormatedWithCurrencyName()
    }
}
