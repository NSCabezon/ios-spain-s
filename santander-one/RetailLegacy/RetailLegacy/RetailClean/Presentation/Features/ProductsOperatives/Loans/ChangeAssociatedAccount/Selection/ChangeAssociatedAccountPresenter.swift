class ChangeAssociatedAccountPresenter: OperativeStepPresenter<ChangeAssociatedAccountViewController, VoidNavigator, ChangeAssociatedAccountPresenterProtocol> {
    private var loan: Loan?
    private var loanDetail: LoanDetail?
    private var validList: AccountList?
    
    override var screenId: String? {
        return TrackerPagePrivate.LoanChangeAssotiatedAccount().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_associatedAccount")
        guard let container = container else {
            fatalError()
        }
        loan = container.provideParameter()
        loanDetail = container.provideParameter()
        validList = container.provideParameter()
        
        infoObtained()
    }
    
    private func infoObtained() {
        guard let accounts = validList?.list, let loanDetail = loanDetail else {
            return
        }
        
        let sectionHeader = TableModelViewSection()        
        let headerViewModel = GenericHeaderTwoLineViewModel(title: stringLoader.getString((loan?.getAlias()) ?? ""),
                                      subtitle: stringLoader.getString(loan?.getAmountUI() ?? ""),
                                      infoText: stringLoader.getString("changeAccount_label_pending"))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderTwoLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let filtered = accounts.filter { $0.accountDTO.contract?.formattedValue != loanDetail.getLinkedAccountContract }
        
        let sectionContent = TableModelViewSection()
        let sectionTitleHeader = TitledTableModelViewHeader()
        sectionTitleHeader.title = stringLoader.getString("changeAccount_text_whatAccount")
        sectionContent.setHeader(modelViewHeader: sectionTitleHeader)
        sectionContent.items = filtered.map { SelectableAccountViewModel($0, dependencies) }
        
        view.sections = [sectionHeader, sectionContent]
    }
}

extension ChangeAssociatedAccountPresenter: ChangeAssociatedAccountPresenterProtocol {
    
    func selected(index: Int) {
        guard let modelView = view.itemsSectionContent()[index] as? SelectableAccountViewModel else {
            return
        }
        let account = modelView.account
        
        let input = PrevalidateChangeLinkedAccountUseCaseInput(account: account)
        let useCase = useCaseProvider.prevalidateChangeLoanLinkedAccount(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.container?.saveParameter(parameter: account)
            strongSelf.container?.saveParameter(parameter: result.accountDetail)
            strongSelf.container?.stepFinished(presenter: strongSelf)
        }, onError: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.showError(keyDesc: error?.getErrorDesc())
        })
    }
}
