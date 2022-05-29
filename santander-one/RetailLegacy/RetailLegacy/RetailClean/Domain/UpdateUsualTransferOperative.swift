import Foundation
import CoreFoundationLib

class UpdateUsualTransferOperative: BaseUsualTransferOperative {
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let isShareable = false
    let needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    var opinatorPage: OpinatorPage? {
        return .updateSepaUsualTransfer
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
        add(step: factory.createStep() as UpdateUsualTransferCountryCurrencySelector)
        add(step: factory.createStep() as UpdateUsualTransferInputData)
        add(step: factory.createStep() as UpdateUsualTransferConfirmation)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupUpdateUsualTransferUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: UpdateUsualTransferOperativeData = container.provideParameter()
                operativeData.updatePre(sepaList: result.sepaList)
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: UpdateUsualTransferOperativeData = container.provideParameter()
        let usecase = dependencies.useCaseProvider.getSetupUpdateUsualTransferUseCase()
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
        let confirmData = ValidateOTPUpdateUsualTransferUseCaseInput(signatureWithToken: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.getValidateOTPUpdateUsualTransferUseCase(input: confirmData)
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
        
        let input = ConfirmUpdateUsualTransferUseCaseInput(otp: validation, code: otpCode)
        let useCase = dependencies.useCaseProvider.getConfirmUpdateUsualTransferUseCase(input: input)
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
        let parameter: UpdateUsualTransferOperativeData = containerParameter()
        let builder = UpdateUsualTransferOperativeSummaryItemDataBuilder(parameter: parameter, dependencies: dependencies)
         builder.addAlias()
                .addBeneficiary()
                .addDestinationAccount()
                .addDestinationCountry()
                .addCurrency()
        return builder.build()
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().sepaSignature
    }
    
    var screenIdOtp: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().sepaOtp
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().sepaSummary
    }
}

struct UpdateUsualTransferCountryCurrencySelector: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.updateUsualTransferCountryCurrencySelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct UpdateUsualTransferInputData: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.updateUsualTransferInputDataPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct UpdateUsualTransferConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.updateUsualTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - SummaryItemBuilder
private class UpdateUsualTransferOperativeSummaryItemDataBuilder {
    let parameter: UpdateUsualTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: UpdateUsualTransferOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }

    @discardableResult
    func addAlias() -> UpdateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_alias"), value: "\(parameter.favourite?.alias ?? "")"))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> UpdateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: "\(parameter.newBeneficiaryName ?? "")"))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> UpdateUsualTransferOperativeSummaryItemDataBuilder {
        let accountText: String = parameter.newDestinationAccount?.formatted ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addDestinationCountry() -> UpdateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationCountry"), value: parameter.newCountry?.name.camelCasedString ?? ""))
        return self
    }
    
    @discardableResult
    func addCurrency() -> UpdateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_currency"), value: parameter.newCurrency?.name.camelCasedString ?? ""))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
