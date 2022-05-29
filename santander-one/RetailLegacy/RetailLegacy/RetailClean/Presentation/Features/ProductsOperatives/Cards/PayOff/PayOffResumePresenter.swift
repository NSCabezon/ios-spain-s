import Foundation

final class PayOffResumePresenter: OperativeStepPresenter<PayOffResumeViewController, VoidNavigator, PayOffResumePresenterProtocol> {
    
    override var screenId: String? {
        return TrackerPagePrivate.PayOffConfirmation().page
    }
    
    var operativeData: PayOffCardOperativeData? {
        return container?.provideParameter()
    }
    
    var cardNumber: String? {
        guard let card = operativeData?.productSelected else { return nil }
        return card.getDetailUI()
    }
    
    var ownerName: String? {
        guard let cardDetail = operativeData?.cardDetail else { return nil }
        return cardDetail.beneficiary
    }
    
    var amountText: String? {
        guard let amount = operativeData?.amount else { return nil }
        return amount.getFormattedAmountUI()
    }
    
    private var cardImage: String? {
        return operativeData?.productSelected?.buildImageRelativeUrl(true)
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        
        let accountSection = TableModelViewSection()
        let accountHeader = TitledTableModelViewHeader()
        accountHeader.title = stringLoader.getString("confirmationDepositCard_label_originAccount")
        accountHeader.titleIdentifier = "confirmationDepositCard_label_originAccount"
        accountSection.setHeader(modelViewHeader: accountHeader)
        if let account = operativeData?.payOffAccount {
            let accountName = account.getAlias() ?? dependencies.stringLoader.getString("generic_confirm_associatedAccount").text
            let ibanNumber = account.getIBANShort() 
            let amount = account.getAmountUI()
            let accountViewModel = AccountConfirmationViewModel(accountName: accountName,
                                                                ibanNumber: ibanNumber,
                                                                amount: amount, identifiers:
                                                                    ("confirmationDepositCard_label_accountName",
                                                                     "confirmationDepositCard_label_accountIban",
                                                                     "confirmationDepositCard_label_accountAmount",
                                                                     "confirmationDepositCard_label_accountAmountInfo"),
                                                                privateComponent: dependencies)
            accountSection.add(item: accountViewModel)
        }
        
        let infoSection = TableModelViewSection()
        let infoTitleSection = TitledTableModelViewHeader()
        infoTitleSection.title = stringLoader.getString("confirmationDepositCard_label_cardEntry")
        infoTitleSection.titleIdentifier = "confirmationDepositCard_label_cardEntry"
        infoSection.setHeader(modelViewHeader: infoTitleSection)
        if let amount = amountText {
            let amountItem = PayOffHeaderAmountViewModel(amount, identifier: "confirmationDepositCard_label_amount", dependencies)
            infoSection.items.append(amountItem)
        }
        
        if let card = operativeData?.productSelected {
            let cardHeaderItem = PayOffConfirmationCardViewModel(alias: card.getAlias(),
                                                                 amount: card.getAmountUI(),
                                                                 imageURL: cardImage ?? "",
                                                                 imageLoader: dependencies.imageLoader,
                                                                 identifiers: ("confirmationDepositCard_label_cardAlias", "confirmationDepositCard_label_cardAmount", "confirmationDepositCard_image_cardImage"),
                                                                 privateComponent: dependencies)
            infoSection.items.append(cardHeaderItem)
        }
        if let cardNumber = cardNumber {
            let cardNumberItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmationDepositCard_item_numberCard"), cardNumber, false, dependencies, accessibilityIdentifier: "confirmationDepositCard_view_number", descriptionIdentifier: "confirmationDepositCard_label_descNumber", valueIdentifier: "confirmationDepositCard_label_valueNumber")
            infoSection.add(item: cardNumberItem)
        }
        if let ownerName = ownerName {
            let ownerNameItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmation_item_holder"), ownerName.capitalized, false, dependencies, accessibilityIdentifier: "confirmationDepositCard_view_owner", descriptionIdentifier: "confirmationDepositCard_label_descOwner", valueIdentifier: "confirmationDepositCard_label_valueOwner")
            infoSection.add(item: ownerNameItem)
        }
        let dateItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmation_item_date"), dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "", true, dependencies, accessibilityIdentifier: "confirmationDepositCard_view_date", descriptionIdentifier: "confirmationDepositCard_label_descDate", valueIdentifier: "confirmationDepositCard_label_valueDate")
        infoSection.add(item: dateItem)
        view.sections = [accountSection, infoSection]
    }
    
}

extension PayOffResumePresenter: PayOffResumePresenterProtocol {
    var buttonTitle: LocalizedStylableText {
        return stringLoader.getString("generic_button_confirm")
    }
    
    func confirmButtonTouched() {
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let usecase = useCaseProvider.validatePayOffUsecase()
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let presenter = self else { return }
            presenter.hideLoading(completion: {
                presenter.container?.saveParameter(parameter: response.depositMoneyIntoCardSignatureToken)
                presenter.container?.stepFinished(presenter: presenter)
            })
            
            }, onError: { [weak self] error in
                guard let presenter = self else { return }
                presenter.hideLoading(completion: {
                    presenter.showError(keyDesc: error?.getErrorDesc())
                })
        })
    }
}
