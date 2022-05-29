//
//  SendMoneyTransferTypeRadioButtonsContainerViewModel.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

final class SendMoneyTransferTypeRadioButtonsContainerViewModel {
    let selectedIndex: Int
    let viewModels: [SendMoneyTransferTypeRadioButtonViewModel]
    
    init(selectedIndex: Int,
         viewModels: [SendMoneyTransferTypeRadioButtonViewModel]) {
        self.selectedIndex = selectedIndex
        self.viewModels = viewModels
    }
}
