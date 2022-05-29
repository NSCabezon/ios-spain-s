import UIKit

class BillsAndTaxesTypeSelectorPresenter: OperativeStepPresenter<BillsAndTaxesTypeSelectorViewController, VoidNavigator, BillsAndTaxesTypeSelectorPresenterProtocol> {
       
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_doingPayement")
        
        getInfo()
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        onSuccess(parameter.typeOperative == nil)
    }
    
    var showNavigationInfo: Bool {
        return true
    }
    
    private func getInfo() {
        let sectionHeader = TableModelViewSection()
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let account = parameter.productSelected else {
            return
        }
        let headerViewModel = AccountHeaderViewModel(accountAlias: account.getAlias() ?? "", accountIBAN: account.getIban()?.ibanShort() ?? "", accountAmount: account.getAmount()?.getAbsFormattedAmountUI() ?? "")
        sectionHeader.add(item: GenericHeaderViewModel(viewModel: headerViewModel, viewType: AccountOperativeHeaderView.self, dependencies: dependencies))
        let sectionItems = TableModelViewSection()
        let itemsTitle = TitledTableModelViewHeader()
        itemsTitle.title = stringLoader.getString("receiptsAndTaxes_label_paymentType")
        sectionItems.setHeader(modelViewHeader: itemsTitle)
        
        let payBillModel = BillsAndTaxesTypeSelectorModelView(.bills, title: dependencies.stringLoader.getString("receiptsAndTaxes_label_paymentOfReceipts"), icon: "icnPayReceipt", items: [dependencies.stringLoader.getString("receiptsAndTaxes_label_cameraOrManual"), dependencies.stringLoader.getString("receiptsAndTaxes_label_codeIssuer")], dependencies: dependencies)
        sectionItems.add(item: payBillModel)
        
        let payTaxModel = BillsAndTaxesTypeSelectorModelView(.taxes, title: dependencies.stringLoader.getString("receiptsAndTaxes_label_paymentOfTaxes"), icon: "icnPayTaxes", items: [dependencies.stringLoader.getString("receiptsAndTaxes_label_codeIssuer"), dependencies.stringLoader.getString("receiptsAndTaxes_label_cameraOrManual")], dependencies: dependencies)
        sectionItems.add(item: payTaxModel)
        
        view.sections = [sectionHeader, sectionItems]
    }
}

extension BillsAndTaxesTypeSelectorPresenter: BillsAndTaxesTypeSelectorPresenterProtocol {
    func onSelectedIndex(index: Int) {
        guard let type = BillsAndTaxesTypeOperative(rawValue: index) else {
            return
        }
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        operativeData.typeOperative = type
        container?.saveParameter(parameter: operativeData)
        container?.stepFinished(presenter: self)
    }
}
