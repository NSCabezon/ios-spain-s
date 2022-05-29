import Foundation
import CoreFoundationLib

class BillsAndTaxesConfirmationPresenter: OperativeStepPresenter<BillsAndTaxesConfirmationViewController, VoidNavigator, BillsAndTaxesConfirmationPresenterProtocol> {
    private var checkModel: CheckViewModel?
    
    override var screenId: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills: return TrackerPagePrivate.BillAndTaxesPayBillConfirm().page
        case .taxes: return TrackerPagePrivate.BillAndTaxesPayTaxConfirm().page
        }
    }
    
    // MARK: - Overrided methods
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("genericToolbar_title_confirmation")
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let paymentBillTaxes: PaymentBillTaxes = parameter.paymentBillTaxes, let type = parameter.typeOperative else { return }
        
        // Add account section
        let accountSection = TableModelViewSection()
        addAccount(paymentBillTaxes.originAccount, to: accountSection)
        
        // Add confirmation items
        let confirmationSection = TableModelViewSection()
        addConfirmation(of: paymentBillTaxes, to: confirmationSection)
        
        //Add check
        let checkSection = TableModelViewSection()
        var titleCheck: String
        switch type {
        case .bills:
            titleCheck = "confirmation_item_domicilePaymentReceipts"
            view.localizedSubTitleKey = "toolbar_title_payReceipts"
        case .taxes:
            titleCheck = "confirmation_item_domicilePaymentTaxes"
            view.localizedSubTitleKey = "toolbar_title_taxPayment"
        }
        checkModel = CheckViewModel(dependencies: dependencies, title: stringLoader.getString(titleCheck), isSelected: false)
        guard let checkModelViewCell = checkModel else { return }
        checkSection.add(item: checkModelViewCell)
        
        self.view.sections = [accountSection, confirmationSection, checkSection]
    }
    
    // MARK: - Private methods
    
    private func addAccount(_ account: Account, to accountSection: TableModelViewSection) {
        let accountItem = AccountConfirmationViewModel(
            accountName: account.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text,
            ibanNumber: account.getIBANShort(),
            amount: account.getAmountUI(),
            privateComponent: dependencies
        )
        let accountTitle = TitledTableModelViewHeader()
        accountTitle.title = stringLoader.getString("deliveryDetails_label_originAccount")
        accountSection.setHeader(modelViewHeader: accountTitle)
        accountSection.add(item: accountItem)
    }
    
    private func addConfirmation(of paymentBillTaxes: PaymentBillTaxes, to confirmationSection: TableModelViewSection) {
        let title = TitledTableModelViewHeader()
        
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let paymentBillTaxes: PaymentBillTaxes = parameter.paymentBillTaxes, let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            title.title = stringLoader.getString("confirmation_label_payReceipts")
        case .taxes:
            title.title = stringLoader.getString("confirmation_label_payTaxes")
        }    
        confirmationSection.setHeader(modelViewHeader: title)
        
        let confirmationHeader = ConfirmationTableViewHeaderModel((paymentBillTaxes.amount).getFormattedAmountUI(), dependencies)
        confirmationSection.items.append(confirmationHeader)
        
        let items = [
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_issuingEntity"), paymentBillTaxes.issuingDescription, false, dependencies),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_codeIssuingEntity"), paymentBillTaxes.codeEntity, false, dependencies),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_reference"), paymentBillTaxes.reference, false, dependencies),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_identification"), paymentBillTaxes.id, true, dependencies)
        ]
        confirmationSection.addAll(items: items)
    }
}

extension BillsAndTaxesConfirmationPresenter: BillsAndTaxesConfirmationPresenterProtocol {
    
    var continueTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_confirm")
    }
    
    func next() {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let paymentBillTaxes: PaymentBillTaxes = parameter.paymentBillTaxes, let check = checkModel?.isSelected else { return }
        
        let validateData = ValidateBillsAndTaxesUseCaseInput(
            account: paymentBillTaxes.originAccount,
            directDebit: check,
            amount: paymentBillTaxes.amount)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getValidateBillsAndTaxesUseCase(input: validateData),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings {
                    guard let strongSelf = self else { return }
                    let parameter: BillAndTaxesOperativeData = strongSelf.containerParameter()
                    parameter.directDebit = check
                    strongSelf.container?.saveParameter(parameter: parameter)
                    strongSelf.container?.saveParameter(parameter: response.signatureWithToken)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings {
                    guard let strongSelf = self else { return }
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                }
            }
        )
    }
    
    func didTapFaqs() {
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        let faqs = operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.BillAndTaxesFaq().page, extraParameters: [:])
        self.view.showFaqs(faqs)
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .billsFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}
