import Foundation

class ConfirmationChangeDirectDebitPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: CancelDirectBillingOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.ChangeDirectDebitConfirmation().page
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.updateButton(title: stringLoader.getString("generic_button_continue"))
        self.view.sections = makeSections()
    }
    
    // MARK: - Private methods
    
    private func makeSections() -> [TableModelViewSection] {
        let parameter: ChangeDirectDebitOperativeData = containerParameter()
        guard let destinationAccount = parameter.destinationAccount else { return [] }
        let bill = parameter.bill
        let billDetail = parameter.billDetail
        let entitySection = TableModelViewSection()
        let entityHeader = TitledTableModelViewHeader()
        entityHeader.title = stringLoader.getString("confirmation_item_issuingEntity")
        entitySection.setHeader(modelViewHeader: entityHeader)
        let entityItem = BillConfirmationViewModel(name: bill.name, identifier: bill.issuerCode, privateComponent: dependencies)
        entitySection.add(item: entityItem)
        let dataSection = TableModelViewSection()
        let dataHeader = TitledTableModelViewHeader()
        dataHeader.title = stringLoader.getString("confirmation_item_domiciliation")
        dataSection.setHeader(modelViewHeader: dataHeader)
        let items: [ConfirmationTableViewItemModel] = [
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_newAccount"), destinationAccount.getAliasAndInfo(), false, dependencies, isFirst: true),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_holder"), bill.holder.camelCasedString, false, dependencies),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_authorisationReference"), billDetail.mandateReference, false, dependencies),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_description"), billDetail.concept?.capitalizingFirstLetter() ?? "", true, dependencies)
        ]
        dataSection.addAll(items: items)
        let footerSection = TableModelViewSection()
        let footerInfoLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("confirmation_text_rememberlReceipt"), style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .center), insets: Insets(left: 33, right: 33, top: 23, bottom: 23), privateComponent: dependencies)
        footerSection.items.append(footerInfoLabelModel)
        return [entitySection, dataSection, footerSection]
    }
}

extension ConfirmationChangeDirectDebitPresenter: OperativeConfirmationPresenterProtocol {
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }

    func onContinueButtonClicked() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getValidateChangeDirectDebitUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.container?.saveParameter(parameter: response.signatureWithToken)
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
}
