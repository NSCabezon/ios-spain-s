import CoreFoundationLib
import Foundation

class MobileTopUpOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let isShareable = true
    let needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toCardsHomeNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .mobileRecharge
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.MobileRechargeSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.MobileRechargeSignature().page
    }
    var screenIdOtp: String? {
        return TrackerPagePrivate.MobileRechargeOtp().page
    }
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let amount: Amount = container.provideParameter()
        return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        add(step: factory.createStep() as MobileTopUpDataCollection)
        add(step: factory.createStep() as MobileTopUpConfirmationStep)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let card: Card = container.provideParameter()
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
        
        let input = ConfirmOtpMobileToUpUseCaseInput(card: card, otpValidation: validation, otpCode: otpCode)
        let usecase = dependencies.useCaseProvider.confirmOtpMobileToUpUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let card: Card = container.provideParameter()
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let phone: MobilePhoneNumber = container.provideParameter()
        let mobile: String = phone.number.tlfwithValidaRecargaMovilOTP()
        let amount: Amount = container.provideParameter()
        let mobileOperator: MobileOperator = container.provideParameter()
        let input = ConfirmMobileToUpUseCaseInput(card: card, signature: signatureFilled.signature, mobile: mobile, amount: amount, mobileOperator: mobileOperator)
        let usecase = dependencies.useCaseProvider.confirmMobileToUpUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { response in
            container.saveParameter(parameter: response.otpValidation)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_mobileRechangeSuccess")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let stringLoader = dependencies.stringLoader
        let card: Card = container.provideParameter()
        let phone: MobilePhoneNumber = container.provideParameter()
        let mobile: String = phone.number.spainTlfFormatted()
        let amount: Amount = container.provideParameter()
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy)
        let mobileOperator: MobileOperator = container.provideParameter()
        let cardItem = SimpleSummaryData(field: stringLoader.getString("summary_item_originCard"),
                                         value: card.getAliasAndInfo(),
                                         fieldIdentifier: AccessibilityMobileRecharge.summaryCardTitle.rawValue,
                                         valueIdentifier: AccessibilityMobileRecharge.summaryCardValue.rawValue)
        let phoneItem = SimpleSummaryData(field: stringLoader.getString("summary_item_phone"),
                                          value: mobile,
                                          fieldIdentifier: AccessibilityMobileRecharge.summaryPhoneTitle.rawValue,
                                          valueIdentifier: AccessibilityMobileRecharge.summaryPhoneValue.rawValue)
        let operatorItem = SimpleSummaryData(field: stringLoader.getString("summary_item_operator"),
                                             value: mobileOperator.name ?? "",
                                             fieldIdentifier: AccessibilityMobileRecharge.summaryOperatorTitle.rawValue,
                                             valueIdentifier: AccessibilityMobileRecharge.summaryOperatorValue.rawValue)
        let dateItem = SimpleSummaryData(field: stringLoader.getString("summary_item_operationDate"),
                                         value: date ?? "",
                                         fieldIdentifier: AccessibilityMobileRecharge.summaryOperationDateTitle.rawValue,
                                         valueIdentifier: AccessibilityMobileRecharge.summaryOperationDateValue.rawValue)
        let amountItem = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"),
                                           value: amount.getFormattedAmountUI(),
                                           fieldIdentifier: AccessibilityMobileRecharge.summaryAmountTitle.rawValue,
                                           valueIdentifier: AccessibilityMobileRecharge.summaryAmountValue.rawValue)
        return [cardItem, phoneItem, operatorItem, dateItem, amountItem]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct MobileTopUpDataCollection: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.mobileTopUpPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct MobileTopUpConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.mobileTopUpConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider

    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
