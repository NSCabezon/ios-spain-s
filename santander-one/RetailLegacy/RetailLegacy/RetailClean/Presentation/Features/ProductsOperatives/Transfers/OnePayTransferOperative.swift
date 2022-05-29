import CoreFoundationLib
import Operative
import Transfer
import TransferOperatives

class OnePayTransferOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable: Bool {
        return getSummaryState() == .success
    }
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        let parameter: OnePayTransferOperativeData = containerParameter()
        let finishType: OnePayTransferOperativeFinishType = parameter.finishType
        return dependencies.navigatorProvider.toHomeTransferNavigator(type: finishType)
    }
    var pdfSource: PdfSource {
        return .transferSummary
    }
    
    var signatureNavigationTitle: String? {
        return "toolbar_title_moneyTransfers"
    }
    
    var otpNavigationTitle: String? {
        return "toolbar_title_moneyTransfers"
    }

    var opinatorPage: OpinatorPage? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        if parameter.summaryState == .success {
            switch parameter.type {
            case .national?:
                switch parameter.subType {
                case .standard?:
                    switch parameter.time {
                    case .day?:
                        return .nationalDeferredTransfer
                    case .periodic?:
                        return .nationalPeriodicTransfer
                    default:
                        return .nationalTransfer
                    }
                case .immediate?:
                    return .inmediateTransfer
                case .urgent?:
                    return .urgentTransfer
                case .none:
                    return nil
                }
            case .sepa?:
                switch parameter.time {
                case .day?:
                    return .internationalDeferredTransfer
                case .periodic?:
                    return .internationalPeriodicTransfer
                default:
                    return .internationalTransfer
                }
            case .noSepa?:
                    return .noSepaSend
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    var sharingType: OperativeSharingType {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national, .sepa:
            return .image
        case .noSepa, .none:
            return .text
        }
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return .nationalTransfer
    }
    
    private var biometricsManager: LocalAuthenticationPermissionsManagerProtocol {
        self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }

    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    var getTokenPushUseCase: GetLocalPushTokenUseCase {
            self.dependenciesResolver.resolve(for: GetLocalPushTokenUseCase.self)
        }
    
    let dependencies: PresentationComponent
    var dependenciesResolver: DependenciesResolver {
        return dependencies.useCaseProvider.dependenciesResolver
    }
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    private func setDefaultNumberOfStepsForProgress(numberOfSteps: Int) -> Int {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .some: return steps.count
        case .none: return numberOfSteps
        }
    }
    
    var numberOfStepsForProgress: Int {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let onePayTransferModifier = dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            let numberOfSteps = !parameter.isProductSelectedWhenCreated ? 7 : 6
            return setDefaultNumberOfStepsForProgress(numberOfSteps: numberOfSteps)
        }
        let numberOfSteps = onePayTransferModifier.getNumberOfStepsForProgress(isProductSelectedWhenCreated: parameter.isProductSelectedWhenCreated)
        return setDefaultNumberOfStepsForProgress(numberOfSteps: numberOfSteps)
    }
    
    var payer: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return parameter.payer
    }
    
    private var contactsEngine: ContactsEngineProtocol {
        self.dependencies.navigatorProvider.dependenciesEngine.resolve()
    }
        
    private var predefinedSCA: PredefinedSCAEntity? {
        let entity: PredefinedSCAEntity? = self.container?.provideParameterOptional()
        return entity
    }
    
    private var sca: SCA? {
        let scaEntity: LegacySCAEntity? = self.container?.provideParameterOptional()
        return scaEntity?.sca
    }
    
    var stepFactory: OperativeStepFactory? {
        guard let presenterProvider = container?.presenterProvider else {
            return nil
        }
        return OperativeStepFactory(presenterProvider: presenterProvider)
    }
    private var showSpecialPricesForNowTransfers: Bool {
        guard let onePayTransferModifier = dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            return true
        }
        return onePayTransferModifier.showSpecialPricesForNowTransfers
    }
    private var showSpecialPricesForDateTransfers: Bool {
        guard let onePayTransferModifier = dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            return false
        }
        return onePayTransferModifier.showSpecialPricesForDateTransfers
    }
    private var showSpecialPricesForPeriodicTransfers: Bool {
        guard let onePayTransferModifier = dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            return false
        }
        return onePayTransferModifier.showSpecialPricesForPeriodicTransfers
    }
        
    func buildSteps() {
        guard let factory = self.stepFactory else { return }
        let parameter: ProductSelection<Account> = containerParameter()
        if !parameter.isProductSelectedWhenCreated {
            add(step: factory.createStep() as OnePayAccountSelectorStep) //Put this step to use the account selector of Transfer module
        }
        add(step: factory.createStep() as OnePayTransferSelectorStep)
    }
    
    func rebuildSteps() {
        buildSteps()
        guard let factory = self.stepFactory else { return }
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type else {
            return
        }
        switch type {
        case .national:
            add(step: factory.createStep() as OnePayTransferDestinationStep)
            appendSpecialPricesStep(parameter: parameter, type: type)
            add(step: factory.createStep() as OnePayTransferConfirmationStep)
            let avoidSignatureAndOTPSteps = parameter.isBiometryAppConfigEnabled &&
                                            parameter.isCorrectFingerFlag &&
                                            parameter.userPreffersBiometry
            if (!avoidSignatureAndOTPSteps) {
                addSCASteps()
            }
            add(step: factory.createStep() as OnePayTransferLisboaSummaryStep)
        case .sepa:
            add(step: factory.createStep() as OnePayTransferDestinationStep)
            appendSpecialPricesStep(parameter: parameter, type: type)
            add(step: factory.createStep() as OnePayTransferConfirmationStep)
            addSCASteps()
            add(step: factory.createStep() as OnePayTransferLisboaSummaryStep)
        case .noSepa:
            add(step: factory.createStep() as OnePayNoSepaTransferSelectorStep)
            let noSepaData: NoSepaTransferOperativeData? = container?.provideParameterOptional()
            if noSepaData?.shouldAskForDetail == true {
                add(step: factory.createStep() as OnePayNoSepaTransferSelectorDetailStep)
            }
            add(step: factory.createStep() as OnePayNoSepaTransferConfirmationStep)
            add(step: factory.createStep() as OperativeSimpleSignature)
            add(step: factory.createStep() as OperativeOTP)
            add(step: factory.createStep() as OnePayNoSepaTransferSummaryStep)
        }
    }
    
    private func appendSpecialPricesStep(parameter: OnePayTransferOperativeData, type: OnePayTransferType) {
        guard let factory = self.stepFactory else { return }
        if showSpecialPricesForNowTransfers && showSpecialPricesForDateTransfers && showSpecialPricesForPeriodicTransfers {
            add(step: factory.createStep() as OnePayTransferSubtypeSelectorStep)
        } else {
            if type == .national,
               let time = parameter.time {
                if case OnePayTransferTime.now = time, self.showSpecialPricesForNowTransfers {
                    add(step: factory.createStep() as OnePayTransferSubtypeSelectorStep)
                } else if case OnePayTransferTime.day = time, self.showSpecialPricesForDateTransfers {
                    add(step: factory.createStep() as OnePayTransferSubtypeSelectorStep)
                } else if time.isPeriodic(), self.showSpecialPricesForPeriodicTransfers {
                    add(step: factory.createStep() as OnePayTransferSubtypeSelectorStep)
                }
            }
        }
    }

    private func appendPredefinedSCASteps() {
        guard let factory = self.stepFactory else { return }
        switch self.predefinedSCA {
        case .signatureAndOtp:
            add(step: factory.createStep() as OperativeSimpleSignature)
            add(step: factory.createStep() as OperativeOTP)
        case .otp, .signature, .none:
            break
        }
    }
    
    private func addSCASteps() {
        guard let _ = self.sca else {
            appendPredefinedSCASteps()
            return
        }
        self.sca?.prepareForVisitor(self)
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
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
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: performNationalOTP(for: presenter,
                                            validation: validation,
                                            otpCode: otpCode,
                                            completion: completion)
        case .sepa?: performSepaOTP(for: presenter,
                                    validation: validation,
                                    otpCode: otpCode,
                                    completion: completion)
        case .noSepa?: performNoSepaOTP(for: presenter,
                                        validation: validation,
                                        otpCode: otpCode,
                                        completion: completion)
        case .none: break
        }
    }
    
    func getRichSharingText() -> String? {
        if getSummaryState() == .success {
            let parameter: OnePayTransferOperativeData = containerParameter()
            switch parameter.type {
            case .national?, .sepa?:
                return getSepaRichSharingText()
            case .noSepa?:
                return getNoSepaRichSharingText()
            case .none:
                break
            }
        }
        return nil
    }
        
    func getSummaryImage() -> ShareTransferSummaryView? {
        let container: OnePayTransferOperativeData = containerParameter()
        let shareView = ShareTransferSummaryView()
        let viewModel = ShareTransferSummaryViewModel(operativeData: container, dependencies: dependencies)
        shareView.modalPresentationStyle = .fullScreen
        shareView.loadViewIfNeeded()
        shareView.setInfo(viewModel)
        return shareView
    }
    
    private func performSepaOTP(for presenter: GenericOtpDelegate,
                                validation: OTPValidation?,
                                otpCode: String?,
                                completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type,
              let subType = parameter.subType,
              let account = parameter.productSelected,
              let iban = parameter.iban,
              let amount = parameter.amount,
              let time = parameter.time else {
            completion(false, nil)
            return
        }
        let input = ConfirmOtpOnePayTransferUseCaseInput(otpValidation: validation,
                                                         code: otpCode ?? "",
                                                         type: type,
                                                         subType: subType,
                                                         originAccount: account,
                                                         destinationIBAN: iban,
                                                         name: parameter.name,
                                                         alias: parameter.alias,
                                                         isSpanishResident: parameter.spainResident ?? false,
                                                         saveFavorites: parameter.saveToFavorites ?? false,
                                                         beneficiaryMail: parameter.beneficiaryMail,
                                                         amount: amount,
                                                         concept: parameter.concept,
                                                         time: time,
                                                         scheduledTransfer: parameter.scheduledTransfer)
        UseCaseWrapper(with: dependencies.useCaseProvider.getConfirmOtpOnePayTransferUseCase(input: input),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: presenter.errorOtpHandler,
                       onSuccess: { [weak self] result in
            parameter.transferConfirmAccount = result.transferConfirmAccount
            self?.container?.saveParameter(parameter: parameter)
            let onePayTransferModifier = self?.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self)
            if subType == .immediate, onePayTransferModifier == nil {
                self?.performCheckInternal(for: presenter, completion: completion)
            } else {
                parameter.summaryState = .success
                self?.container?.saveParameter(parameter: parameter)
                // For national standard transfers, we have to check if the transfer is fundable
                if type == .national && time == .now {
                    self?.loadAccountEasyPayInfo(presenter: presenter) { accountEasyPay in
                        self?.loadFundableType(presenter: presenter, accountEasyPay: accountEasyPay) {
                            completion(true, nil)
                        }
                    }
                } else {
                    completion(true, nil)
                }
            }
        }, onError: { error in
            completion(false, error)
        })
    }

    func performNationalOTP(for presenter: GenericOtpDelegate,
                                           validation: OTPValidation?,
                                           otpCode: String?,
                                           completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type,
              let subType = parameter.subType,
              let account = parameter.productSelected,
              let iban = parameter.iban,
              let amount = parameter.amount,
              let time = parameter.time
        else {
            completion(false, nil)
            return
        }
        var input = ConfirmOtpOnePayTransferUseCaseInput(
            otpValidation: validation,
            code: otpCode ?? "",
            type: type,
            subType: subType,
            originAccount: account,
            destinationIBAN: iban,
            name: parameter.name,
            alias: parameter.alias,
            isSpanishResident: parameter.spainResident ?? false,
            saveFavorites: parameter.saveToFavorites ?? false,
            beneficiaryMail: parameter.beneficiaryMail,
            amount: amount,
            concept: parameter.concept,
            time: time,
            scheduledTransfer: parameter.scheduledTransfer
        )
        let useCase: UseCase<ConfirmOtpOnePayTransferUseCaseInput, ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput>!
        if parameter.isBiometryAppConfigEnabled {
            input.tokenSteps = parameter.tokenSteps
            useCase = dependencies.useCaseProvider.getConfirmOtpOnePaySanKeyTransferUseCase(input: input)
        } else {
            useCase = dependencies.useCaseProvider.getConfirmOtpOnePayTransferUseCase(input: input)
        }
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { [weak self] result in
                parameter.transferConfirmAccount = result.transferConfirmAccount
                self?.container?.saveParameter(parameter: parameter)
                let onePayTransferModifier = self?.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self)
                if subType == .immediate, onePayTransferModifier == nil {
                    self?.performCheckInternal(for: presenter, completion: completion)
                } else {
                    parameter.summaryState = .success
                    self?.container?.saveParameter(parameter: parameter)
                    // For national standard transfers, we have to check if the transfer is fundable
                    if type == .national && time == .now {
                        self?.loadAccountEasyPayInfo(presenter: presenter) { accountEasyPay in
                            self?.loadFundableType(presenter: presenter, accountEasyPay: accountEasyPay) {
                                completion(true, nil)
                            }
                        }
                    } else {
                        completion(true, nil)
                    }
                }
            }, onError: { error in
                completion(false, error)
            })
    }
    
    private func loadAccountEasyPayInfo(presenter: GenericOtpDelegate, completion: @escaping (AccountEasyPay?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getGetAccountEasyPayUseCase(input: GetAccountEasyPayUseCaseInput(type: .transfer)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { response in
                completion(response.accountEasyPay)
            },
            onError: { [weak self] error in
                completion(nil)
                self?.container?.operative.trackErrorEvent(page: TrackerPagePrivate.NationalTransferSummary().page, error: error?.getErrorDesc(), code: error?.errorCode)
            }
        )
    }
    
    private func loadFundableType(presenter: GenericOtpDelegate, accountEasyPay: AccountEasyPay?, completion: @escaping () -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let accountEasyPay = accountEasyPay, let amount = parameter.amount else { return completion() }
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getAccountEasyPayFundableTypeUseCase(input: AccountEasyPayFundableTypeUseCaseInput(amount: amount, accountEasyPay: accountEasyPay)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { [weak self] response in
                parameter.easyPayFundableType = response.accountEasyPayFundableType
                self?.container?.saveParameter(parameter: parameter)
                completion()
            },
            onError: { _ in
                completion()
            }
        )
    }
    
    private func performNoSepaOTP(for presenter: GenericOtpDelegate, validation: OTPValidation?, otpCode: String?, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let operativeData: NoSepaTransferOperativeData = containerParameter()
        let beneficiaryAddress = operativeData.beneficiaryAddress
        let swiftValidation = operativeData.swiftValidation
        guard let beneficiary = operativeData.beneficiary, let beneficiaryAccount = operativeData.beneficiaryAccount, let noSepaTransferValidation = operativeData.noSepaTransferValidation, let otpValidation = validation else { return completion(false, nil) }
        
        let transferAmount = operativeData.amount
        let originAccount = operativeData.account
        let country = operativeData.country
        let input = ConfirmNoSepaTransferOTPUseCaseInput(
            originAccount: originAccount,
            beneficiary: beneficiary,
            beneficiaryAccount: beneficiaryAccount,
            beneficiaryAddress: beneficiaryAddress,
            dateOperation: operativeData.date,
            transferAmount: transferAmount,
            expensiveIndicator: operativeData.transferExpenses,
            countryCode: country.code,
            concept: operativeData.concept ?? "",
            noSepaTransferValidation: noSepaTransferValidation,
            swiftValidation: swiftValidation,
            otpValidation: otpValidation,
            otpCode: otpCode ?? "",
            beneficiaryEmail: operativeData.beneficiaryEmail,
            aliasPayee: operativeData.aliasPayee,
            isNewPayee: operativeData.isNewPayee
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmNoSepaTransferOTPUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { response in
                let parameter: OnePayTransferOperativeData = self.containerParameter()
                if response.result == "PE" {
                    parameter.summaryState = .error
                } else {
                    parameter.summaryState = .success
                }
                self.container?.saveParameter(parameter: parameter)
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            }
        )

    }
    
    private func performCheckInternal(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        let stringLoader = dependencies.stringLoader
        presenter.updateOtpLoading(text: LoadingText(title: stringLoader.getString("loading_label_doingOperation"), subtitle: stringLoader.getString("loading_label_onePay")))
        guard let transferConfirmAccount = parameter.transferConfirmAccount else {
            completion(false, nil)
            return
        }
        let input = CheckStatusOnePayTransferUseCaseInput(transferConfirmAccount: transferConfirmAccount)
        let usecase = dependencies.useCaseProvider.getCheckStatusOnePayTransferUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { [weak self] result in
            parameter.summaryState = result.status
            self?.container?.saveParameter(parameter: parameter)
            completion(true, nil)
        }, onError: { error in
            presenter.hideOtpLoading {
                presenter.showOtpError(keyDesc: error?.getErrorDesc(), completion: { [weak self] in
                    self?.container?.reloadPGAndExit()
                })
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: performNationalSignature(for: presenter, completion: completion)
        case .sepa?: performSepaSignature(for: presenter, completion: completion)
        case .noSepa?: performNoSepaSignature(for: presenter, completion: completion)
        case .none: break
        }
    }
    
    private func performSepaSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type, let originAccount = parameter.productSelected, let amount = parameter.amount, let beneficiary = parameter.name, let iban = parameter.iban, let time = parameter.time else {
            completion(false, nil)
            return
        }
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        let input = ConfirmOnePayTransferUseCaseInput(signature: signatureFilled.signature, type: type, originAccount: originAccount, amount: amount, beneficiary: beneficiary, isSpanishResident: parameter.spainResident ?? false, iban: iban, saveAsUsual: parameter.saveToFavorites ?? false, concept: parameter.concept, saveAsUsualAlias: parameter.alias, beneficiaryMail: parameter.beneficiaryMail, time: time, dataMagicPhrase: parameter.scheduledTransfer?.dataMagicPhrase)
        let useCase = dependencies.useCaseProvider.getConfirmOnePayTransferUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] response in
            self?.container?.saveParameter(parameter: response.otp)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func performNationalSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let amount = parameter.amount,
              let beneficiary = parameter.name,
              let iban = parameter.iban,
              let time = parameter.time
        else {
            completion(false, nil)
            return
        }
        var signatureFilled: SignatureFilled<Signature>? = containerParameter()
        if parameter.userPreffersBiometry {
            signatureFilled = nil
        }
        var input = ConfirmOnePayTransferUseCaseInput(signature: signatureFilled?.signature,
                                                      type: type,
                                                      originAccount: originAccount,
                                                      amount: amount,
                                                      beneficiary: beneficiary,
                                                      isSpanishResident: parameter.spainResident ?? false,
                                                      iban: iban,
                                                      saveAsUsual: parameter.saveToFavorites ?? false,
                                                      concept: parameter.concept,
                                                      saveAsUsualAlias: parameter.alias,
                                                      beneficiaryMail: parameter.beneficiaryMail,
                                                      time: time,
                                                      dataMagicPhrase: parameter.scheduledTransfer?.dataMagicPhrase)
        var useCase: UseCase<ConfirmOnePayTransferUseCaseInput, ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput>!
        if parameter.isBiometryAppConfigEnabled {
            if parameter.userPreffersBiometry {
                input.footPrint = parameter.footprint
                input.deviceToken = parameter.deviceToken
            }
            input.tokenSteps = parameter.transferNational?.tokenSteps
            useCase = dependencies.useCaseProvider.getConfirmOnePaySanKeyTransferUseCase(input: input)
        } else {
            useCase = dependencies.useCaseProvider.getConfirmOnePayTransferUseCase(input: input)
        }
        UseCaseWrapper(with: useCase,
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: presenter,
                       onSuccess: { [weak self] response in
            parameter.tokenSteps = response.sanKeyOTP?.tokenSteps
            self?.container?.saveParameter(parameter: parameter)
            self?.container?.saveParameter(parameter: response.otp)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    private func performNoSepaSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let operativeData: NoSepaTransferOperativeData = containerParameter()
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        let beneficiaryAddress = operativeData.beneficiaryAddress
        guard let beneficiary = operativeData.beneficiary, let beneficiaryAccount = operativeData.beneficiaryAccount, let noSepaTransferValidation = operativeData.noSepaTransferValidation else { return }
        let transferAmount = operativeData.amount
        let originAccount = operativeData.account
        let country = operativeData.country
        let input = ConfirmNoSepaTransferUseCaseInput(
            signature: signatureFilled.signature,
            originAccount: originAccount,
            beneficiary: beneficiary,
            beneficiaryAccount: beneficiaryAccount,
            beneficiaryAddress: beneficiaryAddress,
            dateOperation: operativeData.date,
            transferAmount: transferAmount,
            expensiveIndicator: operativeData.transferExpenses,
            countryCode: country.code,
            concept: operativeData.concept ?? "",
            noSepaTransferValidation: noSepaTransferValidation
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmNoSepaTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter,
            onSuccess: { response in
                self.container?.saveParameter(parameter: response.otp)
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            }
        )

    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        UseCaseWrapper(with: dependencies.useCaseProvider.setupOnePayTranferCardUseCase(),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: delegate.errorOperativeHandler,
                       onSuccess: { result in
                        let operativeData: OnePayTransferOperativeData = container.provideParameter()
                        self.contactsEngine.fetchContacts { contacts in
                            var favContacts: [Favourite] = []
                            if case let .success(contactsList) = contacts {
                                favContacts = contactsList.map(Favourite.init)
                            }
                            container.saveParameter(parameter: result.operativeConfig)
                            operativeData.update(favouriteList: favContacts.map(SepaFavoriteAdapter.init),
                                                 maxImmediateNationalAmount: result.maxAmount,
                                                 payer: result.payer,
                                                 baseUrl: result.baseUrl,
                                                 enabledFavouritesCarrusel: result.enabledFavouritesCarrusel,
                                                 favoriteContacts: result.favoriteContacts,
                                                 summaryUserName: result.summaryUserName)
                            container.saveParameter(parameter: operativeData)
                            success()
                        }
                       }, onError: { error in
                        delegate.hideOperativeLoading {
                            delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                        }
                       })
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate,
                         container: OperativeContainerProtocol,
                         completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: OnePayTransferOperativeData = container.provideParameter()
        let input = PreSetupOnePayTransferCardUseCaseInput(account: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.getPreSetupOnePayTransferCardUseCase()
        let useCasePredefined = dependencies.useCaseProvider.getPredefinedSCAOnePayTransferUseCase()
        
        Scenario(useCase: useCasePredefined)
            .execute(on: DispatchQueue.main)
            .onSuccess { result in
                container.saveParameter(parameter: result.predefinedSCAEntity)
            }.then(scenario: { _ in
                Scenario(useCase: usecase, input: input)
            }, scheduler: dependencies.useCaseHandler)
            .onSuccess { result in
                operativeData.updatePre(accounts: result.accountVisibles,
                                        accountNotVisibles: result.accountNotVisibles,
                                        sepaList: result.sepaList,
                                        faqs: result.faqs)
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }.onError { _ in
                completion(false, (title: nil, message: "deeplink_alert_errorSend"))
            }
        
        //consulta de biometría activada para transferencias (app config)
        operativeData.isBiometryAppConfigEnabled = dependenciesResolver
            .resolve(forOptionalType: AppConfigRepositoryProtocol.self)?
            .getBool("enableSepaTransferBiometric") ?? false
        //consulta de touchId
        operativeData.isTouchIdEnabled = biometricsManager.isTouchIdEnabled
        container.saveParameter(parameter: operativeData)
        //consulta de dispositivo seguro
        evaluateSecureDevice(container: container)
        //consulta de token push
        evaluateTokenPush(container: container)
    }
    
    private func evaluateSecureDevice(container: OperativeContainerProtocol) {
        let operativeData: OnePayTransferOperativeData = container.provideParameter()
        otpPushManager?.updateToken(completion: { _, state in
            operativeData.isRightRegisteredDevice = state == .rightRegisteredDevice
            container.saveParameter(parameter: operativeData)
        })
    }
    
    private func evaluateTokenPush(container: OperativeContainerProtocol) {
        let operativeData: OnePayTransferOperativeData = container.provideParameter()
        Scenario(useCase: getTokenPushUseCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { response in
                operativeData.tokenPush = response.toStringTokenPush
                container.saveParameter(parameter: operativeData)
            }
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.time {
        case .day?, .periodic?:
            return dependencies.stringLoader.getString("summary_title_standardProgrammedOneaPay")
        default:
            break
        }
        switch parameter.type {
        case .national?:
            guard let subType = parameter.subType else { return dependencies.stringLoader.getString("") }
            switch subType {
            case .standard:
                return dependencies.stringLoader.getString("summary_title_standardOnePay")
            case .immediate:
                guard let summaryState = parameter.summaryState else { return dependencies.stringLoader.getString("") }
                switch summaryState {
                case .success: return dependencies.stringLoader.getString("summary_title_immediateOnePay")
                case .error: return dependencies.stringLoader.getString("summary_title_notImmediateOnePay")
                case .pending: return dependencies.stringLoader.getString("summary_title_pendingImmediateOnePay")
                }
            case .urgent:
                return dependencies.stringLoader.getString("summary_title_expressOnePay")
            }
        case .sepa?:
            return dependencies.stringLoader.getString("summary_title_standardOnePay")
        case .noSepa?:
            switch getSummaryState() {
            case .success:
                return dependencies.stringLoader.getString("summary_title_standardOnePay")
            case .error:
                return dependencies.stringLoader.getString("onePay_title_transferFailed")
            default:
                return .empty
            }
        case .none:
            return .empty
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.time {
        case .day?, .periodic?:
            return dependencies.stringLoader.getString("summary_subtitle_paidOnePay")
        default:
            break
        }
        switch parameter.type {
        case .national?:
            guard let subType = parameter.subType else { return dependencies.stringLoader.getString("") }
            switch subType {
            case .standard:
                guard let _ = dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
                    return dependencies.stringLoader.getString("summary_subtitle_standardOnePay")
                }
                return dependencies.stringLoader.getString("")
            case .immediate:
                guard let summaryState = parameter.summaryState else { return dependencies.stringLoader.getString("") }
                switch summaryState {
                case .success: return dependencies.stringLoader.getString("summary_subtitle_immediateOnePay")
                case .error: return dependencies.stringLoader.getString("summary_subtitle_errorImmediateOnePay")
                case .pending: return dependencies.stringLoader.getString("summary_title_processedOperation")
                }
            case .urgent:
                return dependencies.stringLoader.getString("summary_label_expressOnePay")
            }
        case .sepa?:
            return dependencies.stringLoader.getString("summary_subtitle_intenationalOnePay")
        case .noSepa?:
            switch getSummaryState() {
            case .success:
                return dependencies.stringLoader.getString("summary_subtitle_timeDelivery")
            case .error:
                return dependencies.stringLoader.getString("onePay_label_errorFailedNoSepa")
            default:
                return nil
            }
        case .none:
            return nil
        }
    }
    
    var pdfTitle: String? {
        return "toolbar_title_detailOnePay"
    }
    
    var pdfContent: String? {
        if getSummaryState() == .success {
            let parameter: OnePayTransferOperativeData = containerParameter()
            switch parameter.type {
            case .national?, .sepa?:
                return getSepaPfdContent()
            case .noSepa?:
                return getNoSepaPfdContent()
            case .none:
                break
            }
        }
        return nil
    }
    
    private func getNoSepaRichSharingText() -> String? {
        let parameter: NoSepaTransferOperativeData = containerParameter()
        let builder = TransferEmailBuilder(stringLoader: dependencies.stringLoader)
        guard
            let payer = self.payer,
            let destinationAccount = parameter.beneficiaryAccount?.account
        else {
            return nil
        }
        let shortDestinationAccount = destinationAccount.asterisk()
        if let concept = parameter.concept, !concept.isEmpty {
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer", [StringPlaceholder(.name, payer), StringPlaceholder(.value, shortDestinationAccount), StringPlaceholder(.value, concept)]).text)
        } else {
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer_withoutConcept", [StringPlaceholder(.name, payer), StringPlaceholder(.value, shortDestinationAccount)]).text)
        }
        builder.addTransferInfo([
            EmailInfo(key: "summary_item_payer", value: payer, detail: parameter.account.getAsteriskIban()),
            EmailInfo(key: "summary_item_beneficiary", value: parameter.beneficiary, detail: shortDestinationAccount),
            EmailInfo(key: "summary_label_destinationCountryToPayement", value: parameter.country.name, detail: nil),
            EmailInfo(key: "summary_label_bicSwift", value: parameter.beneficiaryAccount?.bicSwift, detail: nil),
            EmailInfo(key: "summary_item_nameBank", value: parameter.beneficiaryAccount?.bankName, detail: nil),
            EmailInfo(key: "summary_item_amount", value: parameter.noSepaTransferValidation?.settlementAmountBenef, detail: nil),
            EmailInfo(key: "summary_item_concept", value: transferConcept(currentConcept: parameter.concept), detail: nil),
            EmailInfo(key: "summary_item_periodicity", value: dependencies.stringLoader.getString("summary_label_timely").text, detail: nil),
            EmailInfo(key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.date, outputFormat: .dd_MMM_yyyy), detail: nil),
            EmailInfo(key: expensesKey(), value: parameter.noSepaTransferValidation?.expenses, detail: nil),
            EmailInfo(key: "summary_item_swiftExpenses", value: parameter.noSepaTransferValidation?.swiftExpenses, detail: nil),
            EmailInfo(key: "summary_item_mailExpenses", value: parameter.noSepaTransferValidation?.mailExpenses, detail: nil),
            EmailInfo(key: "summary_label_totalExpenses", value: parameter.noSepaTransferValidation?.impTotComComp, detail: nil),
            EmailInfo(key: "summary_label_payerAmountToDebt", value: parameter.noSepaTransferValidation?.settlementAmountPayer, detail: nil),
            EmailInfo(key: "summary_label_amountBeneficiaryPay", value: parameter.noSepaTransferValidation?.settlementAmountBenef, detail: nil)
        ])
        return builder.build()
    }
    
    private func getSepaRichSharingText() -> String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let iban = parameter.iban, let payer = parameter.payer else { return nil }
        let builder = TransferEmailBuilder(stringLoader: dependencies.stringLoader)
        if let concept = parameter.concept, !concept.isEmpty {
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer", [StringPlaceholder(.name, payer), StringPlaceholder(.value, iban.getAsterisk()), StringPlaceholder(.value, concept)]).text)
        } else {
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer_withoutConcept", [StringPlaceholder(.name, payer), StringPlaceholder(.value, iban.getAsterisk())]).text)
        }
        builder.addTransferInfo([
            EmailInfo(key: "summary_item_payer", value: parameter.payer, detail: parameter.account?.getAsteriskIban()),
            EmailInfo(key: "summary_item_beneficiary", value: parameter.name, detail: parameter.iban?.getAsterisk()),
            EmailInfo(key: "summary_item_amount", value: parameter.amount, detail: nil),
            EmailInfo(key: "summary_item_concept", value: transferConcept(currentConcept: parameter.concept), detail: nil),
            EmailInfo(key: "summary_item_periodicity", value: transferPeriodicity(), detail: nil),
            EmailInfo(key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.issueDate, outputFormat: .dd_MMM_yyyy), detail: nil),
            EmailInfo(key: "summary_item_startDate", value: startDate(), detail: nil),
            EmailInfo(key: "summary_item_endDate", value: endDate(), detail: nil),
            EmailInfo(key: "summary_item_commission", value: parameter.transferNational?.bankChargeAmount ?? parameter.scheduledTransfer?.bankChargeAmount, detail: nil),
            EmailInfo(key: "summary_item_mailExpenses", value: parameter.transferNational?.expensesAmount, detail: nil),
            EmailInfo(key: "summary_item_amountToDebt", value: parameter.transferNational?.netAmount, detail: nil)
            ])
        return builder.build()
    }
    
    private func getSepaPfdContent() -> String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard
            let originAccountAlias = parameter.productSelected?.getAlias(),
            let originAccountIBAN = parameter.productSelected?.getAsteriskIban(),
            let destinationIBAN = parameter.iban?.getAsterisk()
        else {
            return nil
        }
        let date: Date?
        switch parameter.time {
        case .now?:
            date = Date()
        case .day(let day)?:
            date = day
        case .periodic(let startDate, _, _, _)?:
            date = startDate
        case .none:
            date = nil
        }
        let builder = TransferPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: date)
        if let accountNumberFotmat = dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) {
            let originAccountNumber = accountNumberFotmat.accountNumberFormat(parameter.account?.accountEntity)
            builder.addAccounts(originAccountAlias: originAccountAlias, originAccountIBAN: originAccountNumber, destinationAccountAlias: parameter.name ?? "", destinationAccountIBAN: destinationIBAN)
        } else {
            builder.addAccounts(originAccountAlias: originAccountAlias, originAccountIBAN: originAccountIBAN, destinationAccountAlias: parameter.name ?? "", destinationAccountIBAN: destinationIBAN)
        }
        builder.addTransferInfo([
            (key: "summary_item_amount", value: parameter.amount),
            (key: "summary_item_concept", value: transferConcept(currentConcept: parameter.concept, time: parameter.time)),
            (key: "summary_item_periodicity", value: transferPeriodicity()),
            (key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.issueDate, outputFormat: .dd_MMM_yyyy)),
            (key: "summary_item_startDate", value: startDate()),
            (key: "summary_item_endDate", value: endDate())
        ])
        builder.addExpenses([
            getCommissonValue(),
            (key: "summary_item_mailExpenses", value: parameter.transferNational?.expensesAmount ?? parameter.commission),
            (key: "summary_item_amountToDebt", value: parameter.transferNational?.netAmount)
        ])
        return builder.build()
    }
    
    private func getExchangeRate() -> String? {
        let data: NoSepaTransferOperativeData = containerParameter()
        guard var amount = data.noSepaTransferValidation?.preciseAmountNumber.getFormattedAmountUI(currencyFormat: .none, 4),
              let currencyPayer = data.noSepaTransferValidation?.settlementAmountPayer?.currencyName, !currencyPayer.isEmpty,
              let currencyBenef = data.noSepaTransferValidation?.settlementAmountBenef?.currencyName, !currencyBenef.isEmpty
        else { return nil }
        amount += " \(currencyPayer)/\(currencyBenef)"
        return amount
    }
    
    private func getNoSepaPfdContent() -> String? {
        let parameter: NoSepaTransferOperativeData = containerParameter()
        let builder = TransferPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        guard
            let originAccountAlias = parameter.account.getAlias(),
            let destinationAccount = parameter.beneficiaryAccount?.account
        else {
            return nil
        }
        let shortDestinationAccount = destinationAccount.asterisk()
        builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: parameter.date)
        builder.addAccounts(originAccountAlias: originAccountAlias,
                            originAccountIBAN: parameter.account.getAsteriskIban(),
                            destinationAccountAlias: parameter.beneficiary ?? "",
                            destinationAccountIBAN: shortDestinationAccount)
        var transferInfo: [(key: String, value: PDFStringConvertible?)] = [
            (key: "summary_label_destinationCountryToPayement", value: parameter.country.name),
            (key: "summary_label_bicSwift", value: parameter.beneficiaryAccount?.bicSwift),
            (key: "summary_item_nameBank", value: parameter.beneficiaryAccount?.bankName),
            (key: "summary_item_amount", value: parameter.noSepaTransferValidation?.settlementAmountBenef),
            (key: "summary_item_concept", value: transferConcept(currentConcept: parameter.concept)),
            (key: "summary_item_periodicity", value: dependencies.stringLoader.getString("summary_label_timely").text),
            (key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.date, outputFormat: .dd_MMM_yyyy))
         ]
        let exchangeRatePositionOnPDF = 5
        if let exchangeRate = getExchangeRate(), exchangeRatePositionOnPDF < transferInfo.count {
            transferInfo.insert((key: "summary_item_exchangeRate", value: exchangeRate), at: exchangeRatePositionOnPDF)
        }
        builder.addTransferInfo(transferInfo)
        builder.addExpenses([
            (key: expensesKey(), value: parameter.noSepaTransferValidation?.expenses),
            (key: "summary_item_swiftExpenses", value: parameter.noSepaTransferValidation?.swiftExpenses),
            (key: "summary_item_mailExpenses", value: parameter.noSepaTransferValidation?.mailExpenses),
            (key: "summary_label_totalExpenses", value: parameter.noSepaTransferValidation?.impTotComComp),
            (key: "summary_label_payerAmountToDebt", value: parameter.noSepaTransferValidation?.settlementAmountPayer),
            (key: "summary_label_amountBeneficiaryPay", value: parameter.noSepaTransferValidation?.settlementAmountBenef)
        ])
        return builder.build()
    }
    
    private func expensesKey() -> String {
        let parameter: NoSepaTransferOperativeData = containerParameter()
        switch parameter.transferExpenses {
        case .shared:
            return "summary_item_sharedExpenses"
        case .payer:
            return "summary_item_payerExpenses"
        case .beneficiary:
            return "summary_item_beneficiaryExpenses"
        }
    }
    
    private func startDate() -> String? {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        switch operativeData.time {
        case .periodic(let startDate, _, _, _)?:
            let issueDate = dependencies.timeManager.toString(date: startDate, outputFormat: .dd_MMM_yyyy)
            return issueDate
        default: return nil
        }
    }
    
    private func endDate() -> String? {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        switch operativeData.time {
        case .periodic(_, let endDate, _, _)?:
            let endDateValue: String
            switch endDate {
            case .date(let date):
                endDateValue = dependencies.timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy) ?? ""
            case .never:
                endDateValue = dependencies.stringLoader.getString("detailsOnePay_label_indefinite").text
            }
            return endDateValue
        default:
            return nil
        }
    }
    
    private func transferConcept(currentConcept: String?, time: OnePayTransferTime? = .now) -> String {
        let concept: String
        if let transferConcept = currentConcept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            switch time {
            case .periodic?, .day?:
                concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
            case .now?, .none:
                concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
            }
        }
        return concept
    }
    
    private func transferPeriodicity() -> String {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        let periodicity: String
        switch operativeData.time {
        case .day?:
            periodicity = dependencies.stringLoader.getString("summary_label_delayed").text
        case .periodic(_, _, let periodicityValue, _)?:
            switch periodicityValue {
            case .monthly: periodicity = dependencies.stringLoader.getString("summary_label_monthly").text
            case .quarterly: periodicity = dependencies.stringLoader.getString("summary_label_quarterly").text
            case .biannual: periodicity = dependencies.stringLoader.getString("summary_label_sixMonthly").text
            case .weekly: periodicity = dependencies.stringLoader.getString("summary_label_weekly").text
            case .bimonthly: periodicity = dependencies.stringLoader.getString("summary_label_bimonthly").text
            case .annual: periodicity = dependencies.stringLoader.getString("summary_label_annual").text
            }
        case .now?:
            periodicity = dependencies.stringLoader.getString("summary_label_timely").text
        default:
            periodicity = dependencies.stringLoader.getString("summary_label_standar").text
        }
        return periodicity
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        trackSummaryState()
        if getSummaryState() == .success {
            let summary: OnePaySummaryInfo?
            let parameter: OnePayTransferOperativeData = containerParameter()
            switch parameter.type {
            case .national?, .sepa?:
                summary = OnePaySepaSummaryInfo(operativeData: parameter, dependencies: dependencies)
            case .noSepa?:
                summary = OnePayNoSepaSummaryInfo(operativeData: containerParameter(), dependencies: dependencies)
            default:
                summary = nil
            }
            return summary?.info() ?? []
        } else {
            return []
        }
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    func getSummaryState() -> OperativeSummaryState {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.summaryState {
        case .success?: return .success
        case .pending?: return .pending
        case .error?: return .error
        case .none: return .error
        }
    }
    
    // MARK: - Tracker
    
    var screenIdProductSelection: String? {
        return TrackerPagePrivate.TransferOriginAccountSelection().page
    }
    
    var screenIdSignature: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.NationalTransferSignature().page
        case .sepa?: return TrackerPagePrivate.InternationalTransferSignature().page
        case .noSepa?: return TrackerPagePrivate.NoSepaTransferSignature().page
        default: return nil
        }
    }
    
    var screenIdSummary: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.NationalTransferSummary().page
        case .sepa?: return TrackerPagePrivate.InternationalTransferSummary().page
        case .noSepa?: return TrackerPagePrivate.NoSepaTransferSummary().page
        default: return nil
        }
    }
    
    var screenIdOtp: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.NationalTransferOTP().page
        case .sepa?: return TrackerPagePrivate.InternationalTransferOTP().page
        case .noSepa?: return TrackerPagePrivate.NoSepaTransferOTP().page
        default: return nil
        }
    }
    
    private func typeOnePayTransferParameters() -> [String: String]? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?:
            return [
                TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? "",
                TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? ""
            ]
        case .sepa?:
            return [
                TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? ""
            ]
        default: return nil
        }
    }
    
    var extraParametersForTrackerError: [String: String]? {
        return typeOnePayTransferParameters()
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        guard let amount = operativeData.amount else {
            return nil
        }
        let parameters: [String: String] = typeOnePayTransferParameters() ?? [:]
        var summaryParameters = [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
        for (key, value) in parameters {
            summaryParameters[key] = value
        }
        return summaryParameters
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return typeOnePayTransferParameters()
    }
    
    func getTrackParametersOTP() -> [String: String]? {
        return typeOnePayTransferParameters()
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return typeOnePayTransferParameters()
    }
    
    func trackSummaryState() {
        let summaryState = getSummaryState()
        switch summaryState {
        case .pending:
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.NationalTransferImmediateSummaryPending().page, extraParameters: [:])
        case .error:
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.NationalTransferImmediateSummaryKO().page, extraParameters: [:])
        case .success:
            break
        }
    }
    
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? nil
        return faqModel
    }
    
    private func getCommissonValue() -> (key: String, value: PDFStringConvertible?) {
        if let hideCommission = self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.hideSummaryCommissions,
           hideCommission {
            return (key: "summary_item_commission", value: nil)
        }
        let parameter: OnePayTransferOperativeData = containerParameter()
        return (key: "summary_item_commission", value: parameter.transferNational?.bankChargeAmount ?? parameter.scheduledTransfer?.bankChargeAmount)
    }
}

extension OnePayTransferOperative: SCACapable {}

extension OnePayTransferOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: Signature) {
        guard let factory = self.stepFactory else { return }
        self.container?.saveParameter(parameter: signature)
        self.add(step: factory.createStep() as OperativeSimpleSignature)
    }
}

extension OnePayTransferOperative: SCAOTPCapable {
    func prepareForOTP(_ otp: OTP?) {
        guard let factory = self.stepFactory else { return }
        if let otp = otp {
            self.container?.saveParameter(parameter: otp)
        }
        self.add(step: factory.createStep() as OperativeOTP)
    }
}

struct OnePayAccountSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.onePayTransferAccountSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayTransferSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.onePayTransferSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayTransferDestinationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.onePayTransferDestinationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayTransferConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.onePayTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayNoSepaTransferConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.onePayNoSepaTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayTransferSubtypeSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.onePayTransferSelectorSubtypePresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayNoSepaTransferSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.noSepaTransferDestinationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayNoSepaTransferSelectorDetailStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.noSepaTransferDestinationDetailPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayNoSepaTransferSummaryStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = false
    var showsCancel: Bool = false
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.noSepaTransferSummaryPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OnePayTransferLisboaSummaryStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = false
    var showsCancel: Bool = false
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        presenterProvider.onePayTransferLisboaSummaryPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
