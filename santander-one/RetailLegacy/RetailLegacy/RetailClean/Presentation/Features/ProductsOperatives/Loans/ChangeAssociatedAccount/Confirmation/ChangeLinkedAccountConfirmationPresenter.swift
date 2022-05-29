class ChangeLinkedAccountConfirmationPresenter: OperativeStepPresenter<ChangeLinkedAccountConfirmationViewController, VoidNavigator, ChangeLinkedAccountConfirmationPresenterProtocol> {
    var loan: Loan?
    var account: Account?
    
    override var screenId: String? {
        return TrackerPagePrivate.LoanChangeAssotiatedAccountConfirmation().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        guard let container = container else {
            fatalError()
        }
        
        loan = container.provideParameter()
        account = container.provideParameter()
        let accountDetail: AccountDetail = container.provideParameter()
        
        guard let loan = loan, let account = account else {
            return
        }
        
        let loanSection = TableModelViewSection()
        
        let loanHeader = TitledTableModelViewHeader()
        loanHeader.title = stringLoader.getString("changeAccount_label_loans")
        
        loanSection.setHeader(modelViewHeader: loanHeader)
        
        let loanItem = ChangeLinkedAccountConfirmationLoanViewModel(loan, dependencies)
        loanSection.items = [loanItem]
        
        let accountSection = TableModelViewSection()
        
        let accountHeader = TitledTableModelViewHeader()
        accountHeader.title = stringLoader.getString("changeAccount_label_associatedAccount")
        accountSection.setHeader(modelViewHeader: accountHeader)
        
        let accountItem = SimpleConfirmationTableViewHeaderModel(stringLoader.getString("confirmation_item_accounts"),
                                                                 account.getAliasAndInfo(),
                                                                 false,
                                                                 dependencies)
        
        let holderItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_holder"),
                                                        accountDetail.getHolder?.capitalized ?? "",
                                                        false,
                                                        dependencies)
        
        let balanceItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_balance"),
                                                         account.getAmount()?.getFormattedAmountUI() ?? "",
                                                         true,
                                                         dependencies)
        
        accountSection.items = [accountItem, holderItem, balanceItem]
        
        view.sections = [loanSection, accountSection]
    }
}

extension ChangeLinkedAccountConfirmationPresenter: ChangeLinkedAccountConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: useCaseProvider.validateLinkedChangeAccount(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.container?.saveParameter(parameter: Signature(dto: response.signature))
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
        })
    }
}
