import Foundation

class NoSepaTransferDestinationDetailPresenter: OperativeStepPresenter<FormViewController, NoSepaNavigatorProtocol, FormPresenterProtocol> {
    private lazy var transferType: NoSepaTransferSeletorType = {
        let parameter: NoSepaTransferOperativeData = containerParameter()
        guard let noSepaPayee = parameter.favouriteSelected?.noSepaPayee, !noSepaPayee.swiftCode.isEmpty else { return NoSepaTransferSeletorType.identifier }
        return NoSepaTransferSeletorType.bicSwift
    }()
    private let indexSectionDate = 6
    private let indexSectionBank = 3
    private var sectionHeader = StackSection()
    private var sectionRecipent = StackSection()
    private var sectionBankSelector = StackSection()
    private lazy var bicSwiftSection: StackSection = {
        let sectionBankIdentifier = StackSection()
        let nameTextItems = getTextItems(inputIdentifier: InputIdentifier.bicSwift.rawValue, keyTitle: "sendMoney_label_bicSwift", placeholderKey: "onePayInternational_hint_bicSwift")
        sectionBankIdentifier.add(items: nameTextItems)
        return sectionBankIdentifier
    }()
    private lazy var bankIdentifierSection: StackSection = {
        let sectionBankIdentifier = StackSection()
        let nameTextItems = getTextItems(inputIdentifier: InputIdentifier.bankName.rawValue, keyTitle: "sendMoney_label_nameBank", placeholderKey: nil)
        sectionBankIdentifier.add(items: nameTextItems)
        let addressTextItems = getTextItems(inputIdentifier: InputIdentifier.bankAddress.rawValue, keyTitle: "sendMoney_label_optionalAddress", placeholderKey: nil, titleStyle: .titleLight)
        sectionBankIdentifier.add(items: addressTextItems)
        let placeTextItems = getTextItems(inputIdentifier: InputIdentifier.bankPlace.rawValue, keyTitle: "sendMoney_label_optionalTown", placeholderKey: nil, titleStyle: .titleLight)
        sectionBankIdentifier.add(items: placeTextItems)
        let countryTextItems = getTextItems(inputIdentifier: InputIdentifier.bankCountry.rawValue, keyTitle: "sendMoney_label_country", placeholderKey: nil, titleStyle: .titleLight)
        sectionBankIdentifier.add(items: countryTextItems)
        return sectionBankIdentifier
    }()
    
    private enum NoSepaTransferSeletorType: CustomStringConvertible, CaseIterable {
        case identifier
        case bicSwift
        
        var description: String {
            switch self {
            case .bicSwift:
                return "sendMoney_label_bicSwift"
            case .identifier:
                return "sendMoney_hint_informationBankRecipient"
            }
        }
        var value: NoSepaTransferTypeLocal {
            switch self {
            case .bicSwift: return .bicSwift
            case .identifier: return .identifier
            }
        }
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.NoSepaTransferDestiny().page
    }
    
    enum InputIdentifier: String {
        case address
        case place
        case country
        case bicSwift
        case bankName
        case bankAddress
        case bankPlace
        case bankCountry
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_sendMoney")
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        infoObtained()
    }
    
    private func infoObtained() {
        let parameter: NoSepaTransferOperativeData = containerParameter()
        let account = parameter.account
        let header = AccountHeaderStackModel(accountAlias: account.getAlias() ?? "", accountIBAN: account.getIban()?.ibanShort() ?? "", accountAmount: account.getAmount()?.getAbsFormattedAmountUI() ?? "")
        sectionHeader.add(item: header)
        
        let addressTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.address.rawValue, keyTitle: "sendMoney_label_recipientsAddress", placeholderKey: nil, titleStyle: .titleLight)
        sectionRecipent.add(items: addressTextFieldModel)
        let placeTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.place.rawValue, keyTitle: "sendMoney_label_recipientsTown", placeholderKey: nil, titleStyle: .titleLight)
        sectionRecipent.add(items: placeTextFieldModel)
        let countryTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.country.rawValue, keyTitle: "sendMoney_label_destinationToCountry", placeholderKey: nil)
        sectionRecipent.add(items: countryTextFieldModel)
        
        let bankSelectorTitleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString("sendMoney_label_bankIdentifier"))
        sectionBankSelector.add(item: bankSelectorTitleHeader)
        let bankSelectorModel = OptionsPickerStackModel(items: NoSepaTransferSeletorType.allCases, selected: transferType, dependencies: dependencies) { [weak self] selected in
            self?.transferType = selected
            self?.updateBankSections()
        }
        sectionBankSelector.add(item: bankSelectorModel)
        
        let sections = [sectionHeader, sectionRecipent, sectionBankSelector, getBankIdentifierSection()]
        view.dataSource.reloadSections(sections: sections)
        
        fillDetail(with: parameter.favouriteSelected?.noSepaPayee)
    }
    
    private func fillDetail(with noSepaPayee: NoSepaPayee?) {
        guard let noSepaPayee = noSepaPayee else { return }
        if !noSepaPayee.swiftCode.isEmpty {
            self.transferType = .bicSwift
            updateBankSections()
            view.dataSource.updateData(identifier: InputIdentifier.bicSwift.rawValue, value: noSepaPayee.swiftCode)
        } else if let bankName: String = noSepaPayee.bankName {
            self.transferType = .identifier
            updateBankSections()
            view.dataSource.updateData(identifier: InputIdentifier.bankName.rawValue, value: bankName)
            view.dataSource.updateData(identifier: InputIdentifier.bankAddress.rawValue, value: noSepaPayee.bankAddress ?? "")
            view.dataSource.updateData(identifier: InputIdentifier.bankPlace.rawValue, value: noSepaPayee.bankTown ?? "")
            view.dataSource.updateData(identifier: InputIdentifier.bankCountry.rawValue, value: noSepaPayee.bankCountryCode ?? "")
        }
        view.dataSource.updateData(identifier: InputIdentifier.address.rawValue, value: noSepaPayee.address ?? "")
        view.dataSource.updateData(identifier: InputIdentifier.place.rawValue, value: noSepaPayee.town ?? "")
        view.dataSource.updateData(identifier: InputIdentifier.country.rawValue, value: noSepaPayee.countryName ?? "")
    }
    
    private func dateEnteredForIdentifier(_ identifier: InputIdentifier) -> String? {
        return view.dataSource.findData(identifier: identifier.rawValue)
    }
    
    private func updateBankSections() {
        let sections = [sectionHeader, sectionRecipent, sectionBankSelector, getBankIdentifierSection()]
        view.dataSource.setSections(sections: sections)
    }
    
    private func getTextItems(inputIdentifier: String, keyTitle: String, placeholderKey: String?, titleStyle: TitleLabelStackStyle = .title) -> [StackItemProtocol] {
        var items: [StackItemProtocol] = []
        let titleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString(keyTitle), titleStyle: titleStyle)
        items.append(titleHeader)
        let placeholder: LocalizedStylableText?
        if let placeholderKey = placeholderKey {
            placeholder = dependencies.stringLoader.getString(placeholderKey)
        } else {
            placeholder = nil
        }
        let textFieldModel = TextFieldStackModel(inputIdentifier: inputIdentifier, placeholder: placeholder, maxLength: 50)
        items.append(textFieldModel)
        return items
    }
    
    private func getBankIdentifierSection() -> StackSection {
        switch transferType {
        case .bicSwift:
            return bicSwiftSection
        case .identifier:
            return bankIdentifierSection
        }
    }
}

// MARK: - FormPresenterProtocol

extension NoSepaTransferDestinationDetailPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let operativeData: NoSepaTransferOperativeData = containerParameter()
        let input = DestinationDetailNoSepaTransferUseCaseInput(
            originAccount: operativeData.account,
            beneficiary: operativeData.beneficiary ?? "",
            countryInfo: operativeData.country,
            beneficiaryAccountValue: operativeData.detailTemporalAccount,
            beneficiaryAccountName: transferType == .identifier ? dateEnteredForIdentifier(.bankName) : nil,
            beneficiaryAccountAddress: transferType == .identifier ? dateEnteredForIdentifier(.bankAddress) : nil,
            beneficiaryAccountLocality: transferType == .identifier ? dateEnteredForIdentifier(.bankPlace) : nil,
            beneficiaryAccountCountry: transferType == .identifier ? dateEnteredForIdentifier(.bankCountry) : nil,
            beneficiaryAccountBicSwift: transferType == .bicSwift ? dateEnteredForIdentifier(.bicSwift)?.uppercased() : nil,
            beneficiaryCountry: dateEnteredForIdentifier(.country),
            beneficiaryAddress: dateEnteredForIdentifier(.address),
            beneficiaryLocality: dateEnteredForIdentifier(.place),
            dateOperation: operativeData.date,
            transferAmount: operativeData.amount,
            expensiveIndicator: operativeData.transferExpenses,
            countryCode: operativeData.country.code,
            concept: operativeData.concept ?? "",
            transferType: transferType.value
        )
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getDestinationDetailNoSepaTransferUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    operativeData.transferType = result.transferType
                    operativeData.beneficiaryAddress = result.beneficiaryAddress
                    operativeData.swiftValidation = result.swiftValidation
                    operativeData.beneficiary = result.beneficiary
                    operativeData.noSepaTransferValidation = result.noSepaTransferValidation
                    strongSelf.container?.saveParameter(parameter: operativeData)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: error?.getErrorDesc())
                }
            }
        )
    }
}

// MARK: - TooltipTextFieldActionDelegate

extension NoSepaTransferDestinationDetailPresenter: TooltipTextFieldActionDelegate {
    func auxiliaryButtonAction(completion: (TooltipTextFieldAuxiliaryAction) -> Void) {
        completion(.toolTip(delegate: view))
    }
}
