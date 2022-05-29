import Foundation
import CoreFoundationLib

class UpdateNoSepaUsualTransferOperative: Operative {
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let isShareable = true
    let needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    var opinatorPage: OpinatorPage? {
        return .updateNoSepaUsualTransfer
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
        add(step: factory.createStep() as UpdateNoSepaUsualTransferInputData)
        add(step: factory.createStep() as UpdateNoSepaUsualTransferBankData)
        add(step: factory.createStep() as UpdateNoSepaUsualTransferConfirmation)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)

        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        //TODO: crear un caso de uso para esta operativa
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupUpdateNoSepaUsualTransferUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: UpdateNoSepaUsualTransferOperativeData = container.provideParameter()
                operativeData.sepaList = result.sepaList
                operativeData.allCountries = result.allCountries
                completion(true, nil)
            }, onError: { error in
                completion(false, (title: nil, message: error?.getErrorDesc()))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: UpdateNoSepaUsualTransferOperativeData = container.provideParameter()
        let input = SetupUpdateNoSepaUsualTransferUseCaseInput()
        let usecase = dependencies.useCaseProvider.getSetupUpdateNoSepaUsualTransferUseCase(input: input)
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
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
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let signatureFilled: SignatureFilled<SignatureWithToken> = containerParameter()
        let inputParameters = ValidateOTPUpdateNoSepaUsualTransferUseCaseInput(signatureWithToken: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.getValidateOTPUpdateNoSepaUsualTransferUseCase(input: inputParameters)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter,
                       onSuccess: { [weak self] response in
                        self?.container?.saveParameter(parameter: response.otp)
                        completion(true, nil)
            },
                       onError: { error in
                        completion(false, error)
        })
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        let otpCode = otpFilled.value
        let validation: OTPValidation
        if let otpFilledValidation = otpFilled.validation {
            validation = otpFilledValidation
        } else {
            switch otp {
            case .userExcepted(let innerValidation):
                validation = innerValidation
            case .validation(let innerValidation):
                validation = innerValidation
            }
        }
        let input = ConfirmUpdateNoSepaUsualTransferUseCaseInput(otp: validation, code: otpCode)
        let useCase = dependencies.useCaseProvider.getConfirmUpdateNoSepaUsualTransferUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_titie_favoriteRecipientsEdited")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameters: UpdateNoSepaUsualTransferOperativeData = containerParameter()
        
        let summaryBuilder = NoSepaFieldsBuilderFactory.create(parameters)
        return summaryBuilder.createSummaryFields(data: parameters, dependencies: dependencies)
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().noSepaSignature
    }
    
    var screenIdOtp: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().noSepaOtp
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().noSepaSummary
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
}

private struct UpdateNoSepaUsualTransferInputData: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.updateNoSepaUsualTransferInputDataPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

private struct UpdateNoSepaUsualTransferBankData: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.updateNoSepaUsualTransferBankDataPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

private struct UpdateNoSepaUsualTransferConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.updateNoSepaUsualTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
