import Foundation
import CoreFoundationLib

class CreateNoSepaUsualTransferInputDataDetailPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {
    
    private var operativeData: CreateNoSepaUsualTransferOperativeData?
    private var transferType: NoSepaTransferSelectorType = .identifier
    private let indexSectionBank = 2
    private var sectionRecipent: StackSection = StackSection()
    private var sectionBankSelector: StackSection = StackSection()
    
    override var screenId: String? {
        return TrackerPagePrivate.CreateNoSepaUsualTransferInputData().page
    }
    
    private enum NoSepaTransferSelectorType: CustomStringConvertible, CaseIterable {
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
    
    //Aquí hay que preguntarse si es sepa o noSepa
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_newFavoriteRecipients")
        view.backgroundColorProgressBar = .uiBackground
        
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        
        let addressTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.address.rawValue, keyTitle: "sendMoney_label_recipientsAddress", placeholderKey: nil, titleStyle: .titleLight, isFirstModel: true)
        sectionRecipent.add(items: addressTextFieldModel)
        let placeTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.place.rawValue, keyTitle: "sendMoney_label_recipientsTown", placeholderKey: nil, titleStyle: .titleLight)
        sectionRecipent.add(items: placeTextFieldModel)
        let countryTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.country.rawValue, keyTitle: "sendMoney_label_destinationToCountry", placeholderKey: nil)
        sectionRecipent.add(items: countryTextFieldModel)
        
        let bankSelectorTitleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString("sendMoney_label_bankIdentifier"))
        bankSelectorTitleHeader.accessibilityIdentifier = AccessibilityUsualTransfer.sendBankIdenfierLabel.rawValue
        sectionBankSelector.add(item: bankSelectorTitleHeader)
        let bankSelectorModel = OptionsPickerStackModel(items: NoSepaTransferSelectorType.allCases, selected: NoSepaTransferSelectorType.identifier, dependencies: dependencies) { [weak self] selected in
            self?.transferType = selected
            self?.generateSections()
        }
        bankSelectorModel.accessibilityIdentifier = NoSepaTransferSelectorType.identifier.description
        sectionBankSelector.add(item: bankSelectorModel)
        
        let sections = [sectionRecipent, sectionBankSelector, getBankIdentifierSection()]        
        view.dataSource.setSections(sections: sections)
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        self.view.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
    }
    
    private func generateSections() {
        let sections = [sectionRecipent, sectionBankSelector, getBankIdentifierSection()]
        view.dataSource.setSections(sections: sections)
    }
    
    private func dateEnteredForIdentifier(_ identifier: InputIdentifier) -> String? {
        return view.dataSource.findData(identifier: identifier.rawValue)
    }
    
    private func getTextItems(inputIdentifier: String, keyTitle: String, placeholderKey: String?, titleStyle: TitleLabelStackStyle = .title, isFirstModel: Bool = false) -> [StackItemProtocol] {
        var items: [StackItemProtocol] = []
        let titleHeader: TitleLabelStackModel
        if isFirstModel {
            titleHeader  = TitleLabelStackModel(title: dependencies.stringLoader.getString(keyTitle), titleStyle: titleStyle, insets: Insets(left: 11, right: 10, top: CreateUsualTransferOperative.Constants.firstCellExtraTopInset, bottom: 6))
        } else {
            titleHeader  = TitleLabelStackModel(title: dependencies.stringLoader.getString(keyTitle), titleStyle: titleStyle)
        }
        items.append(titleHeader)
        let placeholder: LocalizedStylableText?
        if let placeholderKey = placeholderKey {
            placeholder = dependencies.stringLoader.getString(placeholderKey)
        } else {
            placeholder = nil
        }
        let textFieldModel = TextFieldStackModel(inputIdentifier: inputIdentifier, placeholder: placeholder, maxLength: 50)
        textFieldModel.accessibilityIdentifier = keyTitle
        items.append(textFieldModel)
        return items
    }
    
    private func getBankIdentifierSection() -> StackSection {
        let sectionBankIdentifier: StackSection = StackSection()
        switch transferType {
        case .bicSwift:
            let nameTextItems = getTextItems(inputIdentifier: InputIdentifier.bicSwift.rawValue, keyTitle: "sendMoney_label_bicSwift", placeholderKey: "onePayInternational_hint_bicSwift")
            sectionBankIdentifier.add(items: nameTextItems)
        case .identifier:
            let nameTextItems = getTextItems(inputIdentifier: InputIdentifier.bankName.rawValue, keyTitle: "sendMoney_label_nameBank", placeholderKey: nil)
            sectionBankIdentifier.add(items: nameTextItems)
            let addressTextItems = getTextItems(inputIdentifier: InputIdentifier.bankAddress.rawValue, keyTitle: "sendMoney_label_optionalAddress", placeholderKey: nil, titleStyle: .titleLight)
            sectionBankIdentifier.add(items: addressTextItems)
            let placeTextItems = getTextItems(inputIdentifier: InputIdentifier.bankPlace.rawValue, keyTitle: "sendMoney_label_optionalTown", placeholderKey: nil, titleStyle: .titleLight)
            sectionBankIdentifier.add(items: placeTextItems)
            let countryTextItems = getTextItems(inputIdentifier: InputIdentifier.bankCountry.rawValue, keyTitle: "sendMoney_label_country", placeholderKey: nil, titleStyle: .titleLight)
            sectionBankIdentifier.add(items: countryTextItems)
        }
        return sectionBankIdentifier
    }
}

extension CreateNoSepaUsualTransferInputDataDetailPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let operativeData: CreateNoSepaUsualTransferOperativeData = containerParameter()
        guard let country = operativeData.country, let account = operativeData.account, let beneficiaryName = operativeData.beneficiaryName else { return }
        
        let input = ValidateCreateNoSepaUsualTransferInputDetailUseCaseInput(
            accountDescription: account,
            beneficiaryName: beneficiaryName,
            beneficiaryAddress: dateEnteredForIdentifier(.address),
            beneficiaryLocality: dateEnteredForIdentifier(.place),
            beneficiaryCountryName: dateEnteredForIdentifier(.country),
            transferType: transferType.value,
            beneficiaryBicSwift: dateEnteredForIdentifier(.bicSwift),
            beneficiaryBankName: dateEnteredForIdentifier(.bankName),
            beneficiaryBankAddress: dateEnteredForIdentifier(.bankAddress),
            beneficiaryBankLocality: dateEnteredForIdentifier(.bankPlace),
            beneficiaryBankCountry: dateEnteredForIdentifier(.bankCountry),
            countryInfo: country)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getValidateCreateNoSepaUsualTransferInputDetailUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    operativeData.noSepaPayee = result.noSepaPayee
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
