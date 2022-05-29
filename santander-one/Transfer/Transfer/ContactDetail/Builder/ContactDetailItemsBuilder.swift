//
//  ContactDetailItemsBuilder.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 30/04/2020.
//

import Foundation
import CoreFoundationLib

class ContactDetailItemsBuilder {
    private var viewModels: [ContactDetailItemViewModel] = []
    private let viewModel: ContactDetailViewModel
    
    init(contactDetailViewModel: ContactDetailViewModel) {
        self.viewModel = contactDetailViewModel
    }
    
    func addAccount() -> Self {
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "favoriteRecipients_label_accountNumber",
            itemValue: self.viewModel.formattedAccount,
            baseURL: self.viewModel.bankIconUrl,
            type: .account
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addAlias() -> Self {
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "favoriteRecipients_label_alias",
            itemValue: self.viewModel.alias,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldAliasContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldAlias,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addHolder() -> Self {
        guard !self.viewModel.beneficiary.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "favoriteRecipients_label_holder",
            itemValue: self.viewModel.beneficiary,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldHolderContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldHolder,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addCountry() -> Self {
        guard !self.viewModel.country.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "favoriteRecipients_label_country",
            itemValue: self.viewModel.country,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldCountryContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldCountry,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addCurrency() -> Self {
        guard !self.viewModel.currency.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "favoriteRecipient_label_currency",
            itemValue: self.viewModel.currency,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldCurrencyContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldCurrency,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBeneficiaryAddress() -> Self {
        guard !self.viewModel.beneficiaryAddress.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_beneficiaryAddress",
            itemValue: self.viewModel.beneficiaryAddress,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBeneficiaryAddressContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBeneficiaryAddress,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBeneficiaryTown() -> Self {
        guard !self.viewModel.beneficiaryTown.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_beneficiaryTown",
            itemValue: self.viewModel.beneficiaryTown,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBeneficiaryTownContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBeneficiaryTown,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBeneficiaryCountry() -> Self {
        guard let countryNameBeneficiary = self.viewModel.noSepaContact?.payee?.countryName, !countryNameBeneficiary.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_countryBeneficiary",
            itemValue: countryNameBeneficiary,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBeneficiaryCountryContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBeneficiaryCountry,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addDestinationCountry() -> Self {
        guard !self.viewModel.destinationCountry.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_destinationCountryToPayement",
            itemValue: self.viewModel.destinationCountry,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldDestinationCountryContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldDestinationCountry,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBicSwift() -> Self {
        guard !self.viewModel.bicSwift.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_bicSwift",
            itemValue: self.viewModel.bicSwift,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBicSwiftContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBicSwift,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBankName() -> Self {
        guard !self.viewModel.bankName.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_nameBank",
            itemValue: self.viewModel.bankName,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBankNameContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBankName,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBankAddress() -> Self {
        guard !self.viewModel.bankTown.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_bankAddress",
            itemValue: self.viewModel.bankAddress,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBankAddressContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBankAddress,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBankTown() -> Self {
        guard !self.viewModel.bankTown.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_bankTown",
            itemValue: self.viewModel.bankTown,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBankTownContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBankTown,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func addBankCountry() -> Self {
        guard !self.viewModel.bankCountry.isEmpty else { return self }
        let viewModel = ContactDetailItemViewModel(
            itemTitleKey: "deliveryDetails_label_bankCountry",
            itemValue: self.viewModel.bankCountry,
            accessibilityIdentifier: AccessibilityContactDetail.genericFieldBankCountryContainer,
            accessibilityIdentifierItemValue: AccessibilityContactDetail.genericFieldBankCountry,
            type: .detail
        )
        self.viewModels.append(viewModel)
        return self
    }
    
    func build() -> [ContactDetailItemViewModel] {
        return self.viewModels
    }
}
