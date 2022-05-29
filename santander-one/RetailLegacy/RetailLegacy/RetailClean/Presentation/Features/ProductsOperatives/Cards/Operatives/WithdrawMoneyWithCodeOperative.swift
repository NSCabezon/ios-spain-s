import Foundation
import CoreFoundationLib

class WithdrawMoneyWithCodeOperative: Operative {
    let dependencies: PresentationComponent

    // MARK: - LifeCycle
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Operative
    
    let isShareable = true
    let needsReloadGP = true
    var steps: [OperativeStep] = []
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .cashWithdrawal
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.CashWithdrawlCodeSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.CashWithdrawlCodeSignature().page
    }
    var screenIdOtp: String? {
        return TrackerPagePrivate.CashWithdrawlCodeOtp().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        guard let amount = operativeData.amount else {
            return nil
        }
        return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else {
            return
        }
        let useCase = dependencies.useCaseProvider.setupWithdrawMoneyWithCodeUseCase(input: SetupWithdrawMoneyWithCodeUseCaseInput(card: card))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            if result.cardDetail.allowsWithdrawMoney {
                let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
                container.saveParameter(parameter: result.operativeConfig)
                operativeData.update(cardDetail: result.cardDetail, amounts: result.amounts)
                container.saveParameter(parameter: operativeData)
                success()
            } else {
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: "ces_alert_beneficiaryCard", completion: nil)
                }
            }
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }

   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        let input = PreSetupWithdrawMoneyWithCodeUseCaseInput(card: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.preSetupWithdrawMoneyWithCodeUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
            operativeData.updatePre(list: result.cards)
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { error in
            guard let errorDesc = error?.getErrorDesc() else {
                completion(false, nil)
                return
            }
            completion(false, (title: nil, message: errorDesc))
        })
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        guard let amount = operativeData.amount, let card = operativeData.productSelected else {
            return
        }
        let otpFilled: OTPFilled = container.provideParameter()
        let otp: OTP = container.provideParameter()
        var validation = otpFilled.validation
        let otpCode = otpFilled.value
        if validation == nil {
            switch otp {
            case .userExcepted(let innerValidation):
                validation = innerValidation
            case .validation(let innerValidation):
                validation = innerValidation
            }
        }
        let input = ConfirmOtpWithdrawMoneyWithCodeUseCaseInput(card: card, otpValidation: validation, code: otpCode, amount: amount)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmOtpWithdrawMoneyWithCodeUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { [weak self] response in
            let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
            operativeData.cashWithDrawal = response.cashWithDrawal
            self?.container?.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else {
            return
        }
        let input = ConfirmWithdrawMoneyWithCodeUseCaseInput(signature: signatureFilled.signature, card: card)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmWithdrawMoneyWithCodeUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] response in
            self?.container?.saveParameter(parameter: response.otp)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_successCode")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_link_atmClosest")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        guard let cashWithDrawal = operativeData.cashWithDrawal, let amountDO = operativeData.amount else {
            return nil
        }
        var items: [SummaryItemData] = []
        let stringLoader = dependencies.stringLoader
        let code = cashWithDrawal.code
        let amount = amountDO.getFormattedAmountUI(0)
        let date = dependencies.timeManager.toString(input: cashWithDrawal.date, inputFormat: .YYYYMMDD_T_HHMM, outputFormat: .d_MMM_yyyy) ?? cashWithDrawal.date
        let fee = cashWithDrawal.fee.getAbsFormattedAmountUIWith1M()
        let phone = cashWithDrawal.phone.obfuscateNumber(withNumberOfAsterisks: 5)
        let codeItem = PostItSummaryData(field: stringLoader.getString("summary_item_code"), value: code)
        items.append(codeItem)
        let amountItem = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount)
        items.append(amountItem)
        let dateItem = SimpleSummaryData(field: stringLoader.getString("summary_item_expiryDate"), value: date)
        items.append(dateItem)
        let feeItem = SimpleSummaryData(field: stringLoader.getString("summary_item_commission"), value: fee)
        items.append(feeItem)
        let phoneItem = SimpleSummaryData(field: stringLoader.getString("summary_item_phone"), value: phone)
        items.append(phoneItem)
        let cashierItem = LinkSummaryItemData(field: stringLoader.getString("summary_subtitle_successCode"), tag: 0, delegate: self)
        items.append(cashierItem)
        return items
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }

    // MARK: - Class Methods
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as WithdrawMoneyConfigurationOperativeStep)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeWithdrawMoneySummary)
    }
}

extension WithdrawMoneyWithCodeOperative: LinkSummaryItemDelegate {
    func selectedLink(tag: Int) {
        let completion: () -> Void = { [weak self] in
            self?.container?.presenterProvider.sessionManager.sessionStarted(completion: {
                self?.dependencies.navigatorProvider.withdrawMoneyNavigator.goToAtmLocator()
            })
        }
        let completionError: (String?) -> Void = { [weak self] error in
            self?.container?.presenterProvider.sessionManager.finishWithReason(.failedGPReload(reason: error))
        }
        container?.reloadPG(onSuccess: completion, onError: completionError)
    }
}

struct WithdrawMoneyConfigurationOperativeStep: OperativeStep {
    private let presenterProvider: PresenterProvider
    
    // MARK: - OperativeStep
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.withdrawMoneyConfigurationPresenter
    }
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
