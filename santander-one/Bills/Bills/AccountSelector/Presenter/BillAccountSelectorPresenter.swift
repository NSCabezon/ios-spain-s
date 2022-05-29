import Foundation
import CoreFoundationLib
import UI

protocol BillAccountSelector {
    func didSelectAccount(_ account: AccountEntity)
}

protocol BillAccountSelectorPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: BillAccountSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectAccount(_ viewModel: BillAccountSelectionViewModel)
    func didSelectDismiss()
}

final class BillAccountSelectorPresenter {
    weak var view: BillAccountSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var getAccountsUseCase: GetAccountsUseCase {
        return self.dependenciesResolver.resolve(for: GetAccountsUseCase.self)
    }
    
    private var billAccountSelector: BillAccountSelector {
        return self.dependenciesResolver.resolve(for: BillAccountSelector.self)
    }
    
    private var coordinator: BillAccountSelectorCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BillAccountSelectorCoordinatorProtocol.self)
    }
}
 
private extension BillAccountSelectorPresenter {
    func loadAccounts(_ completion: @escaping([AccountEntity]) -> Void) {
        MainThreadUseCaseWrapper(
            with: self.getAccountsUseCase,
            onSuccess: { response in
                completion(response.accounts)
        }, onError: { _ in
            completion([])
        })
    }
}
    
extension BillAccountSelectorPresenter: BillAccountSelectorPresenterProtocol {
    func viewDidLoad() {
        self.loadAccounts { [weak self] accounts in
            let viewModels = accounts.map { BillAccountSelectionViewModel(account: $0) }
            self?.view?.setViewModels(viewModels)
        }
    }
    
    func didSelectAccount(_ viewModel: BillAccountSelectionViewModel) {
        self.billAccountSelector.didSelectAccount(viewModel.account)
        self.coordinator.dismiss()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
}
