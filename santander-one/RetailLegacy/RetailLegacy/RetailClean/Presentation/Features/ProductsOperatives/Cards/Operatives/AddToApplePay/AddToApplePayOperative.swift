import Foundation
import CoreFoundationLib
import Cards

class AddToApplePayOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let applePay: String = localized("cardsOption_button_pay_ios")
    let isShareable = true
    let needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.applePayFinishNavigator
    }
    var opinatorPage: OpinatorPage? {
        return nil
    }
    let dependencies: PresentationComponent
    let dependenciesResolver: DependenciesResolver
    lazy var applePayEnrollment: ApplePayEnrollmentManager = {
        return self.dependenciesResolver.resolve(for: ApplePayEnrollmentManager.self)
    }()
    var numberOfStepsForProgress: Int {
        return 3
    }
    
    init(dependencies: PresentationComponent, dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependencies
        self.dependenciesResolver = dependenciesResolver
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
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate,
                         container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupAddToApplePayUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { response in
                let operativeData: AddToApplePayOperativeData = container.provideParameter()
                operativeData.list = response.cards
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { [weak self] error in
                let message = error?.getErrorDesc()
                    .map({ localized($0, [StringPlaceholder(.value, self?.applePay ?? "")]) })?.text
                completion(false, (title: nil, message: message))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate,
                      container: OperativeContainerProtocol, success: @escaping () -> Void) {
        self.getCardApplePaySupport(container: container) { [weak self] (supported, error) in
            if supported {
                self?.getSetupAddToApplePayUseCase(for: delegate, container: container, success: success)
            } else {
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error, completion: nil)
                }
            }
        }
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler,
                          completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let operativeData: AddToApplePayOperativeData = containerParameter()
        let useCase = dependencies.useCaseProvider.getAddToApplePayValidationUseCase(input: AddToApplePayValidationUseCaseInput(card: operativeData.card, signatureWithToken: signatureFilled.signature))
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter,
            onSuccess: { result in
                container.saveParameter(parameter: result.otp)
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            }
        )
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let operativeData: AddToApplePayOperativeData = containerParameter()
        let otpFilled: OTPFilled = containerParameter()
        guard
            let detail = operativeData.cardDetail?.entity,
            let validation = otpFilled.validation,
            let otpCode = otpFilled.value,
            let card = operativeData.card
        else {
            return
        }
        self.applePayEnrollment.enrollCard(
            card.cardEntity,
            detail: detail,
            otpValidation: validation.entity,
            otpCode: otpCode
        ) { result in
            switch result {
            case .success:
                self.loadCardsApplePayStatus {
                    presenter.hideOtpLoading {
                        self.container?.stepFinished(presenter: presenter.operativeStepPresenter)
                        self.dependenciesResolver.resolve(for: ApplePayEnrollmentDelegate.self).applePayEnrollmentDidFinishSuccessfully()
                    }
                }
            case .failure(let error):
                guard let applePayError = error as? ApplePayError else {
                    // Workaround to close operative
                    completion(true, nil)
                    return
                }
                switch applePayError {
                case .description(let description):
                    presenter.hideOtpLoading {
                        presenter.showOtpError(keyDesc: description, completion: {})
                    }
                case .notAvailable, .unknown:
                    // Workaround to close operative
                    completion(true, nil)
                }
            }
        }
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
    
    // MARK: - Tracker
    
    var screenIdProductSelection: String? {
        return nil
    }
    
    var screenIdSignature: String? {
        return nil
    }
    
    var screenIdOtp: String? {
        return nil
    }
    
    var screenIdSummary: String? {
        return nil
    }
    
    // Parameters are sent when enter in Signature screen
    func getTrackParametersSignature() -> [String: String]? {
        return nil
    }
    
    // Parameters are sent when enter in OTP screen
    func getTrackParametersOTP() -> [String: String]? {
        return nil
    }
    
    // Parameters are sent when enter in Summary screen
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
    
    // Extra parameters are sent when click in share buttons in Summary screen
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return nil
    }
    
    // The additional parameters are automatically sent when the Signature or OTP fails or for example when we want to register when a service fails, we can call the trackErrorEvent() function of the operative container.
    var extraParametersForTrackerError: [String: String]? {
        return nil
    }
}

private extension AddToApplePayOperative {
    func getCardApplePaySupport(container: OperativeContainerProtocol,
                                completion: @escaping (Bool, String?) -> Void) {
        let operativeData: AddToApplePayOperativeData = container.provideParameter()
        let useCase = dependenciesResolver.resolve(for: GetCardApplePaySupportUseCase.self)
        guard let card = operativeData.card else {
            completion(false, nil)
            return
        }
        let input = GetCardApplePaySupportUseCaseInput(card: card.cardEntity)
        UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: dependencies.useCaseHandler,
            onSuccess: { [weak self] response in
                guard response.applePayState == .inactive else {
                    let error = localized("deeplink_alert_cardNotAdded",
                        [StringPlaceholder(.value, self?.applePay ?? "")]).text
                    completion(false, error)
                    return
                }
                completion(true, nil)
            },
            onError: { [weak self] _ in
                let error = localized("deeplink_alert_cardNotAdded",
                    [StringPlaceholder(.value, self?.applePay ?? "")]).text
                completion(false, error)
            }
        )
    }
    
    func getSetupAddToApplePayUseCase(for delegate: OperativeLauncherPresentationDelegate,
                                      container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: AddToApplePayOperativeData = container.provideParameter()
        let input = SetupAddToApplePayUseCaseInput(card: operativeData.card)
        let usecase = dependencies.useCaseProvider.getSetupAddToApplePayUseCase(input: input)
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.cardDetail = result.cardDetail
                container.saveParameter(parameter: result.signatureWithToken)
                container.saveParameter(parameter: result.operativeConfig)
                container.saveParameter(parameter: operativeData)
                success()
            }, onError: { error in
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func loadCardsApplePayStatus(completion: @escaping () -> Void) {
        let scenario = Scenario(useCase: dependenciesResolver.resolve(firstTypeOf: LoadCardsListApplePayStatusUseCase.self))
        scenario
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { _ in
                completion()
            }
            .onError { _ in
                completion()
            }
    }
}
