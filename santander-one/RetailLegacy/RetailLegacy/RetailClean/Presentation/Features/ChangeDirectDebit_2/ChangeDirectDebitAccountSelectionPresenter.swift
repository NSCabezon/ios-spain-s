import Foundation

class ChangeDirectDebitAccountSelectionPresenter: OperativeStepPresenter<ProductSelectionViewController, VoidNavigator, ProductSelectionPresenterProtocol> {
    
    // MARK: - Public attributes
    
    lazy var products: [Account] = {
        let parameter: ChangeDirectDebitOperativeData = containerParameter()
        return parameter.accounts
    }()
    
    override func loadViewData() {
        super.loadViewData()
        setHeader()
        self.setTitle()
        showProducts(sectionTitleKey: "confirmation_label_whereDomicile")
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.ChangeDirectDebitOriginAccount().page
    }
    
    // MARK: - Private methods
    
    private func setHeader() {
        let parameter: ChangeDirectDebitOperativeData = containerParameter()
        let headerViewModel = GenericHeaderTwoLineViewModel(title: .plain(text: parameter.bill.holder), subtitle: nil, infoText: .plain(text: parameter.bill.issuerCode))
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderTwoLineView.self, dependencies: dependencies)
        let section = TableModelViewSection()
        section.items = [headerCell]
        view.sections += [section]
    }
}

extension ChangeDirectDebitAccountSelectionPresenter: ProductSelectionPresenterProtocol {
    
    func selected(index: Int) {
        let parameter: ChangeDirectDebitOperativeData = containerParameter()
        parameter.destinationAccount = products[index]
        container?.saveParameter(parameter: parameter)
        container?.stepFinished(presenter: self)
    }
    
    var tooltipMessage: LocalizedStylableText? {
        return nil
    }
    
    var progressBarBackgroundStyle: ProductSelectionProgressStyle {
        return .white
    }
    
    func setTitle() {
        set(title: "confirmation_label_domiciliationAccount")
    }
    
    func getTitle() -> String? {
        return "confirmation_label_domiciliationAccount"
    }
}
