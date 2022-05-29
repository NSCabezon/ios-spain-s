//
//  OneAccountSelectionCardViewModelExtensions.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 01/09/2021.
//

import CoreFoundationLib
import CoreDomain

extension OneAccountSelectionCardItem {
    var formattedAmount: NSAttributedString? {
        guard let amount = self.amountRepresentable else { return nil }        
        let primaryFont = UIFont.typography(fontName: .oneH300Regular)
        let decimalFont = UIFont.typography(fontName: .oneB400Regular)
        let decorator = AmountRepresentableDecorator(amount, currencyStyle: .code, font: primaryFont, decimalFont: decimalFont)
        return decorator.formattedPaddedCurrencyWithoutMillion
    }
    
    var localizedHelperText: String {
        return localized(self.helperText)
    }
}

public extension OneAccountSelectionCardItem.CardStatus {
    func backgroundColor() -> UIColor {
        switch self {
        case .inactive:
            return .white
        case .selected, .favourite:
            return UIColor.turquoise.withAlphaComponent(0.07)
        case .hidden:
            return UIColor.skyGray
        }
    }

    func itemsColor() -> UIColor {
        switch self {
        case .inactive, .hidden:
            return UIColor.lisboaGray
        case .selected, .favourite:
            return UIColor.darkTorquoise
        }
    }
}
