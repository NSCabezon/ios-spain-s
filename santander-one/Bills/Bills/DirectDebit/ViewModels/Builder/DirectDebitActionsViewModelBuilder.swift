//
//  DirectDebitActionsViewModelBuilder.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 03/04/2020.
//

import Foundation
import CoreFoundationLib

final class DirectDebitActionsViewModelBuilder {
    private var viewModels = [DirectDebitActionViewModel]()
    
    func addChangeDirectDebit(_ account: AccountEntity?) -> Self {
        let viewModel = DirectDebitActionViewModel(
            title: localized("receiptsAndTaxes_button_changeDirectDebit"),
            description: localized("receiptsAndTaxes_text_changeDirectDebit"),
            imageName: "icnChangeDomicileReceipt",
            type: .operative)
        self.viewModels.append(viewModel)
        return self
    }
    
    func addPension(with url: String?) -> Self {
        guard let billsHomePensionUrl = url else { return self }
        let viewModel = DirectDebitActionViewModel(
            title: localized("receiptsAndTaxes_button_pension"),
            description: localized("receiptsAndTaxes_text_pension"),
            imageName: "icnContribution",
            type: .externalUrl(billsHomePensionUrl))
        self.viewModels.append(viewModel)
        return self
    }
    
    func addUnemploymentBenefit(with url: String?) -> Self {
        guard let billsHomeUnemploymentBenefitUrl = url else { return self }
        let viewModel = DirectDebitActionViewModel(
            title: localized("receiptsAndTaxes_button_benefit"),
            description: localized("receiptsAndTaxes_text_benefit"),
            imageName: "icnStatement",
            type: .externalUrl(billsHomeUnemploymentBenefitUrl))
        self.viewModels.append(viewModel)
        return self
    }
    
    func build() -> [DirectDebitActionViewModel] {
        return self.viewModels
    }
}
