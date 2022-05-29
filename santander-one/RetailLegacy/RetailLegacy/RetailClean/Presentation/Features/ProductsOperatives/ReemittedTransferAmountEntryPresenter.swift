import Foundation

final class ReemittedTransferAmountEntryPresenter: OnePayGenericAmountEntryPresenter {
    
    var isSpanishResident = false
    
    override var screenId: String? {
        return TrackerPagePrivate.ReemittedTransferAmountEntry().page
    }
    
    override var originAccount: Account? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return parameter.productSelected
    }
    
    override var recipientName: LocalizedStylableText {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return .plain(text: parameter.name)
    }
    
    override var recipientAccount: LocalizedStylableText {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return .plain(text: parameter.iban?.formatted)
    }
    
    override var recipientCountry: LocalizedStylableText {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return .plain(text: parameter.country?.name)
    }
    
    override var recipientCurrency: LocalizedStylableText {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return .plain(text: parameter.currency?.name)
    }
    
    override func checkChangedClosure() -> ((_ selected: Bool) -> Void)? {
        return { [weak self] selected in
            self?.isSpanishResident = selected
        }
    }
    
    override func continueButtonPressed() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let currency = parameter.currency, let country = parameter.country, let account = parameter.productSelected else {
            return
        }
        let amount = view.dataSource.findData(identifier: InputIdentifier.amount.rawValue)
        let input = DestinationOnePayTransferUseCaseInput(amount: amount, currencyInfo: currency, countryInfo: country, account: account)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getDestinationOnePayTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                parameter.type = response.type
                self?.container?.saveParameter(parameter: parameter)
                self?.handleDestinationSuccess(response)
            }, onError: { [weak self] error in
                self?.handleDestinationError(error)
            }
        )
    }
    
    override func loadViewData() {
        super.loadViewData()
        self.view.backgroundColorProgressBar = .skyGray
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.setTitle("toolbar_title_newSendOnePay",
                           subtitle: "toolbar_title_moneyTransfers")
    }
    
    // MARK: - Private methods
    
    private func handleDestinationSuccess(_ response: DestinationOnePayTransferUseCaseOkOutput) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type, let country = parameter.country, let originAccount = parameter.productSelected else { return }
        let input = DestinationAccountOnePayTransferUseCaseInput(
            iban: parameter.iban?.ibanString,
            name: parameter.name,
            alias: nil,
            saveFavorites: false,
            isSpanishResident: self.isSpanishResident,
            time: .now,
            favouriteList: [],
            country: country,
            type: type,
            concept: parameter.concept,
            amount: response.amount,
            originAccount: originAccount,
            scheduledTransfer: nil
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getDestinationAccountOnePayTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] getDestinationAccountResponse in
                parameter.amount = response.amount
                self?.container?.saveParameter(parameter: parameter)
                self?.handleDestinationAccountSuccess(getDestinationAccountResponse)
            }, onError: { [weak self] error in
                self?.handleDestinationAccountError(error)
            }
        )
    }
    
    private func handleDestinationAccountSuccess(_ response: DestinationAccountOnePayTransferUseCaseOkOutput) {
        self.hideAllLoadings { [weak self] in
            guard let strongSelf = self else { return }
            let parameter: OnePayTransferOperativeData = strongSelf.containerParameter()
            guard let type = parameter.type else { return }
            parameter.name = response.name
            parameter.iban = response.iban
            parameter.concept = strongSelf.view.dataSource.findData(identifier: InputIdentifier.concept.rawValue)
            parameter.spainResident = strongSelf.isSpanishResident
            parameter.saveToFavorites = response.saveFavorites
            parameter.alias = response.alias
            parameter.time = response.time
            parameter.transferNational = response.transferNational
            if parameter.type != .national {
                parameter.subType = .standard
            }
            strongSelf.container?.saveParameter(parameter: parameter)
            switch type {
            case .national:
                strongSelf.container?.stepFinished(presenter: strongSelf)
            case .sepa, .noSepa:
                Dialog.alert(
                    title: strongSelf.localized(key: "onePayIntSepa_title_collectionsAndPays"),
                    body: strongSelf.localized(key: "onePayIntSepa_label_collectionsAndPays"),
                    withAcceptComponent: DialogButtonComponents(titled: strongSelf.localized(key: "generic_button_accept")) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.container?.stepFinished(presenter: strongSelf)
                    },
                    withCancelComponent: nil,
                    source: strongSelf.view,
                    shouldTriggerHaptic: true
                )
            }
        }
    }
    
    private func handleDestinationError(_ error: DestinationOnePayTransferUseCaseErrorOutput?) {
        self.hideAllLoadings { [weak self] in
            let key: String?
            switch error?.error {
            case .invalid?:
                key = "generic_alert_text_errorData_numberAmount"
            case .empty?:
                key = "sendMoney_alert_amountTransfer"
            case .zero?:
                key = "sendMoney_alert_higherValue"
            case .none:
                key = nil
            }
            self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: key)
        }
    }
    
    private func handleDestinationAccountError(_ error: DestinationAccountOnePayTransferUseCaseErrorOutput?) {
        self.hideAllLoadings { [weak self] in
            guard let strongSelf = self else { return }
            switch error?.error {
            case .ibanInvalid?:
                strongSelf.showError(keyDesc: "onePay_alert_valueIban")
            case .noToName?:
                strongSelf.showError(keyDesc: "onePay_alert_nameRecipients")
            case .noAlias?:
                strongSelf.showError(keyDesc: "onePay_alert_alias")
            case .duplicateAlias(let alias)?:
                let acceptComponents = DialogButtonComponents(titled: strongSelf.localized(key: "generic_button_accept"), does: nil)
                Dialog.alert(title: nil, body: strongSelf.localized(key: "onePay_alert_valueAlias", stringPlaceHolder: [StringPlaceholder(.value, alias)]), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: strongSelf.view, shouldTriggerHaptic: true)
            case .serviceError(let errorDesc)?:
                strongSelf.showError(keyDesc: errorDesc)
            case .none:
                break
            }
        }
    }
}

extension ReemittedTransferAmountEntryPresenter: BackablePresenterProtocol {
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
}
