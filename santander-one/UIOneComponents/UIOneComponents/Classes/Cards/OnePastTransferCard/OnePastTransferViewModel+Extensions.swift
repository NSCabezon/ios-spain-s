//
//  OnePastTransferViewModel+Extensions.swift
//  UIOneComponents
//
//  Created by Juan Diego Vázquez Moreno on 23/9/21.
//

import CoreFoundationLib

public extension OnePastTransferViewModel {

    var formattedAmount: NSAttributedString? {
        guard let amount = self.transfer.amountRepresentable else { return nil }
        let primaryFont = UIFont.typography(fontName: .oneH100Bold)
        let decimalFont = UIFont.typography(fontName: .oneB200Bold)
        let decorator = AmountRepresentableDecorator(amount, font: primaryFont, decimalFont: decimalFont)
        return decorator.getFormatedCurrency()
    }
}

public extension OnePastTransferViewModel.CardStatus {

    var backgroundColor: UIColor {
        switch self {
        case .inactive, .disabled:
            return .white
        case .selected:
            return UIColor.turquoise.withAlphaComponent(0.07)
        }
    }
}

public extension OnePastTransferViewModel.TransferType {

    var transferTypeIcon: String? {
        switch self {
        case .none:
            return nil
        case .emited:
            return "icnOneSent"
        case .received:
            return "icnOneReceived"
        }
    }
}

public extension OnePastTransferViewModel.TransferScheduleType {

    var localizedScheduleText: String? {
        switch self {
        case .normal:
            return nil
        case .scheduled:
            return localized("transfer_label_scheduled")
        case .periodic:
            return localized("transfer_label_periodic")
        }
    }
}
