//
//  SavingDetailElementViewFactory.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 29/4/22.
//

import Foundation
import CoreDomain
import UI
import CoreFoundationLib

class SavingDetailElementViewFactory {
    
    static func createDetailElementView(for savingDetailsInfo: SavingDetailsInfoRepresentable, saving: SavingProductRepresentable) -> SavingDetailElementView {
        
        var iconName: String?
        switch savingDetailsInfo.action {
        case .share: iconName = "icnShareSlimGreen"
        case .edit: iconName = "icnEdit"
        case .none: iconName = nil
        }
        
        var title, value: String
        var titleIdentifier, valueIdentifier: String?
        var iconIdentifier: String?
        switch savingDetailsInfo.type {
        case .number:
            title = localized("savings_label_accountNumber")
            value = saving.identification ?? ""
            titleIdentifier = "savings_label_accountNumber"
            valueIdentifier = "savingsLabelAccountNumber"
            iconIdentifier = "oneIcnShareNumber"
        case .alias:
            title = localized("savings_label_accountAlias")
            value = saving.alias ?? ""
            titleIdentifier = "savings_label_accountAlias"
            valueIdentifier = "savingsLabelAccountAlias"
            iconIdentifier = "icnEdit"
        case .custom(title: let titleParameter, value: let valueParamater, titleIdentifier: let titleIdentifierParameter, valueIdentifier: let valueIdentifierParameter):
            title = titleParameter
            value = valueParamater
            titleIdentifier = titleIdentifierParameter
            valueIdentifier = valueIdentifierParameter
        }
        
        let elementView = SavingDetailElementView(frame: .zero)
        elementView.configure(title: title,
                              value: value,
                              icon: Assets.image(named: iconName ?? ""),
                              titleIdentifier: titleIdentifier ?? "",
                              valueIdentifier: valueIdentifier ?? "",
                              iconIdentifier: iconIdentifier ?? "")
        return elementView
    }
}
