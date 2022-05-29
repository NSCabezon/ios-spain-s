class EnableOtpPushChangeAliasPresenter: OperativeStepPresenter<EnableOtpPushChangeAliasViewController, VoidNavigator, EnableOtpPushChangeAliasPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.OtpPushOperativeAlias().page
    }
    var operativeMode: EnableOTPPushOperativeMode? {
        guard let container = container else { return nil }
        let operativeData: EnableOtpPushOperativeData = container.provideParameter()
        return operativeData.operativeMode
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.set(title: getTitle())
        view.configureNextStep(withTitle: stringLoader.getString("generic_button_save"))
    }
    
    private func getTitle() -> LocalizedStylableText {
        return stringLoader.getString("toolbar_title_secureDevice")
    }
}

extension EnableOtpPushChangeAliasPresenter: EnableOtpPushChangeAliasPresenterProtocol {
    func nextStep() {
        self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.OtpPushOperativeAlias().page, eventId: TrackerPagePrivate.OtpPushOperativeAlias.Action.save.rawValue, extraParameters: [:])
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        
        var alias: String?
        if let newAlias = view.alias, !newAlias.isEmpty {
            alias = newAlias
        }
        let usecase = useCaseProvider.getValidateEnableOtpPushUseCase()
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let self = self, let container = self.container else { return }
            self.hideLoading(completion: {
                if let signatureAndToken = response.signatureToken {
                    
                    var operativeData: EnableOtpPushOperativeData = container.provideParameter()
                    operativeData.alias = alias
                    
                    container.saveParameter(parameter: operativeData)
                    container.saveParameter(parameter: signatureAndToken)
                    container.stepFinished(presenter: self)
                } else {
                    self.showError(keyDesc: nil)
                }
            })
            
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.hideLoading(completion: {
                    self.container?.operative.trackErrorEvent(page: self.screenId, error: error?.getErrorDesc(), code: error?.errorCode)
                    self.showError(keyTitle: "generic_alert_title_errorData", keyDesc: error?.getErrorDesc(), phone: nil, completion: nil)
                })
        })
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    func didTapClose() {
        closeButtonTouched()
    }
}
