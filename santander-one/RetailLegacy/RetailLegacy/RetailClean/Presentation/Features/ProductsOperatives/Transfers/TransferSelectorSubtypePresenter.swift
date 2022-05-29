import Foundation
import CoreFoundationLib
import Transfer
import SANLegacyLibrary
import TransferOperatives

class TransferSelectorSubtypePresenter<T: SubtypeTransferOperativeData, UseCaseInput: SubtypeTransferUseCaseInput, UseCaseOkOutput, Navigator>: OperativeStepPresenter<TransferSelectorSubtypeViewController, Navigator, TransferSelectorSubtypePresenterProtocol> {
    
    weak var subTypeView: TransferSubTypeSelectorViewProtocol?
    var subTypes: [TransferSubTypeItemViewModel] = []
    var selectedSubType: TransferSubTypeItemViewModel? {
        self.subTypes.first(where: { $0.isSelected })
    }
    
    private lazy var transferSubTypeSelectorModifierProtocol = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: TransferSubTypeSelectorModifierProtocol.self)
    
    struct CommissionDescription {
        let comissionStandard: String?
        let comissionInmediate: String?
        let comissionUrgent: String?
    }

    func proccessResponse(parameter: T, response: UseCaseOkOutput) {
        //Se usa en las clases hijas
    }

    func getUseCase(subtype: OnePayTransferSubType, parameter: T) -> UseCase<UseCaseInput, UseCaseOkOutput, SubtypeTransferUseCaseErrorOutput>? {
        //Se usa en las clases hijas
        return nil
    }
    
    func showError(error: SubtypeTransferError?) {
        switch error {
        case .maxAmount?:
            let parameter: T = containerParameter()
            let text = dependencies.stringLoader.getString("immediateOnePay_alert_important", [StringPlaceholder(StringPlaceholder.Placeholder.value, parameter.maxImmediateNationalAmount?.getFormattedAmountUI() ?? "")])
            let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: nil)
            Dialog.alert(title: localized(key: "immediateOnePay_alert_title_important"), body: text, withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view, shouldTriggerHaptic: true)
        case .urgentNationalTransfers5304(let text)?:
            let text = LocalizedStylableText(text: text ?? "", styles: nil)
            let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_continue"), does: { [weak self] in
                self?.selectedSubType(.standard)
            })
            let cancelComponents = DialogButtonComponents(titled: localized(key: "generic_button_cancel"), does: nil)
            Dialog.alert(title: localized(key: "sendMoney_alert_title_importantNotice"), body: text, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: view, shouldTriggerHaptic: true)
        case .nonAttachedEntity?:
            showError(keyTitle: "immediateOnePay_alert_title_accountsDestination", keyDesc: "immediateOnePay_alert_label_accountsDestination")
        case .serviceError(let errorDesc):
            showError(keyDesc: errorDesc)
        case .noConnection:
            showError(keyDesc: "generic_error_internetConnection")
        case .none:
            showError(keyDesc: nil)
        }
    }
    
    private func isImmediateEnabled() -> Bool {
        let parameter: T = containerParameter()
        guard let maxAmount = parameter.maxImmediateNationalAmount?.value, let amount = parameter.amount?.value else {
            return true
        }
        return maxAmount >= amount
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        let parameter: T = containerParameter()
        guard let type = parameter.type, let time = parameter.time else {
            return onSuccess(false)
        }
        switch type {
        case .national:
            switch time {
            case .now:
                onSuccess(true)
            case .periodic:
                guard let onePaytransferModifierProtocol = dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
                    onSuccess(false)
                    return
                }
                onSuccess(onePaytransferModifierProtocol.showSpecialPricesForPeriodicTransfers)
            case .day:
                guard let onePaytransferModifierProtocol = dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
                    onSuccess(false)
                    return
                }
                onSuccess(onePaytransferModifierProtocol.showSpecialPricesForDateTransfers)
            }
        case .sepa, .noSepa:
            onSuccess(false)
        }
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
}

extension TransferSelectorSubtypePresenter: TransferSelectorSubtypePresenterProtocol {
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapFaqs() {
        let parameter: T = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.TransferFaqs().page, extraParameters: [:])
        self.view.showFaqs(faqModel)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}

extension TransferSelectorSubtypePresenter: TransferSubTypeSelectorPresenterProtocol {
    
    func didSelectContinue() {
        let parameter: T = containerParameter()
        let subType = parameter.subType ?? .standard
        if dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isEnabledSimulationTransfer == false, parameter.time != .now {
            self.processOkResponse(subtype: subType, response: nil)
        } else {
            guard let usecase = getUseCase(subtype: subType, parameter: parameter) else {
                return
            }
            showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil, completion: { [weak self] in
                guard let strongSelf = self else { return }
                UseCaseWrapper( with: usecase,
                                useCaseHandler: strongSelf.dependencies.useCaseHandler,
                                errorHandler: strongSelf.genericErrorHandler,
                                onSuccess: { [weak self] response in
                    self?.hideAllLoadings { [weak self] in
                        self?.processOkResponse(subtype: subType, response: response)
                    }
                }, onError: { [weak self] error in
                    self?.hideAllLoadings { [weak self] in
                        self?.showError(error: error?.error)
                    }
                })
            })
        }
    }
    
    func viewDidAppear() {
        guard self.subTypes.isEmpty else { return }
        self.loadCommissions()
    }
    
    func didSelectSubType(_ viewModel: TransferSubTypeItemViewModel) {
        guard let currentSelected = self.selectedSubType, viewModel != currentSelected else { return }
        self.subTypes = self.subTypes.map {
            switch $0 {
            case currentSelected: return TransferSubTypeItemViewModel(from: $0, isSelected: false)
            case viewModel: return TransferSubTypeItemViewModel(from: $0, isSelected: true)
            default: return TransferSubTypeItemViewModel(from: $0, isSelected: false)
            }
        }
        self.subTypes.forEach({ self.subTypeView?.update($0) })
        self.getSelected()
    }
    
    func didSelectHireTransferPackage() {
        transferSubTypeSelectorModifierProtocol?.goToHireTransferPackage()
    }
}

private extension TransferSelectorSubtypePresenter {
        
    func loadCommissions() {

        let parameter: T = containerParameter()
        guard
            let originAccount = parameter.account?.accountEntity,
            let destinationAccount = parameter.iban?.entity,
            let amount = parameter.amount?.entity
        else {
            return
        }
        self.subTypeView?.showLoading()
        let input = TransferSubTypeCommissionsUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            beneficiary: parameter.beneficiary ?? "",
            concept: parameter.concept ?? ""
        )
        UseCaseWrapper(
            with: self.dependencies.useCaseProvider.getSubTypeTransferCommissions(input: input),
            useCaseHandler: self.dependencies.useCaseHandler,
            errorHandler: self.genericErrorHandler,
            onSuccess: { [weak self] result in
                let commissionDescription = CommissionDescription(comissionStandard: result.comissionStandard, comissionInmediate: result.commissionInmediate, comissionUrgent: result.commissionUrgent)
                self?.subTypeView?.dismissLoading {
                    if result.commissions.count > 0 {
                        self?.view.showCommissions()
                    } else {
                        self?.view.hideCommissions()
                    }
                    self?.showSubTypes(withCommissions: result.commissions, taxes: result.taxes ?? [:], total: result.total ?? [:], commissionDescription: commissionDescription, isUrgentTypeDisabled: result.isUrgentTypeDisabled, transferPackage: result.transferPackage ?? [:])
                }
            },
            onGenericErrorType: { [weak self] _ in
                self?.view.hideCommissions()
        }
        )
    }
    
    func getTooltipInstant(commissions: [TransferSubType: AmountEntity?], taxes: [TransferSubType: AmountEntity?], isEnabledShowTaxTooltip: Bool) -> (String?, String?) {
        let parameter: T = containerParameter()
        var taxInstant: String?
        var comissionInstant: String?
        if let instantComissionValue = commissions[.instant], isEnabledShowTaxTooltip == true {
            comissionInstant = instantComissionValue?.getFormattedValue()
        } else {
            comissionInstant = AmountEntity(value: parameter.maxImmediateNationalAmount?.value ?? 0)
                .getFormattedValueOrEmptyUI(withDecimals: 2,truncateDecimalIfZero: true)
        }
        if let standardTaxValue = taxes[.instant] {
            taxInstant = standardTaxValue?.getFormattedValue()
        }
        return (comissionInstant, taxInstant)
    }
    
    func getTooltipStandard(commissions: [TransferSubType: AmountEntity?], taxes: [TransferSubType: AmountEntity?]) -> (String?, String?) {
        var taxStandard: String?
        var comissionStandard: String?
        if let standardComissionValue = commissions[.standard] {
            comissionStandard = standardComissionValue?.getFormattedValue()
        }
        if let standardTaxValue = taxes[.standard] {
            taxStandard = standardTaxValue?.getFormattedValue()
        }
        return (comissionStandard, taxStandard)
    }
    
    func showSubTypes(withCommissions commissions: [TransferSubType: AmountEntity?], taxes: [TransferSubType: AmountEntity?], total: [TransferSubType: AmountEntity?], commissionDescription: CommissionDescription, isUrgentTypeDisabled: Bool, transferPackage: [TransferSubType: TransferPackage?]) {
        let parameter: T = containerParameter()
        var subtype = parameter.subType ?? .standard
        if commissions[.instant] == nil {
            subtype = .standard
        }
        let onePaytransferModifierProtocol = dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)
        var isEnabledUrgentType: Bool = false
        if isUrgentTypeDisabled == false && onePaytransferModifierProtocol?.isDisabledUrgentType ?? false == false {
            isEnabledUrgentType = true
        }
        let tooltipInstantValue = getTooltipInstant(commissions: commissions, taxes: taxes, isEnabledShowTaxTooltip: onePaytransferModifierProtocol?.isEnabledShowTaxTooltip ?? false)
        let tooltipStandardValue = getTooltipStandard(commissions: commissions, taxes: taxes)
        let standard = TransferSubTypeItemViewModel(type: .standard, localizedInfo: localized(key: "sendType_tooltip_standar", stringPlaceHolder: [StringPlaceholder(StringPlaceholder.Placeholder.value, tooltipStandardValue.0 ?? ""), StringPlaceholder(StringPlaceholder.Placeholder.value, tooltipStandardValue.1 ?? "")]), description: "sendType_text_standar", commission: total[.standard] ?? commissions[.standard] ?? nil, isSelected: self.isSelected(selectedType: subtype, type: .standard), commissionDescription: commissionDescription.comissionStandard ?? "")
        let immediate = TransferSubTypeItemViewModel(type: .instant, localizedInfo: localized(key: "sendType_tooltip_inmediate", stringPlaceHolder: [StringPlaceholder(StringPlaceholder.Placeholder.value, tooltipInstantValue.0 ?? ""), StringPlaceholder(StringPlaceholder.Placeholder.value, tooltipInstantValue.1 ?? "")]), description: "sendType_text_inmediate", commission: total[.instant] ?? commissions[.instant] ?? nil, isSelected: self.isSelected(selectedType: subtype, type: .instant), commissionDescription: commissionDescription.comissionInmediate ?? "")
        let urgent = TransferSubTypeItemViewModel(type: .urgent, info: "sendType_tooltip_express", description: "sendType_text_express", commission: commissions[.urgent] ?? nil, isSelected: self.isSelected(selectedType: subtype, type: .urgent), commissionDescription: commissionDescription.comissionUrgent ?? "")
        if dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self) != nil {
            self.subTypes.append(standard)
            self.addImmediateType(immediate: immediate, comission: commissions[.instant] ?? nil)
        } else {
            self.addImmediateType(immediate: immediate, comission: commissions[.instant] ?? nil)
            self.subTypes.append(standard)
        }
        if isEnabledUrgentType  {
            self.subTypes.append(urgent)
        }
        let isEnabledDisclaimer = onePaytransferModifierProtocol?.isEnabledDisclaimerCommissionsText
        if isEnabledDisclaimer == false {
            self.view.hideCommissions()
        }
        self.subTypeView?.showTransferSubTypes(types: self.subTypes, addDisclaimerView: isEnabledDisclaimer ?? true)
        if let package = transferPackage[.instant] ?? nil {
            self.addTransferPackageView(package)
        } else {
            guard let transferSubTypeSelectorModifierProtocol = dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: TransferSubTypeSelectorModifierProtocol.self) else { return }
            if transferSubTypeSelectorModifierProtocol.isEnabledHireTransferPackage {
                self.addHireTransferPackageView()
            }
        }
    }
    
    func addTransferPackageView(_ package: TransferPackage) {
        let parameter: T = containerParameter()
        let transferTime = self.getTransferTime(parameter.time)
        let timeManager = dependencies.navigatorProvider.dependenciesEngine.resolve(for: TimeManager.self)
        let expirationDate = timeManager.toString(input: package.expirationDate, inputFormat: TimeFormat.yyyy_MM_dd, outputFormat: TimeFormat.d_MMM_yyyy) ?? ""
        let viewModel = TransferPackageViewModel(numberTransfers: package.numberTransfers, remainingTransfers: package.remainingTransfers, packageName: package.packageName, expirationDate: expirationDate, transferTime: transferTime)
        self.view.addPackageTransfer(transferPackage: viewModel)
    }
    
    func addHireTransferPackageView() {
        self.view.addHireTransferPackage()
    }
    
    func addImmediateType(immediate: TransferSubTypeItemViewModel, comission: AmountEntity?) {
        guard let onePaytransferModifierProtocol = dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            self.appendImmediate(immediate)
            return
        }
        if onePaytransferModifierProtocol.isImmediateEnabled(comission) {
            self.subTypes.append(immediate)
        }
    }
    
    func appendImmediate(_ immediate: TransferSubTypeItemViewModel) {
        if self.isImmediateEnabled() {
            self.subTypes.append(immediate)
        }
    }
    
    func selectedSubType(_ subtype: OnePayTransferSubType) {
        let parameter: T = containerParameter()
        guard let usecase = getUseCase(subtype: subtype, parameter: parameter) else {
            return
        }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil, completion: { [weak self] in
            guard let strongSelf = self else { return }
            UseCaseWrapper( with: usecase, useCaseHandler: strongSelf.dependencies.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    self?.processOkResponse(subtype: subtype, response: response)
                }
            }, onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    self?.showError(error: error?.error)
                }
            })
        })
    }
    
    func processOkResponse(subtype: OnePayTransferSubType, response: UseCaseOkOutput?) {
        var parameter: T = containerParameter()
        if let useCaseResponse = response {
            proccessResponse(parameter: parameter, response: useCaseResponse)
        } else {
            manageCommissions(&parameter)
        }
        parameter.subType = subtype
        container?.saveParameter(parameter: parameter)
        container?.stepFinished(presenter: self)
    }
    
    func manageCommissions(_ parameter: inout T) {
        if let showCommissions = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.showCostsForStandingOrders,
           showCommissions,
           let commission = self.selectedSubType?.commissionEntity?.dto {
            parameter.commission = Amount.createFromDTO(commission)
        }
    }
    
    func getSelected() {
        let subtype: OnePayTransferSubType = {
            switch self.selectedSubType?.typeValue {
            case .urgent?: return .urgent
            case .instant?: return .immediate
            case .standard?: return .standard
            case .none: return .standard
            }
        }()
        var parameter: T = containerParameter()
        parameter.subType = subtype
        container?.saveParameter(parameter: parameter)
    }
    
    func isSelected (selectedType: OnePayTransferSubType, type: TransferSubType) -> Bool {
        if selectedType.string == type.string {
            return true
        } else {
            return false
        }
    }
    
    func getTransferTime(_ onePayTransferTime: OnePayTransferTime?) -> TransferTime {
        switch onePayTransferTime {
        case .now, .none:
            return .now
        case .day:
            return .defaultDay
        case .periodic:
            return .defaultPeriodic
        }
    }
}
