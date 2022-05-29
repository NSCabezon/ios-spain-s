import Foundation

class OnePayGenericAmountEntryPresenter: OperativeStepPresenter<FormViewController, OnePayTransferNavigatorProtocol, FormPresenterProtocol> {
    private let conceptMaxLength = DomainConstant.maxLengthTransferConcept
    
    var originAccount: Account? {
        return nil
    }
    
    var recipientTitle: LocalizedStylableText {
        return stringLoader.getString("newSendOnePay_label_recipients")
    }
    
    var recipientName: LocalizedStylableText {
        return .empty
    }
    
    var recipientAccount: LocalizedStylableText {
        return .empty
    }
    
    var recipientCountry: LocalizedStylableText {
        return .empty
    }
    
    var recipientCurrency: LocalizedStylableText {
        return .empty
    }
    
    var viewTitle: LocalizedStylableText {
        return stringLoader.getString("toolbar_title_newSendOnePay")
    }
    
    var buttonTitle: LocalizedStylableText {
        return stringLoader.getString("generic_button_continue")
    }
    
    var shouldDisplayResidentField: Bool {
        return true
    }
    enum InputIdentifier: String {
        case resident
        case amount
        case concept
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.continueButton.set(localizedStylableText: buttonTitle, state: .normal)
        view.styledTitle = viewTitle
        makeSections()
    }
    
    func continueButtonPressed() {
        // This should be overriden
    }
    
    func checkChangedClosure() -> ((_ selected: Bool) -> Void)? {
        return nil
    }
    
    // MARK: - Helpers
    
    private func makeSections() {
        var sections: [StackSection] = []
        if let accountSection = makeAccountSection() {
            sections.append(accountSection)
        }
        sections.append(makeRecipientSection())
        sections.append(makeAmountSection())
        sections.append(makeConceptSection())
         view.dataSource.reloadSections(sections: sections)
    }
    
    private func makeAccountSection() -> StackSection? {
        guard let originAccount = originAccount else {
            return nil
        }
        let accountSection = StackSection()
        let titleItem = TitleLabelStackModel(title: stringLoader.getString("deliveryDetails_label_originAccount"), insets: Insets(left: 14, right: 14, top: 16, bottom: 7))
        titleItem.accessibilityIdentifier = "sendMoney_label_optionalConcept"
        accountSection.add(item: titleItem)
        let accountModel = EmittedDetailAccountStackModel(originAccount)
        accountSection.add(item: accountModel)
        return accountSection
    }
    
    private func makeRecipientSection() -> StackSection {
        let recipientSection = StackSection()
        let titleItem = TitleLabelStackModel(title: recipientTitle, insets: Insets(left: 14, right: 14, top: 16, bottom: 0))
        titleItem.accessibilityIdentifier = "newSendOnePay_label_recipients"
        recipientSection.add(item: titleItem)
        let recipientModel = FavoriteTransferRecipientStackModel(
            title: recipientName,
            subtitle: recipientAccount,
            country: recipientCountry,
            currency: recipientCurrency)
        recipientSection.add(item: recipientModel)
        if shouldDisplayResidentField {
            let check = CheckStackModel(inputIdentifier: InputIdentifier.resident.rawValue, title: stringLoader.getString("sendMoney_label_residentsInSpain"), isSelected: true, showLine: false, insets: Insets(left: 11, right: 10, top: 5, bottom: 8), checkChanged: checkChangedClosure())
            recipientSection.add(item: check)
        }
        return recipientSection
    }
    
    private func makeAmountSection() -> StackSection {
        let amountSection = StackSection()
        let amountModel = AmountInputStackModel(inputIdentifier: InputIdentifier.amount.rawValue, titleText: stringLoader.getString("directMoney_label_amount"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(12, 2))
        amountSection.add(item: amountModel)
        return amountSection
    }
    
    private func makeConceptSection() -> StackSection {
        let conceptSection = StackSection()
        let titleItem = TitleLabelStackModel(title: stringLoader.getString("sendMoney_label_optionalConcept"), insets: Insets(left: 14, right: 14, top: 16, bottom: 2))
        titleItem.accessibilityIdentifier = "sendMoney_label_optionalConcept"
        conceptSection.add(item: titleItem)
        let placeholderString = stringLoader.getString("newSendOnePay_hint_maxCharacters", [StringPlaceholder(.number, "\(conceptMaxLength)")])
        let conceptModel = TextFieldStackModel(inputIdentifier: InputIdentifier.concept.rawValue, placeholder: placeholderString, insets: Insets(left: 10, right: 10, top: 5, bottom: 8), maxLength: conceptMaxLength)
        conceptSection.add(item: conceptModel)
        return conceptSection
    }
    
}

// MARK: - FormPresenterProtocol

extension OnePayGenericAmountEntryPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        continueButtonPressed()
    }
}
