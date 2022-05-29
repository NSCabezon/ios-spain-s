import CoreFoundationLib

class InsertPhoneSignUpCesCardPresenter: OperativeStepPresenter<InsertPhoneSignUpCesCardViewController, VoidNavigator, InsertPhoneSignUpCesCardPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.SignUpCes().page
    }
    private var cardDetail: CardDetail?
    private var card: Card?
    private var operativeConfig: OperativeConfig?
    private var phoneText: String?
    private var cesCard: CesCard?
    
    var cardImage: String? {
        return  card?.buildImageRelativeUrl(true)
    }
    
    var cardNumber: String? {
        return card?.getDetailUI()
    }
    
    var cardUserName: String? {
        return cardDetail?.stampedName
    }
    
    var cardExpiration: String? {
        return dependencies.timeManager.toString(date: cardDetail?.expirationDate, outputFormat: .MMyy)
    }
    
    var cardType: CardType? {
        guard let isDebit = card?.isDebitCard else { return nil }
        guard let isCredit = card?.isCreditCard else { return nil }
        guard let isPrepaid = card?.isPrepaidCard else { return nil }
        
        let cardType: CardType
        switch (isCredit, isDebit, isPrepaid) {
        case (true, false, false):
            cardType = .creditCard
        case (false, true, false):
            cardType = .debitCard
        default:
            cardType = .prepaidCard
        }
        
        return cardType
    }
    
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_ces")
        
        guard let container = container else {
            return
        }
        
        let operativeData: SignUpCesOperativeData = container.provideParameter()

        cardDetail = operativeData.cardDetail
        card = operativeData.productSelected
        operativeConfig = container.provideParameter()
        cesCard = operativeData.cesCard
        
        infoObtained()
    }
    
    private func infoObtained() {
        view.prepareNavigationBar()
        
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_accept"), state: .normal)
        view.continueButton.onTouchAction = { [weak self] _ in
            self?.onContinueButtonClicked()
        }
        
        let sectionFirst = TableModelViewSection()
        let sectionLast = TableModelViewSection()
        
        let headerViewModel = GenericHeaderDetailCardViewModel(userName: .plain(text: cardUserName),
                                                               cardNumber: .plain(text: cardNumber),
                                                               cardExpiration: .plain(text: cardExpiration),
                                                               imageURL: cardImage,
                                                               imageLoader: imageLoader,
                                                               cardType: cardType)
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: DetailCardView.self, dependencies: dependencies)
        
        let titleLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("ces_title_contract"), style: LabelStylist(textColor: .sanRed, font: .latoBold(size: 14), textAlignment: .left), privateComponent: dependencies)
        
        let contract1 = OperativeLabelTableModelView(title: stringLoader.getString("ces_text_contract1"), style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .left), privateComponent: dependencies)

        var contract2 = OperativeLabelTableModelView(title: stringLoader.getString("ces_text_contractText"), style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .left), privateComponent: dependencies)

        if let phoneText = cesCard?.phoneNumber {
            self.phoneText = phoneText
            contract2 = OperativeLabelTableModelView(title: stringLoader.getString("ces_text_contract4", [StringPlaceholder(.phone, phoneText.obfuscateNumberFirstSixDigits())]), style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .left), privateComponent: dependencies)
        }

        let phoneTextField = OperativePhoneTextFieldTableModelView(phone: nil, placeholder: placeholderText, delegate: view, privateComponent: dependencies)
        
        let contractPhoneString = operativeConfig?.cesSupportPhone != "" && operativeConfig?.cesSupportPhone != nil ? stringLoader.getString("ces_text_contract3", [StringPlaceholder(.value, operativeConfig?.cesSupportPhone ?? "")]) : stringLoader.getString("ces_text_contract2")
        
        let contract3 = OperativeLabelTableModelView(title: contractPhoneString, style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .left), privateComponent: dependencies)
        
        sectionFirst.items = [headerCell, titleLabelModel, contract1, contract2, phoneTextField]
        sectionLast.items = [contract3]
        
        view.sections = [sectionFirst, sectionLast]
    }
    
    private func getSection (section: Int) -> TableModelViewSection? {
        guard view.sections.count > section else {
            return nil
        }
        return view.sections[section]
    }
    
    var showNavigationInfo: Bool {
        return true
    }
}

extension InsertPhoneSignUpCesCardPresenter: InsertPhoneSignUpCesCardPresenterProtocol {
    var infoTitle: LocalizedStylableText {
        return stringLoader.getString("toolbar_title_ces")
    }
    
    var toolTipMessage: LocalizedStylableText {
        return stringLoader.getString("ces_tooltip_info")
    }
    
    var placeholderText: LocalizedStylableText {
        return stringLoader.getString("ces_hint_phone")
    }
    
    func willChangeText(text: String?) {
        phoneText = text
    }
    
    func onContinueButtonClicked() {
        guard let container = self.container else {
            return
        }
        
        guard let phoneText = phoneText else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "mobileRechange_alert_text_enterPhone")
            return
        }
        
        let parser = PhoneFormatter()
        let typePhone = parser.checkNationalPhone(phone: phoneText)
        
        switch typePhone {
        case .empty:
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "mobileRechange_alert_text_enterPhone")
        case .incorrect:
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "mobileRechange_alert_text_numberNational")
        case .ok:
            showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
            performSelectTypeUseCase(phoneNumber: phoneText, container: container)
        }
    }
        
    func performSelectTypeUseCase(phoneNumber: String, container: OperativeContainerProtocol) {
        guard let container = self.container as? OperativeContainer else {
            return
        }
        
        UseCaseWrapper(with: useCaseProvider.validateSignUpCesCardUseCase(input: ValidateSignUpCesCardUseCaseInput()), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
                guard let strongSelf = self else { return }
            
                let operativeData: SignUpCesOperativeData = container.provideParameter()
            
                let cesCard = CesCard(phoneNumber: phoneNumber)
                operativeData.cesCard = cesCard
                container.saveParameter(parameter: operativeData)
            
                container.saveParameter(parameter: response.signatureWithToken)
                        
                strongSelf.hideLoading(completion: {
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                })
            }, onError: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                })
        })
    }
}
