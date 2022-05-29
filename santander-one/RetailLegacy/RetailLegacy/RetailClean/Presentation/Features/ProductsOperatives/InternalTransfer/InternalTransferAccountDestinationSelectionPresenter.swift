//

import Foundation

class InternalTransferAccountDestinationSelectionPresenter: OperativeStepPresenter<InternalTransferAccountDestinationSelectionViewController, VoidNavigator, InternalTransferAccountDestinationSelectionPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var accounts: [Account] = []
    
    // MARK: - Overrided methods
    
    override func loadViewData() {
        super.loadViewData()
        let parameter: InternalTransferOperativeData = containerParameter()
        let accounts: [Account] = parameter.list
        guard
            let selectedAccount = parameter.productSelected
        else {
            return
        }
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_transfer")
        // Filter the accounts with the selected one
        self.accounts = accounts.filter({ $0 != selectedAccount })
        // Add header of selected account
        let sectionHeader = TableModelViewSection()
        addAcountSelectedHeader(selectedAccount, to: sectionHeader)
        let sectionContent = TableModelViewSection()
        // Add title header
        let titleTable = TitledTableModelViewHeader()
        titleTable.title = stringLoader.getString("transfer_label_destinationAccounts")
        sectionContent.setHeader(modelViewHeader: titleTable)
        // Add the accounts
        sectionContent.addAll(items: self.accounts.map({ SelectableAccountViewModel($0, dependencies) }))
        view.sections = [sectionHeader, sectionContent]
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.InternalTransferDestinationAccountSelection().page
    }
    
    // MARK: - Private methods
    
    private func addAcountSelectedHeader(_ account: Account, to sectionHeader: TableModelViewSection) {
        guard
            let selectedAccountAmount = account.getAmount(),
            let selectedAccountAlias = account.getAlias(),
            let selectedAccountIBAN = account.getIban()?.ibanShort()
        else {
            return
        }
        let headerViewModel = AccountHeaderViewModel(
            accountAlias: selectedAccountAlias,
            accountIBAN: selectedAccountIBAN,
            accountAmount: selectedAccountAmount.getAbsFormattedAmountUI()
        )
        sectionHeader.add(item: GenericHeaderViewModel(viewModel: headerViewModel, viewType: AccountOperativeHeaderView.self, dependencies: dependencies))
    }
}

extension InternalTransferAccountDestinationSelectionPresenter: InternalTransferAccountDestinationSelectionPresenterProtocol {
    
    func selected(index: Int) {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let selectedAccount = parameter.productSelected else {
            return
        }
        let internalTransfer = InternalTransfer()
        internalTransfer.originAccount = selectedAccount
        internalTransfer.destinationAccount = self.accounts[index]
        parameter.internalTransfer = internalTransfer
        container?.saveParameter(parameter: parameter)
        container?.stepFinished(presenter: self)
    }
}
