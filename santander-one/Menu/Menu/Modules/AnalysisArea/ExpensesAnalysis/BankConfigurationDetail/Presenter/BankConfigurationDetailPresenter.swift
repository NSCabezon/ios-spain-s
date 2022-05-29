import Foundation
import CoreFoundationLib
import UI

protocol BankConfigurationDetailPresenterProtocol: AnyObject {
    var view: BankConfigurationDetailViewProtocol? { get set }
    func viewDidLoad()
    func didSelectBack()
    func didSelectDismiss()
    func didSelectSaveData()
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool)
    func didPressAllCardsCheckBox(_ areAllSelected: Bool)
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel)
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel)
    func didSelectRemoveConnection()
    func didSelectConfirmRemoveConnection()
    func didSelectUpdateAccessKeys()
}

final class BankConfigurationDetailPresenter {
    weak var view: BankConfigurationDetailViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var accounts: [AccountAnalysisInfo]?
    private var cards: [ExpenseAnalysisCardInfo]?
    private var initialAccountViewModels: [AccountProductConfigCellViewModel] = []
    private var initialCardViewModels: [CardProductConfigCellViewModel] = []
    private var editedAccountViewModels: [AccountProductConfigCellViewModel] = []
    private var editedCardViewModels: [CardProductConfigCellViewModel] = []
    private var baseUrl: String? {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BankConfigurationDetailPresenter: BankConfigurationDetailPresenterProtocol {
    func viewDidLoad() {
        self.loadLastUpdateInfo()
        self.loadAccounts {
            self.setAccountViews(true)
            self.loadCards {
                self.setCardViews(true)
            }
        }
    }
    
    func didSelectBack() {
        self.coordinator.dismiss()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool) {
        self.reloadAllAccountViews(areAllSelected)
    }
    
    func didPressAllCardsCheckBox(_ areAllSelected: Bool) {
        self.reloadAllCardViews(areAllSelected)
    }
    
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel) {
        self.reloadAccountView(viewModel)
    }
    
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel) {
        self.reloadCardView(viewModel)
    }
    
    func didSelectSaveData() {
        // TODO: - Save config changes when services are available
        self.coordinator.dismiss()
    }
    
    func didSelectRemoveConnection() {
        self.trackEvent(.deleteBank)
        self.view?.showRemoveConnectionDialog()
    }
    
    func didSelectConfirmRemoveConnection() {
        // TODO: - login required to remove connection with this entity
        self.coordinator.dismiss()
    }
    
    func didSelectUpdateAccessKeys() {
        // TODO: - logic required to update keys
        self.view?.recoveryKeysFinished()
    }
}

private extension BankConfigurationDetailPresenter {
    var coordinator: BankConfigurationDetailCoordinatorProtocol {
        self.dependenciesResolver.resolve()
    }
    
    var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve()
    }
    
    func loadLastUpdateInfo() {
        // TODO: - Remove when service is available
        let timeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
        let viewModel = BankDetailProductsHeaderViewModel(
            timeManager: timeManager,
            date: Date(),
            totalProducts: 2,
            bankImageUrl: "https://microsite.bancosantander.es/filesFF/RWD/entidades/iconos/es_1465.png"
        )
        self.view?.setHeaderView(viewModel)
    }
    
    func loadAccounts(completion: @escaping () -> Void) {
        // TODO: - Remove useCase when service is available
        let useCase = self.dependenciesResolver.resolve(for: GetConfigurationAccountsUseCase.self)
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { response in
                self.accounts = response.accountList
                completion()
            }
            .onError { _ in
                completion()
            }
    }
    
    func setAccountViews(_ allCheckBoxSelected: Bool) {
        guard let accountViewModels = self.getAccountProductConfigViewModels(allCheckBoxSelected) else { return }
        self.initialAccountViewModels = accountViewModels
        self.editedAccountViewModels = self.initialAccountViewModels
        self.view?.setAccountViews(self.initialAccountViewModels)
    }
    
    func reloadAllAccountViews(_ allCheckBoxSelected: Bool) {
        guard let accountViewModels = self.getAccountProductConfigViewModels(allCheckBoxSelected) else { return }
        self.editedAccountViewModels = accountViewModels
        self.view?.reloadAccountViews(self.editedAccountViewModels)
        self.setSaveChangesView()
    }
    
    func getAccountProductConfigViewModels(_ areAllSelected: Bool) -> [AccountProductConfigCellViewModel]? {
        guard let accounts = self.accounts else { return nil }
        let accountViewModels: [AccountProductConfigCellViewModel] = accounts.enumerated().map { (index, account) in
            let isLastPosition = index == accounts.count - 1
            return AccountProductConfigCellViewModel(account: account,
                                                     baseUrl: self.baseUrl,
                                                     isSelected: areAllSelected,
                                                     isLastCell: isLastPosition)
        }
        return accountViewModels
    }
    
    func reloadAccountView(_ viewModel: AccountProductConfigCellViewModel) {
        guard let index = self.editedAccountViewModels.firstIndex(where: { $0.iban == viewModel.iban }) else { return }
        self.editedAccountViewModels[index].setIsCellSelected(isSelected: viewModel.isSelected)
        self.view?.reloadAccountViews(self.editedAccountViewModels)
        self.setSaveChangesView()
    }
    
    func loadCards(completion: @escaping () -> Void) {
        // TODO: - Remove useCase when service is available
        let useCase = GetConfigurationCardsUseCase()
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { response in
                self.cards = response.cardList
                completion()
            }
            .onError { _ in
                completion()
            }
    }
    
    func setCardViews(_ allCheckBoxSelected: Bool) {
        guard let cardViewModels = self.getCardProductConfigViewModels(allCheckBoxSelected) else { return }
        self.initialCardViewModels = cardViewModels
        self.editedCardViewModels = self.initialCardViewModels
        self.view?.setCardViews(self.initialCardViewModels)
    }
    
    func reloadAllCardViews(_ allCheckBoxSelected: Bool) {
        guard let cardViewModels = self.getCardProductConfigViewModels(allCheckBoxSelected) else { return }
        self.editedCardViewModels = cardViewModels
        self.view?.reloadCardViews(self.editedCardViewModels)
        self.setSaveChangesView()
    }
    
    func getCardProductConfigViewModels(_ allCheckBoxSelected: Bool) -> [CardProductConfigCellViewModel]? {
        guard let cards = self.cards else { return nil }
        let cardViewModels: [CardProductConfigCellViewModel] = cards.enumerated().map { (index, card) in
            let isLastPosition = index == cards.count - 1
            return CardProductConfigCellViewModel(card: card,
                                                  baseURL: self.baseUrl,
                                                  isSelected: allCheckBoxSelected,
                                                  isLastCell: isLastPosition)
        }
        return cardViewModels
    }
    
    func reloadCardView(_ viewModel: CardProductConfigCellViewModel) {
        guard let index = self.editedCardViewModels.firstIndex(where: { $0.pan == viewModel.pan }) else { return }
        self.editedCardViewModels[index].setIsCellSelected(isSelected: viewModel.isSelected)
        self.view?.reloadCardViews(self.editedCardViewModels)
        self.setSaveChangesView()
    }
    
    func setSaveChangesView() {
        let areCardsEdited = self.initialCardViewModels != self.editedCardViewModels
        let areAccountsEdited = self.initialAccountViewModels != self.editedAccountViewModels
        guard areCardsEdited || areAccountsEdited else { return }
        self.view?.showSaveChangesButton()
    }
}

extension BankConfigurationDetailPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve()
    }
    
    var trackerPage: ExpensesAnalysisConfigurationPage {
        return ExpensesAnalysisConfigurationPage()
    }
}
