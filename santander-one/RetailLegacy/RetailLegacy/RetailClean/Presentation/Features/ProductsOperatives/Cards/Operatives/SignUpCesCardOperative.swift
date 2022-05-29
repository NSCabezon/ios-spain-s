import Foundation
import CoreFoundationLib

class SignUpCesCardOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = false
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .signCES
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.SignUpCesSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.SignUpCesSignature().page
    }
    var screenIdOtp: String? {
        return TrackerPagePrivate.SignUpCesOtp().page
    }
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: SignUpCesOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else {
            return nil
        }
        return [TrackerDimensions.cardType: card.trackId]
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as InsertPhoneCesSignUpCard)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupSignUpCesCardUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: SignUpCesOperativeData = container.provideParameter()
                operativeData.list = result.cards.filter({ !$0.isTemporallyOff })
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
        let operativeData: SignUpCesOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        UseCaseWrapper(
            with: dependencies.useCaseProvider.setupSignUpCesCardUseCase(input: SetupSignUpCesCardUseCaseInput(card: card)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                if result.allowsCesSignup {
                    operativeData.cesCard = result.cesCard
                    operativeData.cardDetail = result.cardDetail
                    container.saveParameter(parameter: result.operativeConfig)
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
            }
        )
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        
        let operativeData: SignUpCesOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected, let cesCard = operativeData.cesCard else { return }
        
        let input = ConfirmSignUpCesCardUseCaseInput(cesCard: cesCard, card: card, signatureWithToken: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.confirmSignUpCesCardUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] response in
            self?.container?.saveParameter(parameter: response.otp)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        
        let operativeData: SignUpCesOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        
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

        let input = ConfirmOtpSignUpCesCardUseCaseInput(card: card, otpValidation: validation, code: otpCode)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmOtpSignUpCesCardUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return self.dependencies.stringLoader.getString("summary_title_ces")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let operativeData: SignUpCesOperativeData = container.provideParameter()
        guard let cesCard = operativeData.cesCard else { return [] }
        
        let itemPhone = SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_phone"), value: cesCard.phoneNumber.spainTlfFormatted())
        
        return [itemPhone]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct InsertPhoneCesSignUpCard: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.insertPhoneSignUpCesCardPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

class SignUpCesOperativeData: ProductSelection<Card> {
    
    var cesCard: CesCard?
    var cardDetail: CardDetail?
    
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_ces", subTitleKey: "deeplink_label_selectOriginCard")
    }
}
