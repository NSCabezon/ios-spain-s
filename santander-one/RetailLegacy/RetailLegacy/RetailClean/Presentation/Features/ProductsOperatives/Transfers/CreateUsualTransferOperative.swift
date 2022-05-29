import Foundation
import CoreFoundationLib

class CreateUsualTransferOperative: BaseUsualTransferOperative {
    struct Constants {
        static let firstCellExtraTopInset: Double = 30.0
    }
    
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
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        return parameter.isNoSepa ? .createNoSepaUsualTransfer: .createSepaUsualTransfer
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
        add(step: factory.createStep() as CreateUsualTransferCountryCurrencySelector)
      
    }
    
    func rebuildSteps() {
        buildSteps()
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        if parameter.isNoSepa {
            add(step: factory.createStep() as CreateNoSepaUsualTransferInputData)
            add(step: factory.createStep() as CreateNoSepaUsualTransferInputDataDetail)            
            add(step: factory.createStep() as CreateNoSepaUsualTransferConfirmation)
        } else {
            add(step: factory.createStep() as CreateUsualTransferInputData)
            add(step: factory.createStep() as CreateUsualTransferConfirmation)
        }
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    var numberOfStepsForProgress: Int {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        return parameter.isNoSepa ? 7 : 6
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupCreateUsualTransferUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: CreateUsualTransferOperativeData = container.provideParameter()
                operativeData.sepaList = result.sepaList
                completion(true, nil)
            }, onError: { error in
                completion(false, (title: nil, message: error?.getErrorDesc()))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: CreateUsualTransferOperativeData = container.provideParameter()
        let input = SetupCreateUsualTransferUseCaseInput()
        let usecase = dependencies.useCaseProvider.getSetupCreateUsualTransferUseCase(input: input)
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
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        if parameter.isNoSepa {
            let confirmData = ValidateOTPCreateNoSepaUsualTransferUseCaseInput(signatureWithToken: signatureFilled.signature)
            let useCase = dependencies.useCaseProvider.getValidateOTPCreateNoSepaUsualTransferUseCase(input: confirmData)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter,
                           onSuccess: { [weak self] response in
                            self?.container?.saveParameter(parameter: response.otp)
                            completion(true, nil)
                },
                           onError: { error in
                            completion(false, error)
            })
        } else {
            let confirmData = ValidateOTPCreateUsualTransferUseCaseInput(signatureWithToken: signatureFilled.signature)
            let useCase = dependencies.useCaseProvider.getValidateOTPCreateUsualTransferUseCase(input: confirmData)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter,
                           onSuccess: { [weak self] response in
                            self?.container?.saveParameter(parameter: response.otp)
                            completion(true, nil)
                },
                           onError: { error in
                            completion(false, error)
            })
        }
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
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        if parameter.isNoSepa {
            let input = ConfirmCreateNoSepaUsualTransferUseCaseInput(otp: validation, code: otpCode)
            let useCase = dependencies.useCaseProvider.getConfirmCreateNoSepaUsualTransferUseCase(input: input)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        } else {
            let input = ConfirmCreateUsualTransferUseCaseInput(otp: validation, code: otpCode)
            let useCase = dependencies.useCaseProvider.getConfirmCreateUsualTransferUseCase(input: input)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        }
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_newFavoriteRecipients")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        if parameter.isNoSepa {
            let noSepaParameter: CreateNoSepaUsualTransferOperativeData = containerParameter()
            let builder = CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder(parameter: noSepaParameter, dependencies: dependencies)
            builder.addAlias()
                .addBeneficiary()
                .addDestinationAccount()
                .addDestinationCountry()
                .addCurrency()
                .addBicSwift()
                .addBankName()
            return builder.build()
        } else {
            let builder = CreateUsualTransferOperativeSummaryItemDataBuilder(parameter: parameter, dependencies: dependencies)
            builder.addAlias()
                .addBeneficiary()
                .addDestinationAccount()
                .addDestinationCountry()
                .addCurrency()
            return builder.build()
        }
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        return parameter.isNoSepa ?
            TrackerPagePrivate.CreateNoSepaUsualTransferSignature().page:
            TrackerPagePrivate.CreateSepaUsualTransferSignature().page
    }
    
    var screenIdOtp: String? {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        return parameter.isNoSepa ?
            TrackerPagePrivate.CreateNoSepaUsualTransferOtp().page:
            TrackerPagePrivate.CreateSepaUsualTransferOtp().page
    }
    
    var screenIdSummary: String? {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        return parameter.isNoSepa ?
            TrackerPagePrivate.CreateNoSepaUsualTransferSummary().page:
            TrackerPagePrivate.CreateSepaUsualTransferSummary().page
    }
}

struct CreateUsualTransferCountryCurrencySelector: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.createUsualTransferCountryCurrencySelectorPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct CreateUsualTransferInputData: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.createUsualTransferInputDataPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct CreateUsualTransferConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.createUsualTransferConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - No Sepa Steps
struct CreateNoSepaUsualTransferInputData: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.createNoSepaUsualTransferInputDataPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct CreateNoSepaUsualTransferInputDataDetail: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.createNoSepaUsualTransferInputDataDetailPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct CreateNoSepaUsualTransferConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.createNoSepaUsualTransferConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - SummaryItemBuilder

private class CreateUsualTransferOperativeSummaryItemDataBuilder {
    let parameter: CreateUsualTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: CreateUsualTransferOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addAlias() -> CreateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_alias"), value: parameter.alias ?? ""))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> CreateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: parameter.beneficiaryName ?? ""))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> CreateUsualTransferOperativeSummaryItemDataBuilder {
        let accountText: String = parameter.iban?.formatted ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addDestinationCountry() -> CreateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationCountry"), value: parameter.country?.name.camelCasedString ?? ""))
        return self
    }
    
    @discardableResult
    func addCurrency() -> CreateUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_currency"), value: parameter.currency?.name.camelCasedString ?? ""))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}

private class CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
    let parameter: CreateNoSepaUsualTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: CreateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addAlias() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_alias"), value: parameter.alias ?? ""))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: parameter.beneficiaryName ?? ""))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
        let accountText: String = parameter.account ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addDestinationCountry() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationCountry"), value: parameter.country?.name.camelCasedString ?? ""))
        return self
    }
    
    @discardableResult
    func addCurrency() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_currency"), value: parameter.currency?.name.camelCasedString ?? ""))
        return self
    }
    
    @discardableResult
    func addBicSwift() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
        if let swiftCode = parameter.noSepaPayee?.swiftCode, !swiftCode.isEmpty {
            fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_label_bicSwift"), value: swiftCode))
        }
        return self
    }
    
    @discardableResult
    func addBankName() -> CreateNoSepaUsualTransferOperativeSummaryItemDataBuilder {
         if let bankName = parameter.noSepaPayee?.bankName, !bankName.isEmpty {
            fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_nameBank"), value: bankName))
        }
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
