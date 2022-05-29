import Foundation
import CoreFoundationLib

struct BizumSendMoneyAccountSelectionViewModel: AccountSelectionViewModelProtocol {
    let account: AccountEntity
    
    var currentBalanceAmount: NSAttributedString {
        guard let amount = self.account.currentBalanceAmount else { return NSAttributedString(string: "") }
        let font = UIFont.santander(family: .text, type: .regular, size: 22)
        let moneyDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString(string: "")
    }
}

protocol BizumSendMoneyAccountSelectorPresenterProtocol: class {
    var view: BizumSendMoneyAccountSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectViewModel(_ viewModel: BizumSendMoneyAccountSelectionViewModel)
}

final class BizumSendMoneyAccountSelectorPresenter {
    
    weak var view: BizumSendMoneyAccountSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumSendMoneyAccountSelectorPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve()
    }
    
    var trackerPage: BizumSendMoneyAccountSelectorPage {
        return BizumSendMoneyAccountSelectorPage()
    }
}

extension BizumSendMoneyAccountSelectorPresenter: BizumSendMoneyAccountSelectorPresenterProtocol {
    func viewDidLoad() {
        Scenario(useCase: self.getAccountsUseCase)
            .execute(on: DispatchQueue.main)
            .onSuccess(self.handleGetAccountsUseCaseOutput)
    }
    
    func didSelectViewModel(_ viewModel: BizumSendMoneyAccountSelectionViewModel) {
        self.coordinator.dismissWithAccount(viewModel.account)
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
}

private extension BizumSendMoneyAccountSelectorPresenter {
    var coordinator: BizumSendMoneyAccountSelectorCoordinatorProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    var getAccountsUseCase: GetAllAccountsUseCase {
        return GetAllAccountsUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    func handleGetAccountsUseCaseOutput(_ output: GetAllAccountsUseCaseOutput) {
        self.view?.showAccounts(output.visibleAccounts.map(BizumSendMoneyAccountSelectionViewModel.init), notVisibleAccounts: output.notVisibleAccounts.map(BizumSendMoneyAccountSelectionViewModel.init))
    }
}
