import Foundation
import CoreFoundationLib

final class PINQueryCardOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = false
    var needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.pinQueryCardViewOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .requestPin
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.CardsPINQuerySignature().page
    }
    var screenIdOtp: String? {
        return TrackerPagePrivate.CardsPINQueryOtp().page
    }
    
    private var typeCardParameters: [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: PINQueryCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else {
            return nil
        }
        return [TrackerDimensions.cardType: card.trackId]
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return typeCardParameters
    }
    
    func getTrackParametersOTP() -> [String: String]? {
        return typeCardParameters
    }
    
    var extraParametersForTrackerError: [String: String]? {
        return typeCardParameters
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupPINQueryUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: PINQueryCardOperativeData = container.provideParameter()
                operativeData.list = result.cards
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { _ in
                completion(false, (title: nil, message: "deeplink_alert_errorPin"))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: PINQueryCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        UseCaseWrapper(
            with: dependencies.useCaseProvider.setupPINQueryCardUseCase(input: SetupPINQueryCardUseCaseInput(card: card)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                container.saveParameter(parameter: result.signatureWithToken)
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
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        
        let operativeData: PINQueryCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        
        let input = ConfirmPINQueryCardUseCaseInput(card: card, signatureWithToken: signatureFilled.signature)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmPINQueryCardUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] response in
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
        
        let operativeData: PINQueryCardOperativeData = container.provideParameter()
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
        
        let input = ConfirmOtpPINQueryCardUseCaseInput(card: card, otpValidation: validation, code: otpCode)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmOtpPINQueryCardUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { [weak self] response in
            self?.container?.saveParameter(parameter: response.numberCipher)
            self?.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.CardsPINQuerySummary().page, extraParameters: self?.typeCardParameters ?? [:])
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return .empty
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        return nil
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return nil
    }
    
    func updateProgress(of presenter: OperativeStepProgressProtocol) {
        guard shouldShowProgress else {
            return
        }
        container?.updateProgress(totalUnitCount: Int64(numberOfStepsForProgress), completedUnitCount: Int64(presenter.number))
    }
}

class PINQueryCardOperativeData: ProductSelection<Card> {
    
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_seePin", subTitleKey: "deeplink_label_selectOriginCard")
    }
}
