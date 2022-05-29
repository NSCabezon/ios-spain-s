import Foundation

class CancelDirectBillingConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: CancelDirectBillingOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.CancelDirectBillingConfirmation().page
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        view.updateButton(title: stringLoader.getString("generic_button_continue"))
        self.view.sections = [
            accountSection(),
            billSection(),
            footerSection()
        ]
    }
    
    // MARK: - Private methods
    
    private func accountSection() -> TableModelViewSection {
        guard let account = operativeData.account else { return TableModelViewSection() }
        let accountSection = TableModelViewSection()
        let accountItem = AccountConfirmationViewModel(
            accountName: account.getAliasUpperCase(),
            ibanNumber: account.getIBANShort(),
            amount: account.getAmountUI(),
            privateComponent: dependencies)
        let accountHeader = DetailTitleHeaderViewModel(title: stringLoader.getString("cancelReceipt_label_domiciliationAccount").uppercased(), color: .opaque)
        accountSection.setHeader(modelViewHeader: accountHeader)
        accountSection.add(item: accountItem)
        return accountSection
    }
    
    private func billSection() -> TableModelViewSection {
        let confirmationSection = TableModelViewSection()
        let header = DetailTitleHeaderViewModel(title: stringLoader.getString("cancelReceipt_label_dataReceipt").uppercased(), color: .opaque)
        confirmationSection.setHeader(modelViewHeader: header)
        let bill = operativeData.bill
        let billDetail = operativeData.billDetail
        
        let confirmationHeader = ConfirmationHeaderViewModel(dependencies: dependencies, amount: bill.amountWithSymbol.getFormattedAmountUI(), concept: bill.name.camelCasedString)
        confirmationSection.add(item: confirmationHeader)
        // TODO:- Check parameters with final BillDO and BillDTO.
        let items: [DetailItemViewModel] = [
            DetailItemViewModel(stringLoader.getString("confirmation_item_date"), info: dependencies.timeManager.toString(date: bill.expirationDate, outputFormat: .dd_MMM_yyyy), isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: nil, dependencies, shareDelegate: nil),
            DetailItemViewModel(stringLoader.getString("confirmation_item_holder"), info: bill.holder.camelCasedString, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: nil, dependencies, shareDelegate: nil),
            DetailItemViewModel(stringLoader.getString("confirmation_item_issuingEntity"), info: bill.name.camelCasedString, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: nil, dependencies, shareDelegate: nil),
            DetailItemViewModel(stringLoader.getString("confirmation_item_codeIssuingEntity"), info: bill.issuerCode, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: nil, dependencies, shareDelegate: nil),
            DetailItemViewModel(stringLoader.getString("confirmation_item_authorisationReference"), info: billDetail.mandateReference, isFirst: false, isLast: true, isCopyEnabled: false, toolTipDisplayer: nil, dependencies, shareDelegate: nil)
            ]
        confirmationSection.addAll(items: items)
        return confirmationSection
    }
    
    private func footerSection() -> TableModelViewSection {
        let section = TableModelViewSection()
        let infoLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("confirmation_text_infCancelReceipt"), style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .center), insets: Insets(left: 33, right: 47, top: 23, bottom: 23), privateComponent: dependencies)
        section.items.append(infoLabelModel)
        return section
    }
}

extension CancelDirectBillingConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    var infoTitle: LocalizedStylableText? {
        return stringLoader.getString("toolbar_title_cancelReceipt")
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return stringLoader.getString("tooltip_text_cancelReceipt")
    }
    
    func onContinueButtonClicked() {
        guard let account = operativeData.account else { return }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateCancelDirectBillingUseCaseInput(account: account, bill: operativeData.bill)
        UseCaseWrapper(
            with: useCaseProvider.getCancelDirectBillingValidationUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    let operativeData: CancelDirectBillingOperativeData = strongSelf.containerParameter()
                    operativeData.cancelDirectBilling = response.cancelDirectBilling
                    strongSelf.container?.saveParameter(parameter: response.signature)
                    strongSelf.container?.saveParameter(parameter: operativeData)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                }
            }
        )
    }
    
    func controlSwipeGesture(tooltipShowed: Bool) {
        self.view.navigationController?.interactivePopGestureRecognizer?.isEnabled = !tooltipShowed
    }
}
