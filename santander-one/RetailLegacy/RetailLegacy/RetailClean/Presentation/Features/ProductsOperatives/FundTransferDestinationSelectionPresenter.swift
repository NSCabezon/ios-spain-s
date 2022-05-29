import Foundation

class FundTransferDestinationSelectionPresenter: OperativeStepPresenter<FundTransferDestinationSelectionViewController, VoidNavigator, FundTransferDestinationSelectionPresenterProtocol> {
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_foundTransfer")
        infoObtained()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.FundTransfer().page
    }
    
    private func infoObtained() {
        guard let container = container else {
            fatalError()
        }
        
        let fundsList: FundList = container.provideParameter()
        let fund: Fund = container.provideParameter()
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderOneLineViewModel(leftTitle: .plain(text: fund.getAlias()?.camelCasedString),
                                                            rightTitle: .plain(text: fund.getAmountUI()))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderOneLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let filtered = fundsList.list.filter { $0.fundDTO.contract?.formattedValue != fund.fundDTO.contract?.formattedValue }
        
        let sectionContent = TableModelViewSection()
        let sectionTitleHeader = TitledTableModelViewHeader()
        sectionTitleHeader.title = stringLoader.getString("foundTransfer_text_selectedFoudDestination")
        sectionContent.setHeader(modelViewHeader: sectionTitleHeader)
        sectionContent.items = filtered.map { SelectableFundViewModel($0, dependencies) }
        
        view.sections = [sectionHeader, sectionContent]
    }
}

enum FundTransferType {
    case total
    case partialAmount
    case partialShares
}

class FundTransferTransaction: OperativeParameter {
    
    var fundTransferType: FundTransferType?
    var amount: Amount?
    var shares: Decimal?
    var associatedAccount: String
    var destinationFund: Fund
    var valueDate: Date?
    
    public init(fundTransferType: FundTransferType?, amount: Amount?, shares: Decimal?, associatedAccount: String, destinationFund: Fund) {
        self.fundTransferType = fundTransferType
        self.amount = amount
        self.shares = shares
        self.associatedAccount = associatedAccount
        self.destinationFund = destinationFund
    }
}

extension FundTransferDestinationSelectionPresenter: FundTransferDestinationSelectionPresenterProtocol {
    
    func selected(index: Int) {
        guard let container = container, let modelView = view.itemsSectionContent()[index] as? SelectableFundViewModel else {
            return
        }
        
        let fundTransferTransaction = FundTransferTransaction(fundTransferType: nil, amount: nil, shares: nil, associatedAccount: "", destinationFund: modelView.fund)
        
        container.saveParameter(parameter: fundTransferTransaction)
        container.stepFinished(presenter: self)
    }
}
