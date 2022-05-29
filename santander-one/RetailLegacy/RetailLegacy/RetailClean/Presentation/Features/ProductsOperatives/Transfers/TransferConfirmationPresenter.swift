import CoreFoundationLib
import Foundation
import Transfer
import TransferOperatives

class TransferConfirmationPresenter<T: ConfirmationTransferOperativeData, UseCaseInput, UseCaseOkOutput: ValidateTransferUseCaseOkOutput, Navigator>: OperativeStepPresenter<TransferConfirmationViewController, Navigator, TransferConfirmationPresenterProtocol> {
    
    var subView: TransferConfirmViewProtocol?
    // MARK: - Overrided methods

    override func loadViewData() {
        super.loadViewData()
        self.subView?.setContinueTitle(stringLoader.getString("generic_button_confirm").text)
        self.setupConfirmationItems()
    }
    
    // MARK: - Class methods
    
    func proccessResponse(parameter: T, response: UseCaseOkOutput) {
        //Se usa en las clases hijas
    }
    
    func getUseCase(mail: String?, parameter: T) -> UseCase<UseCaseInput, UseCaseOkOutput, ValidateTransferUseCaseErrorOutput>? {
        //Se usa en las clases hijas
        return nil
    }
    
    func getUseCaseInput(mail: String?, parameter: T) -> UseCaseInput? {
        return nil
    }

    func continueWithBiometricValidation() {
        //To be override by subclasses in case biometric validation is needed
    }
    
    // MARK: - Private methods
    
    fileprivate enum Constants: String {
        case email
    }    
    
    func modifyAmountAndConcept() {}
    func modifyOriginAccount() {}
    func modifyTransferType() {}
    func modifyDestinationAccount() {}
    func modifyCountry() {}
    func modifyIssueDate() {}
    func modifyPeriodic() {}
    func setSummaryState(with state: OnePayTransferSummaryState) {}
    func validateWithBiometry() {}
    
    func validateSanKeyTransfer(_ completion: @escaping (Bool) -> Void) {
        let parameter: T = containerParameter()
        guard let usecase = getUseCase(mail: dataEntered(for: Constants.email.rawValue),
                                       parameter: parameter),
              let input = getUseCaseInput(mail: dataEntered(for: Constants.email.rawValue),
                                          parameter: parameter)
        else { return }
        Scenario(useCase: usecase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.hideAllLoadings {
                    var parameter: T = strongSelf.containerParameter()
                    strongSelf.proccessResponse(parameter: parameter, response: response)
                    parameter.beneficiaryMail = response.beneficiaryMail
                    strongSelf.container?.saveParameter(parameter: parameter)
                    if let param = parameter as? OnePayTransferOperativeData,
                       let resp = response as? ValidateOnePayTransferUseCaseOkOutput {
                        param.transferNational = resp.transferNational
                        param.tokenSteps = resp.transferNational?.tokenSteps
                        strongSelf.container?.saveParameter(parameter: param)
                    }
                    strongSelf.container?.saveParameter(parameter: response.scaEntity)
                    completion(true)
                }
            }
            .onError { [weak self] error in
                self?.hideAllLoadings {
                    guard let strongSelf = self else { return }
                    strongSelf.setSummaryState(with: .error)
                    guard let useCaseError = error as? ValidateTransferUseCaseErrorOutput else {
                        strongSelf.showError(keyDesc: error.getErrorDesc())
                        completion(false)
                        return
                    }
                    switch useCaseError.error {
                    case .invalidEmail:
                        strongSelf.subView?.showInvalidEmail("onePay_alert_mailNotValid")
                    case .serviceError(let errorDesc):
                        strongSelf.showError(keyDesc: errorDesc)
                    }
                    completion(false)
                }
            }
    }
}

private extension TransferConfirmationPresenter {
    func setupConfirmationItems() {
        let parameter: T = containerParameter()
        let data = ConfirmationTransferBuilderData(
            account: parameter.account,
            type: parameter.type,
            subType: parameter.subType,
            time: parameter.time,
            currency: parameter.currency,
            country: parameter.country,
            iban: parameter.iban,
            concept: parameter.concept,
            issueDate: parameter.issueDate,
            bankChargeAmount: parameter.bankChargeAmount,
            expensesAmount: parameter.expensesAmount,
            transferAmount: parameter.transferAmount,
            name: parameter.name)
        let builder = TransferConfirmationBuilder(data: data, dependencies: self.dependencies)
        guard let time = parameter.time else { return }
        builder.addAmount(action: modifyAmountAndConcept)
        builder.addConcept(action: modifyAmountAndConcept, isAvailable: parameter.isModifyConceptEnabled)
        builder.addOriginAccount(action: modifyAmountAndConcept, isAvailable: parameter.isModifyOriginAccountEnabled)
        builder.addTransferType(action: modifyTransferType, isAvailable: parameter.isModifyTransferTypeEnabled)
        builder.addDestinationAccount(action: modifyDestinationAccount, isAvailable: parameter.isModifyDestinationAccountEnabled)
        builder.addCountry(action: modifyCountry, isAvailable: parameter.isModifyCountryEnabled)
        switch time {
        case .now:
            builder.addMailAmount()
            builder.addDate()
        case .day:
            manageCommission(builder)
            builder.addIssueDate(position: .last, action: modifyIssueDate)
        case .periodic:
            manageCommission(builder)
            builder.addPeriodicity(position: .last, action: modifyPeriodic, isAvailable: parameter.isModifyPeriodicityEnabled)
        }
        self.subView?.add(builder.build())
        guard let totalAmount = self.getTotal() else { return }
        self.subView?.addTotalOperationAmount(totalAmount)
        if time != .now {
            self.subView?.addText(localized(key: "confirmation_item_onePayCommission").text)
        }
        let hideEmail = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.hideEmailNotification
        if let subtype = parameter.subType, subtype != .immediate, time == .now, hideEmail != true {
            self.subView?.addEmail()
        }
        if let param = parameter as? OnePayTransferOperativeData,
           shouldAddBiometricValidationButton(param) {
            self.subView?.addBiometricValidationButton()
        }
    }
    
    private func shouldAddBiometricValidationButton(_ param: OnePayTransferOperativeData) -> Bool {
        param.isBiometryEnabled &&
        param.isRightRegisteredDevice &&
        param.isTouchIdEnabled &&
        param.transferNational?.isCorrectFingerPrintFlag ?? false
    }

    func getTotal() -> AmountEntity? {
        let parameter: T = containerParameter()
        guard let transferAmount = parameter.transferAmount?.value else { return nil }
        var totalAmount: Decimal = transferAmount
        if let amount = parameter.bankChargeAmount?.value {
            totalAmount += amount
        }
        if let amount = parameter.expensesAmount?.value {
            totalAmount += amount
        }
        return Amount.create(value: totalAmount, currency: parameter.currency?.currency ?? Currency.createEur()).entity
    }
    
    func dataEntered(for identifier: String) -> String? {
        return self.subView?.email
    }
    
    func manageCommission(_ builder: TransferConfirmationBuilder) {
        if let showCosts = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.showCostsForStandingOrders,
           showCosts,
           haveCommissions()  {
            builder.addMailAmount()
        }
    }
    
    func haveCommissions() -> Bool {
        let parameter: T = containerParameter()
        guard let _ = parameter.expensesAmount else {
            return false
        }
        return true
    }
    
    func shareByText(_ iban: String) {
        let share: ShareCase = .share(content: iban)
        share.show(from: view)
    }
}

extension TransferConfirmationPresenter: TransferConfirmationPresenterProtocol {
    
    func didSelectShare(_ iban: String) {
        self.shareByText(iban)
    }
    
    func didSelectContinue() {
        let parameter: T = containerParameter()
        guard let usecase = getUseCase(mail: dataEntered(for: Constants.email.rawValue),
                                       parameter: parameter)
        else { return }
        showOperativeLoading(titleToUse: nil,
                             subtitleToUse: nil,
                             source: nil,
                             completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.validateSanKeyTransfer { isSuccess in
                if isSuccess {
                    strongSelf.setSummaryState(with: .success)
                    strongSelf.container?.rebuildSteps()
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            }
        })
    }

    func didSelectConfirmWithBiometrics() {
        continueWithBiometricValidation()
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapFaqs() {
        let parameter: T = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.TransferFaqs().page, extraParameters: [:])
        self.view.showFaqs(faqModel)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}

extension TransferConfirmationPresenter: TransferConfirmPresenterProtocol {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies.dependenciesEngine
    }
    
    func didTapBack() {
        self.container?.operativeContainerNavigator.back()
    }
}
