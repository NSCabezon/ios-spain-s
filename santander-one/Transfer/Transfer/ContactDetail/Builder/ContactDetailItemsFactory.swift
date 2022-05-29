//
//  ContactDetailItemsFactory.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 30/04/2020.
//

import Foundation
import CoreFoundationLib

class ContactDetailItemsFactory {
    
    static func getContactsDetailViewModels(contactDetailViewModel: ContactDetailViewModel) -> [ContactDetailItemViewModel] {
        var viewModels: [ContactDetailItemViewModel] = []
        if contactDetailViewModel.isSepa {
            viewModels = self.getSepaContactViewModels(viewModel: contactDetailViewModel)
        } else {
            viewModels = self.getNoSepaContactViewModels(viewModel: contactDetailViewModel)
        }
        return viewModels
    }
    
    static func getSepaContactViewModels(viewModel: ContactDetailViewModel) -> [ContactDetailItemViewModel] {
        let builder = ContactDetailItemsBuilder(contactDetailViewModel: viewModel)
            .addAlias()
            .addHolder()
            .addAccount()
            .addCountry()
            .addCurrency()
        return builder.build()
    }
    
    static func getNoSepaContactViewModels(viewModel: ContactDetailViewModel) -> [ContactDetailItemViewModel] {
        let builder = ContactDetailItemsBuilder(contactDetailViewModel: viewModel)
            .addAlias()
            .addHolder()
            .addAccount()
            .addBeneficiaryAddress()
            .addBeneficiaryTown()
            .addBeneficiaryCountry()
            .addCountry()
            .addDestinationCountry()
            .addCurrency()
            .addBicSwift()
            .addBankName()
            .addBankAddress()
            .addBankTown()
            .addBankCountry()
        return builder.build()
    }
}
