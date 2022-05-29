import Foundation
import CoreFoundationLib

class ReemittedNoSepaTransferOperative: Operative {
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Operative
    
    var isShareable: Bool {
        return getSummaryState() == .success
    }
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var opinatorPage: OpinatorPage? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.operativeOrigin {
        case .emittedTransfer:
            return .noSepaReemittedTransfer
        case .favorite:
            return .noSepaUsualTransfer
        }
    }
    
    var screenIdProductSelection: String? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.operativeOrigin {
        case .emittedTransfer:
            return TrackerPagePrivate.NoSepaReemittedTransfer().accountSelectionPage
        case .favorite:
            return TrackerPagePrivate.NoSepaUsualTransfer().accountSelectionPage
        }
    }
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    var pdfTitle: String? {
        return "toolbar_title_detailOnePay"
    }
    
    var pdfContent: String? {
        if getSummaryState() == .success {
            let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
            let builder = TransferPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
            guard
                let originAccount = parameter.productSelected,
                let destinationAccount = parameter.beneficiaryAccount?.account
                else {
                    return nil
            }
            let shortDestinationAccount = destinationAccount.asterisk()
            builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: parameter.date)
            builder.addAccounts(originAccountAlias: originAccount.getAlias() ?? "",
                                originAccountIBAN: originAccount.getAsteriskIban(),
                                destinationAccountAlias: parameter.transferDetail.payee?.name ?? "",
                                destinationAccountIBAN: shortDestinationAccount)
            
            let concept: String
            if let transferConcept = parameter.concept, !transferConcept.isEmpty {
                concept = transferConcept
            } else {
                concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
            }
            builder.addTransferInfo([
                (key: "summary_item_destinationCountry", value: parameter.selectedCountry?.name.capitalized),
                (key: "summary_label_bicSwift", value: parameter.beneficiaryAccount?.bicSwift),
                (key: "summary_item_nameBank", value: parameter.beneficiaryAccount?.bankName),
                (key: "summary_item_amount", value: parameter.noSepaTransferValidation?.settlementAmountBenef?.getAbsFormattedAmountUI()),
                (key: "summary_item_concept", value: concept),
                (key: "summary_item_periodicity", value: dependencies.stringLoader.getString("summary_label_timely").text),
                (key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.date, outputFormat: .dd_MMM_yyyy))
                ])
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
        return nil
    }
    
    private func expensesKey() -> String {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.transferExpenses {
        case .shared?:
            return "summary_item_sharedExpenses"
        case .payer?:
            return "summary_item_payerExpenses"
        case .beneficiary?:
            return "summary_item_beneficiaryExpenses"
        case .none:
            return ""
        }
    }
    
    func getRichSharingText() -> String? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        guard
            let originAccount = parameter.productSelected,
            let destinationAccount = parameter.beneficiaryAccount?.account,
            let payer = parameter.payer
        else {
            return nil
        }
        let builder = TransferEmailBuilder(stringLoader: dependencies.stringLoader)
        let concept: String
        if let transferConcept = parameter.concept, !transferConcept.isEmpty {
            concept = transferConcept
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer", [StringPlaceholder(.name, payer), StringPlaceholder(.value, destinationAccount.asterisk()), StringPlaceholder(.value, concept)]).text)
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer_withoutConcept", [StringPlaceholder(.name, payer), StringPlaceholder(.value, destinationAccount.asterisk())]).text)
        }
        builder.addTransferInfo([
            EmailInfo(key: "summary_item_payer", value: payer, detail: originAccount.getAsteriskIban()),
            EmailInfo(key: "summary_item_beneficiary", value: parameter.transferDetail.payee?.name, detail: destinationAccount.asterisk()),
            EmailInfo(key: "summary_label_destinationCountryToPayement", value: parameter.selectedCountry?.name.capitalized, detail: nil),
            EmailInfo(key: "summary_label_bicSwift", value: parameter.beneficiaryAccount?.bicSwift, detail: nil),
            EmailInfo(key: "summary_item_nameBank", value: parameter.beneficiaryAccount?.bankName, detail: nil),
            EmailInfo(key: "newSendOnePay_label_amount", value: parameter.noSepaTransferValidation?.settlementAmountBenef?.getAbsFormattedAmountUI(), detail: nil),
            EmailInfo(key: "summary_item_concept", value: concept, detail: nil),
            EmailInfo(key: "summary_item_periodicity", value: dependencies.stringLoader.getString("summary_label_timely").text, detail: nil),
            EmailInfo(key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.date, outputFormat: .dd_MMM_yyyy), detail: nil),
            EmailInfo(key: "summary_item_swiftExpenses", value: parameter.noSepaTransferValidation?.swiftExpenses, detail: nil),
            EmailInfo(key: "summary_item_mailExpenses", value: parameter.noSepaTransferValidation?.mailExpenses, detail: nil),
            EmailInfo(key: "summary_label_totalExpenses", value: parameter.noSepaTransferValidation?.impTotComComp, detail: nil),
            EmailInfo(key: "summary_label_payerAmountToDebt", value: parameter.noSepaTransferValidation?.settlementAmountPayer, detail: nil),
            EmailInfo(key: "summary_label_amountBeneficiaryPay", value: parameter.noSepaTransferValidation?.settlementAmountBenef, detail: nil)
            ])
        return builder.build()
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let parameter: ReemittedNoSepaTransferOperativeData = container.provideParameter()
        let input = PreSetupOnePayTransferCardUseCaseInput(account: parameter.productSelected)
        let usecase = dependencies.useCaseProvider.getPreSetupOnePayTransferCardUseCase().setRequestValues(requestValues: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            let operativeData: ReemittedNoSepaTransferOperativeData = container.provideParameter()
            operativeData.updatePre(accounts: result.accountVisibles, sepaInfo: result.sepaList)
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { _ in
            completion(false, (title: nil, message: "deeplink_alert_errorSend"))
        })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let parameter: ReemittedNoSepaTransferOperativeData = container.provideParameter()
        let input = SetupReemittedNoSepaTransferCardUseCaseInput(transferDetail: parameter.transferDetail)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getSetupReemittedNoSepaTransferCardUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                parameter.isDestinationSepaAccount = result.isDestinationSepaAccount
                parameter.sepaInfoList = result.sepaList
                container.saveParameter(parameter: result.operativeConfig)
                container.saveParameter(parameter: parameter)
                success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        }
        )
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let operativeData: ReemittedNoSepaTransferOperativeData = containerParameter()
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        let address = Address(country: operativeData.transferDetail.countryName ?? "", address: operativeData.transferDetail.payee?.address, locality: operativeData.transferDetail.payee?.town)
        guard let beneficiary = operativeData.transferDetail.payee?.name, let noSepaTransferValidation = operativeData.noSepaTransferValidation, let transferAmount = operativeData.amount, let beneficiaryAccount = operativeData.beneficiaryAccount, let transferExpenses = operativeData.transferExpenses, let originAccount = operativeData.productSelected else { return }
        let input = ConfirmNoSepaTransferUseCaseInput(
            signature: signatureFilled.signature,
            originAccount: originAccount,
            beneficiary: beneficiary,
            beneficiaryAccount: beneficiaryAccount,
            beneficiaryAddress: address,
            dateOperation: Date(),
            transferAmount: transferAmount,
            expensiveIndicator: transferExpenses,
            countryCode: operativeData.transferDetail.destinationCountryCode ?? "",
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
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let operativeData: ReemittedNoSepaTransferOperativeData = containerParameter()
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        let otpCode = otpFilled.value
        let otpValidation: OTPValidation
        if let validation = otpFilled.validation {
            otpValidation = validation
        } else {
            switch otp {
            case .userExcepted(let innerValidation):
                otpValidation = innerValidation
            case .validation(let innerValidation):
                otpValidation = innerValidation
            }
        }
        let address = Address(country: operativeData.transferDetail.countryName ?? "", address: operativeData.transferDetail.payee?.address, locality: operativeData.transferDetail.payee?.town)
        guard
            let beneficiary = operativeData.transferDetail.payee?.name,
            let noSepaTransferValidation = operativeData.noSepaTransferValidation,
            let transferAmount = operativeData.amount,
            let beneficiaryAccount = operativeData.beneficiaryAccount,
            let transferExpenses = operativeData.transferExpenses,
            let swiftValidation = operativeData.swiftValidation,
            let originAccount = operativeData.productSelected else { return }
        let input = ConfirmNoSepaTransferOTPUseCaseInput(
            originAccount: originAccount,
            beneficiary: beneficiary,
            beneficiaryAccount: beneficiaryAccount,
            beneficiaryAddress: address,
            dateOperation: Date(),
            transferAmount: transferAmount,
            expensiveIndicator: transferExpenses,
            countryCode: operativeData.transferDetail.destinationCountryCode ?? "",
            concept: operativeData.concept ?? "",
            noSepaTransferValidation: noSepaTransferValidation,
            swiftValidation: swiftValidation,
            otpValidation: otpValidation,
            otpCode: otpCode ?? "",
            beneficiaryEmail: operativeData.beneficiaryEmail ?? "",
            aliasPayee: "",
            isNewPayee: false
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmNoSepaTransferOTPUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { response in
                let parameter: ReemittedNoSepaTransferOperativeData = self.containerParameter()
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
    
    func getSummaryTitle() -> LocalizedStylableText {
        switch getSummaryState() {
        case .success:
            return dependencies.stringLoader.getString("summary_title_standardOnePay")
        case .error:
            return dependencies.stringLoader.getString("onePay_title_transferFailed")
        default:
            return .empty
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        switch getSummaryState() {
        case .success:
            return dependencies.stringLoader.getString("summary_subtitle_timeDelivery")
        case .error:
            return dependencies.stringLoader.getString("onePay_label_errorFailedNoSepa")
        default:
            return nil
        }
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        if getSummaryState() == .success {
            return OnePayNoSepaReemittedSummary(operativeData: containerParameter(), dependencies: dependencies).info()
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
    
    private func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Account.self)
        add(step: factory.createStep() as ReemittedNoSepaTransferAccountStep)
        add(step: factory.createStep() as ReemittedNoSepaTransferConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func getSummaryState() -> OperativeSummaryState {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.summaryState {
        case .success?: return .success
        case .pending?: return .pending
        case .error?: return .error
        case .none: return .error
        }
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.operativeOrigin {
        case .emittedTransfer:
            return TrackerPagePrivate.NoSepaReemittedTransfer().signaturePage
        case .favorite:
            return TrackerPagePrivate.NoSepaUsualTransfer().signaturePage
        }
    }
    
    var screenIdOtp: String? {
        return TrackerPagePrivate.NoSepaReemittedTransfer().otpPage
    }
    
    var screenIdSummary: String? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.operativeOrigin {
        case .emittedTransfer:
            return TrackerPagePrivate.NoSepaReemittedTransfer().summaryPage
        case .favorite:
            return TrackerPagePrivate.NoSepaUsualTransfer().summaryPage
        }
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return nil
    }
    
    func getTrackParametersOTP() -> [String: String]? {
        return nil
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        let data: ReemittedNoSepaTransferOperativeData = containerParameter()
        guard let amount = data.amount else { return nil }
        
        return [
            TrackerDimensions.amount: amount.getTrackerFormattedValue(),
            TrackerDimensions.currency: amount.currency?.currencyName ?? ""
        ]
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return nil
    }
    
    var extraParametersForTrackerError: [String: String]? {
       return nil
    }
    
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? nil
        return faqModel
    }
}

struct ReemittedNoSepaTransferAccountStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.reemittedNoSepaTransferAccountPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ReemittedNoSepaTransferConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.reemittedNoSepaTransferConfirmattionPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
