import Foundation
import CoreFoundationLib

class ChargeDischargeCardOperative: Operative {
    
    enum Constants: Double {
        case minimumChargeAmountECashMini = 0.01
        case maximumChargeAmountECashMini = 900
        case minimumChargeAmountOtherPrepaidCards = 6
        case maximumChargeAmountOtherPrepaidCards = 1650
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toCardsHomeNavigator
    }
    var opinatorPage: OpinatorPage? {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        guard let inputType = operativeData.inputType else {
            return nil
        }
        switch inputType {
        case .charge:
            return .ecashCharge
        case .discharge:
            return .ecashDischarge
        }
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return opinatorPage ?? .ecashGeneric
    }
    
    var screenIdSignature: String? {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        
        guard let inputType = operativeData.inputType else {
            return nil
        }
        
        switch inputType {
        case .charge:
            return TrackerPagePrivate.CardChargeSignature().page
        case .discharge:
            return TrackerPagePrivate.CardDischargeSignature().page
        }
    }
    
    var screenIdSummary: String? {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        
        guard let inputType = operativeData.inputType else {
            return nil
        }
        
        switch inputType {
        case .charge:
            return TrackerPagePrivate.CardChargeSummary().page
        case .discharge:
            return TrackerPagePrivate.CardDischargeSummary().page
        }
    }
    
    var screenIdOtp: String? {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        
        guard let inputType = operativeData.inputType else {
            return nil
        }
        
        switch inputType {
        case .charge:
            return TrackerPagePrivate.CardChargeOtp().page
        case .discharge:
            return TrackerPagePrivate.CardDischargeOtp().page
        }
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        guard let stringAmount = operativeData.inputType?.getAmount() else { return nil }
        switch Decimal.getAmountParserResult(value: stringAmount) {
        case .success(let decimalValue):
            let amount = Amount.createWith(value: decimalValue)
            return  [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
        default:
            break
        }
        return nil
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as SelectOriginAccount)
        add(step: factory.createStep() as SelectAmount)
        add(step: factory.createStep() as ChargeDischargeConfirmation)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupChargeDischargeCardUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: ChargeDischargeCardOperativeData = container.provideParameter()
                operativeData.list = result.cards
                operativeData.accountList = AccountList(result.accounts)
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { error in
                guard let errorDesc = error?.getErrorDesc() else {
                    completion(false, nil)
                    return
                }
                completion(false, (title: nil, message: errorDesc))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: ChargeDischargeCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        UseCaseWrapper(
            with: dependencies.useCaseProvider.setupChargeDischargeUseCase(input: SetupChargeDischargeCardUseCaseInput(card: card, accountList: operativeData.accountList)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.accountList = result.accountsList
                operativeData.prepaidCardData = result.prepaidCardData
                operativeData.topUpOptions = result.topUpOptions
                operativeData.withdrawOptions = result.withdrawOptions
                container.saveParameter(parameter: result.operativeConfig)
                success()
            }, onError: { error in
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        
        guard let validatePrepaidCard = operativeData.validatePrepaidCard, let card = operativeData.productSelected else {
            return
        }
        
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmChargeDischargeUseCase(input: ConfirmChargeDischargeUseCaseInput(card: card, signature: signatureFilled.signature, validatePrepaidCard: validatePrepaidCard)), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] result in
            self?.container?.saveParameter(parameter: result.otpValidation)
            completion(true, nil)            
        }, onError: { (error) -> Void in
            completion(false, error)
        })
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        
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
        
        guard let validatePrepaidCard = operativeData.validatePrepaidCard, let type = operativeData.inputType, let account = operativeData.account, let card = operativeData.productSelected, let prepaidCardData = operativeData.prepaidCardData else {
            return
        }
        
        let input = ConfirmOtpChargeDischargeUseCaseInput(card: card, type: type, account: account, validatePrepaidCard: validatePrepaidCard, prepaidCardData: prepaidCardData, otpValidation: validation, otpCode: otpCode)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmOtpChargeDischargeUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ -> Void in
            completion(true, nil)
        }, onError: { (error) -> Void in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        guard let inputType = operativeData.inputType else {
            return .empty
        }        
        switch inputType {
        case .charge:
            return dependencies.stringLoader.getString("summary_title_chargeBalance")
        case .discharge:
            return dependencies.stringLoader.getString("summary_title_dischargeBalance")
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let stringLoader = dependencies.stringLoader
        let amount = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amountString, fieldIdentifier: "chargeDischargeSummary_amount_field", valueIdentifier: "chargeDischargeSummary_amount_value")
        let comision = SimpleSummaryData(field: stringLoader.getString("summary_item_commission"), value: comissionString, fieldIdentifier: "chargeDischargeSummary_commission_field", valueIdentifier: "chargeDischargeSummary_commission_value")
        let originAccount = SimpleSummaryData(field: stringLoader.getString("summary_item_originAccount"), value: originAccountString, fieldIdentifier: "chargeDischargeSummary_origin_field", valueIdentifier: "chargeDischargeSummary_origin_value")
        let destinationCard = SimpleSummaryData(field: stringLoader.getString("summary_item_distinationCard"), value: destinationCardString, fieldIdentifier: "chargeDischargeSummary_destination_field", valueIdentifier: "chargeDischargeSummary_destination_value")
        let date = SimpleSummaryData(field: stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "", fieldIdentifier: "chargeDischargeSummary_date_field", valueIdentifier: "chargeDischargeSummary_date_value")
        
        return [amount, comision, originAccount, destinationCard, date]
    }
    
    //SUMMARY STRINGS TO SHOW
    private var amountString: String {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        
        guard let stringAmount = operativeData.inputType?.getAmount() else {
            return ""
        }
        
        var outputAmountString = ""
        
        switch Decimal.getAmountParserResult(value: stringAmount) {
        case .success(let decimalValue):
            let amount = Amount.createWith(value: decimalValue)
            outputAmountString = amount.getFormattedAmountUI()
        default:
            break
        }
        
        return outputAmountString
    }
    
    private var comissionString: String {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        let comisionAmount = operativeData.validatePrepaidCard?.preliqData.bankCharge
        return comisionAmount?.getFormattedAmountUI() ?? ""
    }
    
    private var originAccountString: String {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.account?.getAliasAndInfo() ?? ""
    }
    
    private var destinationCardString: String {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.productSelected?.getAliasAndInfo() ?? ""
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct SelectOriginAccount: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.chargeDischargeCardAccountSelectionPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct SelectAmount: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.chargeDischargeAmountInputPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ChargeDischargeConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.chargeDischargeCardConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
