import Foundation
import CoreFoundationLib

class CVVQueryCardOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = false
    var needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.cvvQueryCardFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .requestCvv
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
        self.registerDependencies()
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.CardsCVVQuerySignature().page
    }
    var screenIdOtp: String? {
        return TrackerPagePrivate.CardsCVVQueryOtp().page
    }
    
    var dependenciesEngine: DependenciesInjector & DependenciesResolver  {
        return dependencies.useCaseProvider.dependenciesResolver
    }
    
    private var sca: SCA? {
        let scaEntity: LegacySCAEntity? = self.container?.provideParameterOptional()
        return scaEntity?.sca
    }
    
    private var predefinedSCA: PredefinedSCAEntity? {
        let entity: PredefinedSCAEntity? = self.container?.provideParameterOptional()
        return entity
    }
    
    private var typeCardParameters: [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: CVVQueryCardOperativeData = container.provideParameter()
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
        self.addProductSelectionStep(of: Card.self)
        guard let sca = self.sca else {
            self.appendPredefinedSCASteps()
            return
        }
        sca.prepareForVisitor(self)
    }
    
    func rebuildSteps() {
        self.buildSteps()
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
    let predefineSCAUseCase = self.dependenciesEngine.resolve(for: CVVQueryPredefinedSCAUsecaseProtocol.self)
    let presetupUsecase = dependencies.useCaseProvider.getPreSetupCVVQueryCardUseCase()
    Scenario(useCase: predefineSCAUseCase)
        .execute(on: DispatchQueue.main)
        .onSuccess { result in
            container.saveParameter(parameter: result.predefinedSCAEntity)
        }.then(scenario: {_ in
            Scenario(useCase: presetupUsecase)
        }, scheduler: self.dependenciesEngine.resolve(for: UseCaseHandler.self))
        .onSuccess { result in
            let operativeData: CVVQueryCardOperativeData = container.provideParameter()
            operativeData.list = result.cards
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }.onError { result in
            completion(false, (title: nil, message: "deeplink_alert_errorCVV"))
        }
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: CVVQueryCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        let getSetupCVVQueryCardUseCase = self.dependencies.useCaseProvider.getSetupCVVQueryCardUseCase()
        let input = SetupCVVQueryCardUseCaseInput(card: card)
        Scenario(useCase: getSetupCVVQueryCardUseCase, input: input)
            .execute(on: dependencies.useCaseHandler)
            .onSuccess{ result in
                container.saveParameter(parameter: result.legacySCAEntity)
                container.saveParameter(parameter: result.operativeConfig)
                success()
                if !operativeData.isProductSelectedWhenCreated {
                    container.rebuildSteps()
                }
            }.onError{ error in
                delegate.hideOperativeLoading {
                    let message = error.getErrorDesc() == "notBeneficiaryCard" ?
                        "ces_alert_beneficiaryCard" :
                        error.getErrorDesc()
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: message, completion: nil)
                }
            }
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let operativeData: CVVQueryCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }

        let input = ConfirmCVVQueryCardUseCaseInput(card: card, signatureWithToken: signatureFilled.signature)
        UseCaseWrapper(with: dependencies.useCaseProvider.confirmCVVQueryCardUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] response in
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
        let operativeData: CVVQueryCardOperativeData = container.provideParameter()
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
        
        let input = ConfirmOtpCVVQueryCardUseCaseInput(card: card, otpValidation: validation, code: otpCode)
        let confirOtpUseCase = dependencies.useCaseProvider.confirmOtpCVVQueryCardUseCase(input: input)
        UseCaseWrapper(with: confirOtpUseCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { [weak self] response in
            self?.container?.saveParameter(parameter: response.numberCipher)
            self?.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.CardsCVVQuerySummary().page, extraParameters: self?.typeCardParameters ?? [:])
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

extension CVVQueryCardOperative {
    var stepFactory: OperativeStepFactory? {
        guard let presenterProvider = container?.presenterProvider else {
            return nil
        }
        return OperativeStepFactory(presenterProvider: presenterProvider)
    }
}

extension CVVQueryCardOperative: SCACapable {}

extension CVVQueryCardOperative: SCANoneWithResponseCapable {
    func prepareForSCANone(_ scaNone: SCANoneWithResponse) {
        let numberCipher: NumberCipher = scaNone.getResponse()
        self.container?.saveParameter(parameter: numberCipher)
    }
}

extension CVVQueryCardOperative: SCASignatureWithTokenCapable {
    func prepareForSignatureWithToken(_ signature: SignatureWithToken) {
        guard let factory = self.stepFactory else { return }
        self.container?.saveParameter(parameter: signature)
        self.add(step: factory.createStep() as OperativeSignatureWithToken)
    }
}

extension CVVQueryCardOperative: SCAOTPCapable {
    func prepareForOTP(_ otp: OTP?) {
        guard let factory = self.stepFactory else { return }
        if let otp = otp {
            self.container?.saveParameter(parameter: otp)
        }
        self.add(step: factory.createStep() as OperativeOTP)
    }
}

private extension CVVQueryCardOperative {
    func appendPredefinedSCASteps() {
        guard let factory = self.stepFactory else { return }
        switch self.predefinedSCA {
        case .signatureAndOtp:
            self.add(step: factory.createStep() as OperativeSignatureWithToken)
            self.add(step: factory.createStep() as OperativeOTP)
        case .otp:
            self.add(step: factory.createStep() as OperativeOTP)
        case .signature, .none:
            break
        }
    }
    
    func registerDependencies() {
        self.dependenciesEngine.register(for: CVVQueryPredefinedSCAUsecaseProtocol.self) { resolver in
            return CVVQueryPredefinedSCAUsecase(dependenciesResolver: resolver)
        }
    }
}
    
class CVVQueryCardOperativeData: ProductSelection<Card> {
        
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_seeCvv", subTitleKey: "deeplink_label_selectOriginCard")
    }
}
