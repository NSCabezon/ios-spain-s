import Foundation
import CoreFoundationLib

class CardLimitManagementOperative: Operative {
    let dependencies: PresentationComponent
    
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .limitGestion
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return .limitGestion
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.ModifyCardLimitsSummary().page
    }
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.ModifyCardLimitsSignature().page
    }
    
    var screenIdOtp: String? {
        return TrackerPagePrivate.ModifyCardLimitsOTP().page
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as CardLimitSetupStep)
        add(step: factory.createStep() as CardLimitManagementConfirmationStep)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: CardLimitManagementOperativeData = container.provideParameter()
        let input = PreSetupCardLimitManagementUseCaseInput(card: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.getPreSetupCardLimitManagementUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            let operativeData: CardLimitManagementOperativeData = container.provideParameter()
            operativeData.updatePre(cards: result.cards)
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { [weak self] _ in
            //TODO: The error to display is not defined yet
            completion(false, (title: nil, message: self?.dependencies.stringLoader.getString("deeplink_alert_errorMarketplace").text))
        })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: CardLimitManagementOperativeData = container.provideParameter()
        guard operativeData.productSelected?.cardDataDTO != nil else {
            delegate.hideOperativeLoading {
                //TODO: The error to display is not defined yet
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: "deeplink_alert_errorMarketplace", completion: nil)
            }
            return
        }
        let input = SetupCardLimitManagementUseCaseInput(card: operativeData.productSelected)
        UseCaseWrapper(with: dependencies.useCaseProvider.getSetupCardLimitManagementUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            container.saveParameter(parameter: operativeData)
            container.saveParameter(parameter: result.operativeConfig)
            success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else { return completion(false, nil) }
        let operativeData: CardLimitManagementOperativeData = container.provideParameter()
        let signatureFilled: SignatureFilled<SignatureWithToken> = containerParameter()
        guard let card = operativeData.productSelected, let limit = operativeData.cardLimit else { return completion(false, nil) }
        let input = CardLimitManagementConfirmationUseCaseInput(
            card: card,
            limit: limit,
            signature: signatureFilled.signature
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getCardLimitManagementConfirmationUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter,
            onSuccess: { [weak self] response in
                self?.container?.saveParameter(parameter: response.otp)
                completion(true, nil)
            },
            onError: { error in
                completion(false, error)
                
            }
        )
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let operativeData: CardLimitManagementOperativeData = containerParameter()
        guard let card = operativeData.productSelected, let limit = operativeData.cardLimit else { return completion(false, nil) }
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        let otpCode = otpFilled.value
        let validation: OTPValidation
        if let otpValidation = otpFilled.validation {
           validation = otpValidation
        } else {
            switch otp {
            case .userExcepted(let innerValidation):
                validation = innerValidation
            case .validation(let innerValidation):
                validation = innerValidation
            }
        }
        let input = CardLimitManagementOTPConfirmationUseCaseInput(limit: limit, otp: validation, otpCode: otpCode ?? "", card: card)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getCardLimitManagementOTPConfirmationUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            }
        )
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_changeLimitSuccess")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_label_changeImmediateEffect")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let operativeData: CardLimitManagementOperativeData = containerParameter()
        guard let card: Card = operativeData.productSelected, let cardLimit = operativeData.cardLimit else { return [] }
        var summaryItems = [SimpleSummaryData]()
        summaryItems.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_card"), value: card.getAliasAndInfo(), fieldIdentifier: "cardLimitSummary_card_field", valueIdentifier: "cardLimitSummary_card_value"))
        switch cardLimit {
        case .debit(let shopping, let atm):
            summaryItems.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_dailyLimitAtm"), value: atm.getAbsFormattedAmountUI(), fieldIdentifier: "cardLimitSummary_dailyAtm_field", valueIdentifier: "cardLimitSummary_dailyAtm_value"))
            summaryItems.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_limit_dailyLimitShopping"), value: shopping.getAbsFormattedAmountUI(), fieldIdentifier: "cardLimitSummary_dailyShopping_field", valueIdentifier: "cardLimitSummary_dailyShopping_value"))
        case .credit(let atm):
            summaryItems.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_dailyLimitAtm"), value: atm.getAbsFormattedAmountUI(), fieldIdentifier: "cardLimitSuammary_atm_field", valueIdentifier: "cardLimitSummary_atm_value"))
        }
        summaryItems.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: .dd_MMM_yyyy) ?? "", fieldIdentifier: "cardLimitSummary_date_field", valueIdentifier: "cardLimitSummary_date_value"))
        return summaryItems
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct CardLimitSetupStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardLimitPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct CardLimitManagementConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardLimitManagementConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
