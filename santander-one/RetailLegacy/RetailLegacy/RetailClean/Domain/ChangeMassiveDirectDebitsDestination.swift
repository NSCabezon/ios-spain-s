import Foundation

class ChangeMassiveDirectDebitsDestinationProfile: OperativeProductSelectionProfile {
    
    weak var operativeStep: OperativeProductSelectionPresenterStep?
    
    var screenIdProductSelection: String? {
        return TrackerPagePrivate.ChangeMassiveDirectDebitsDestinationAccount().page
    }
    
    required init(operativeStep: OperativeProductSelectionPresenterStep) {
        self.operativeStep = operativeStep
    }
    
    func products() -> [Account] {
        let parameter: ChangeMassiveDirectDebitsOperativeData = containerParameter()
        return parameter.list.filter({ $0 != parameter.productSelected })
    }
    
    func selected(_ index: Int) {
        guard let operativeStep = self.operativeStep else { return }
        let parameter: ChangeMassiveDirectDebitsOperativeData = containerParameter()
        parameter.destinationAccount = products()[index]
        saveParameter(parameter)
        operativeStep.container?.stepFinished(presenter: operativeStep)
    }
    
    func setupHeader(for section: TableModelViewSection) {
        let parameter: ChangeMassiveDirectDebitsOperativeData = containerParameter()
        guard
            let dependencies = operativeStep?.dependencies,
            let account = parameter.productSelected,
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
        section.add(item: GenericHeaderViewModel(viewModel: headerViewModel, viewType: AccountOperativeHeaderView.self, dependencies: dependencies))
    }
    
    func subtitle() -> String {
        return "directDebitMassive_text_selectAccountNew"
    }
}
