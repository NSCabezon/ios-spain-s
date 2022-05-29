class UsualTransferAmountEntryPresenter: OnePayGenericAmountEntryPresenter {
    override var originAccount: Account? {
        let parameter: UsualTransferOperativeData = containerParameter()
        return parameter.account
    }
    override var recipientTitle: LocalizedStylableText {
        return stringLoader.getString("newSendOnePay_label_favoriteRecipients")
    }
    override var recipientName: LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let beneficiary = parameter.originTransfer.alias else {
            return .empty
        }
        return LocalizedStylableText(text: beneficiary, styles: nil)
    }
    override var recipientAccount: LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let ibanFormatted = parameter.originTransfer.iban?.formatted else {
            return .empty
        }
        return LocalizedStylableText(text: ibanFormatted, styles: nil)
    }
    override var recipientCountry: LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let name = parameter.country?.name else {
            return .empty
        }
        return LocalizedStylableText(text: name, styles: nil)
    }
    override var recipientCurrency: LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let name = parameter.currency?.name else {
            return .empty
        }
        return LocalizedStylableText(text: name.camelCasedString, styles: nil)
    }
    override var shouldDisplayResidentField: Bool {
        return false
    }
    override var screenId: String? {
        return TrackerPagePrivate.UsualTransferAmountEntry().page
    }
    
    private func processOkResponse(response: SelectorUsualTransferUseCaseOkOutput) {
        let parameter: UsualTransferOperativeData = containerParameter()
        parameter.amount = response.amount
        parameter.concept = view.dataSource.findData(identifier: InputIdentifier.concept.rawValue)
        parameter.transferNational = response.transferNational
        if parameter.type != .national {
            parameter.subType = .standard
        }
        container?.saveParameter(parameter: parameter)
        container?.stepFinished(presenter: self)
    }
    
    private func processErrorResponse(error: SelectorUsualTransferUseCaseErrorOutput?) {
        let title: String?
        let key: String?
        switch error?.error {
        case .invalid?:
            title = "generic_alert_title_errorData"
            key = "generic_alert_text_errorData_numberAmount"
        case .empty?:
            title = "generic_alert_title_errorData"
            key = "sendMoney_alert_amountTransfer"
        case .zero?:
            title = "generic_alert_title_errorData"
            key = "sendMoney_alert_higherValue"
        case .service(let error)?:
            title = "generic_alert_title_errorData"
            key = error
        case .none:
            title = nil
            key = nil
        }
        showError(keyTitle: title, keyDesc: key)
    }
    
    override func continueButtonPressed() {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let currency = parameter.currency, let account = parameter.account, let type = parameter.type else {
            return
        }
        let concept = view.dataSource.findData(identifier: InputIdentifier.concept.rawValue)
        let amount = view.dataSource.findData(identifier: InputIdentifier.amount.rawValue)
        let input = SelectorUsualTransferUseCaseInput(amount: amount, currencyInfo: currency, originAccount: account, subtype: .standard, type: type, concept: concept, favourite: parameter.originTransfer)
        let usecase = dependencies.useCaseProvider.getSelectorUsualTransferUseCase(input: input)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            self?.hideAllLoadings { [weak self] in
                self?.processOkResponse(response: response)
            }
            }, onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    self?.processErrorResponse(error: error)
                }
        })
    }
}
