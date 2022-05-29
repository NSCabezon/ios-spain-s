//
//  SendMoneyTransferTypeRadioButtonViewModel.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import CoreFoundationLib

final class SendMoneyTransferTypeRadioButtonViewModel {
    let oneRadioButtonViewModel: OneRadioButtonViewModel
    let feeViewModel: SendMoneyTransferTypeFeeViewModel?
    let commissionsInfoKey: String?
    let accessibilitySuffix: String?
    
    init(oneRadioButtonViewModel: OneRadioButtonViewModel,
         feeViewModel: SendMoneyTransferTypeFeeViewModel? = nil,
         commissionsInfoKey: String? = nil,
         accessibilitySuffix: String? = nil) {
        self.oneRadioButtonViewModel = oneRadioButtonViewModel
        self.feeViewModel = feeViewModel
        self.commissionsInfoKey = commissionsInfoKey
        self.accessibilitySuffix = accessibilitySuffix
    }
}
