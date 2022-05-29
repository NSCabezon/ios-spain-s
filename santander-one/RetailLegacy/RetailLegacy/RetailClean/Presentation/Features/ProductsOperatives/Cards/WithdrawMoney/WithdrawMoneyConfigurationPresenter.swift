import CoreFoundationLib

final class WithdrawMoneyConfigurationPresenter: OperativeStepPresenter<WithdrawMoneyConfigurationViewController, WithdrawMoneyNavigatorProtocol, WithdrawMoneyConfigurationPresenterProtocol> {
    var amountLabelModel: AmountInputViewModel?
    private var toolTipVideoOffer: Offer?
    
    private lazy var card: Card? = {
        return operativeData.productSelected
    }()
    
    private lazy var cardDetail: CardDetail? = {
        return operativeData.cardDetail
    }()
    
    private lazy var amounts: [String]? = {
        return operativeData.amounts
    }()
    
    private var tooltipLocation: PullOfferLocation {
        .CARD_WITHDRAW_MONEY_TOOLTIP_VIDEO
    }
    
    var operativeData: WithdrawalWithCodeOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.CashWithdrawlCode().page
    }
    
    var cardSubtitle: String? {
        guard let card = card else { return nil }
        let panDescription = card.getPANShort()
        return dependencies.stringLoader.getString("pg_label_debitCard", [StringPlaceholder(.value, panDescription)]).text
    }
    
    private enum WithdrawMoneyConfigurationAmount {
        case error(error: String)
        case success(decimal: Decimal)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("tooldbar_title_withdrawCode")
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderCardViewModel(
            title: .plain(text: card?.getAliasUpperCase()),
            subtitle: .plain(text: cardSubtitle),
            rightTitle: nil,
            amount: nil,
            imageURL: card?.buildImageRelativeUrl(true),
            imageLoader: dependencies.imageLoader
        )
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        let sectionInputContent = TableModelViewSection()
        var amountStackModel: OperativeStackViewModel?
        if let amounts = amounts {
            let textAmounts = amounts.map { text in
                return text.amountAndCurrency()
            }
            amountStackModel = OperativeStackViewModel(elements: textAmounts, actionDelegate: self, dependencies: dependencies)
        }
        // Cell title with no text. This enlarges the cell and create a space of the first cell
        let amountLabelModel = AmountInputViewModel(inputIdentifier: "amount", titleText: LocalizedStylableText.empty, placeholderText: dependencies.stringLoader.getString("withdrawCode_hint_whitdrawImport"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(3, 0), style: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16), textAlignment: .left), dependencies: dependencies, titleIdentifier: "mobileRechange_amountTextField_title",textInputIdentifier: "mobileRechange_amountTextField", textInputRightImageIdentifier: "mobileRechange_amountTextField_image")
        amountLabelModel.inputValueDidChange = { [weak self] in
            amountStackModel?.tagSelected = nil
            self?.view.reloadButtonsSection()
        }
        self.amountLabelModel = amountLabelModel
        sectionInputContent.items += [amountLabelModel]
        let sectionButtonsContent = TableModelViewSection()
        if let amountStackModel = amountStackModel {
            sectionButtonsContent.items += [amountStackModel]
        }
        view.sections = [sectionHeader, sectionInputContent, sectionButtonsContent]
        view.setDoneFooter(text: dependencies.stringLoader.getString("generic_button_accept"))
        view.setOperationFooter(text: dependencies.stringLoader.getString("withdrawCode_buttom_seeHistory"))
    }
    
    private func getAmountParser(amount: String?) -> WithdrawMoneyConfigurationAmount {
        guard let text = amount, !text.isEmpty else {
            return .error(error: "mobileRechange_alert_text_enterAmount")
        }
        guard let decimal = Decimal(string: text.replace(".", "").replace(",", ".")) else {
            return .error(error: "generic_alert_text_errorData_numberAmount")
        }
        let number = decimal as NSNumber
        let value = number.floatValue
        guard value > 0 else {
            return .error(error: "generic_alert_text_errorData_amount")
        }
        guard value >= 20 else {
            return .error(error: "withdrawCode_alert_SameHigherValue")
        }
        let integer = number.intValue
        guard Float(integer) - value == 0 && integer % 10 == 0 else {
            return .error(error: "withdrawCode_alert_multipleValue")
        }
        guard value <= 300 else {
            return .error(error: "withdrawCode_alert_SameLowerValue")
        }
        return .success(decimal: decimal)
    }
    
    private func performValidate(decimal: Decimal) {
        guard let card = card else { return }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateWithdrawMoneyWithCodeUseCaseInput(card: card)
        UseCaseWrapper(
            with: useCaseProvider.validateWithdrawMoneyWithCodeUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] (response) in
                guard let strongSelf = self else { return }
                let amount = Amount.createWith(value: decimal)
                strongSelf.operativeData.amount = amount
                strongSelf.container?.saveParameter(parameter: strongSelf.operativeData)
                strongSelf.container?.saveParameter(parameter: response.signature)
                strongSelf.hideLoading(completion: {
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                })
            }, onError: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                })
            }
        )
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsInputContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

extension WithdrawMoneyConfigurationPresenter: OperativeStackButtonDelegate {
    func selectAmount(at index: Int) {
        guard let amounts = amounts,
              amounts.count > index
        else { return }
        let amountSelected = amounts[index]
        amountLabelModel?.dataEntered = amountSelected
        view.reloadSections([1, 2])
    }
}

extension WithdrawMoneyConfigurationPresenter: WithdrawMoneyConfigurationPresenterProtocol {
    func selectOperations() {
        guard let card = card else { return }
        launchWithDrawMoney(card: card, cardDetail: cardDetail, delegate: self)
    }
    
    func selectDone() {
        guard let enteredAmount = viewModelForIdentifier(identifier: "amount"),
              !enteredAmount.isEmpty
        else {
            self.showError(keyDesc: "mobileRechange_alert_text_enterAmount")
            return
        }
        switch getAmountParser(amount: enteredAmount) {
        case .error(let error):
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: error)
        case .success(let decimal):
            performValidate(decimal: decimal)
        }
    }
    
    func loadTooltip() {
        let usecase = dependencies.useCaseProvider.getCandidatesUseCase(
            input: PullOfferCandidatesUseCaseInput(
                locations: [
                    self.tooltipLocation
                ]
            )
        )
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.toolTipVideoOffer = result.candidates[self.tooltipLocation.stringTag]
                let isVideoEnabled = self.toolTipVideoOffer != nil
                self.view.showGeneralTooltipWithVideo(isVideoEnabled)
            }, onError: { [weak self] _ in
                self?.view.showGeneralTooltipWithVideo(false)
            }
        )
    }
    
    func startTooltipVideo() {
        executeOffer(action: toolTipVideoOffer?.action, offerId: toolTipVideoOffer?.id, location: tooltipLocation)
    }
}

extension WithdrawMoneyConfigurationPresenter: WithdrawMoneyHistoricalLauncher {
    var errorHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
    
    var operativesNavigator: OperativesNavigatorProtocol {
        return navigator
    }
}

extension WithdrawMoneyConfigurationPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        self.view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        self.navigator
    }
}

extension WithdrawMoneyConfigurationPresenter: ProductLauncherPresentationDelegate {
    func startLoading() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: view)
    }
    
    func endLoading(completion: (() -> Void)?) {
        hideLoading(completion: completion)
    }
    
    func showAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, showsCloseButton: false, source: view)
    }
    
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
}
