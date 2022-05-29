//
//  AnalysisAreaCoordinator.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 11/03/2020.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

protocol OldAnalysisAreaHomeDependenciesResolver {
    var external: AnalysisAreaHomeExternalDependenciesResolver { get }
}

public protocol OldAnalysisAreaCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func showTransactionDetailFromBalanceEntities(_ transactions: [AccountTransactionWithAccountEntity], selectedTransaction: AccountTransactionWithAccountEntity)
    func didSelectSearch()
}

public protocol OldAnalysisAreaCoordinatorProtocol: AnyObject {
    func showExpensesAnalysisConfiguration()
    func showTimePeriodSelector()
    func didSaveTimePeriodWith(_ configuration: TimePeriodConfiguration)
    func didSelectCategoriesDetail(_ category: ExpensesIncomeCategoryType)
    func back()
    func showMenu()
}

final class OldAnalysisAreaCoordinator: BindableCoordinator {
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding = DataBindingObject()
    var childCoordinators: [Coordinator] = []
    
    public weak var navigationController: UINavigationController?
    private var monthTransfersCoordinator: MonthTransfersCoordinator?
    private var incomeExpenseCoordinator: IncomeExpenseCoordinator?
    
    private var monthDebtsCoordinator: MonthDebtsCoordinator?
    private var monthSubscriptionsCoordinator: MonthSubscriptionsCoordinator?
    private var monthReceiptsCoordinator: MonthReceiptsCoordinator?
    private var expensesAnalysisConfigCoordinator: ExpensesAnalysisConfigCoordinator?
    private var categoriesDetailCoordinator: CategoriesDetailCoordinatorProtocol?
    
    private let dependenciesResolver: DependenciesResolver?
    private let externalDependencies: AnalysisAreaHomeExternalDependenciesResolver?
    private lazy var dependencies: Dependency? = {
        guard let extDependency = externalDependencies else { return nil }
        return Dependency(dependencies: extDependency)
    }()
    private lazy var legacyDependencies: DependenciesDefault = {
        DependenciesDefault(father: dependencies?.external.resolve())
    }()
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesResolver = dependenciesResolver
        externalDependencies = nil
        setupDependencies()
    }
    
    init(dependencies: AnalysisAreaHomeExternalDependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
        dependenciesResolver = nil
        initializeAuxiliaryCoordinators()
        setupDependencies()
    }
    
    func start() {
        var controller: UIViewController
        if let enabled = legacyDependencies.resolve(for: AppConfigRepositoryProtocol.self).getBool(Constants.enabledNewAnalysisZone), enabled {
            controller = self.legacyDependencies.resolve(for: OldAnalysisAreaHomeViewController.self)
        } else {
            controller = self.legacyDependencies.resolve(for: OldAnalysisAreaViewController.self)
        }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func goToMonthTransfers(selectedTransfer: ExpenseType, allTransfers: TimeLineResultEntity) {
        self.legacyDependencies.register(for: MonthTransfersConfiguration.self) { _ in
            return MonthTransfersConfiguration(selectedTransfer: selectedTransfer, allTransfers: allTransfers)
        }
        
        self.monthTransfersCoordinator?.start()
    }
    
    func goToMovementsReportsFor(type: AccountMovementsType, pfmMonth: MonthlyBalanceRepresentable) {
        self.legacyDependencies.register(for: IncomeExpenseConfiguration.self) { _ in
            return IncomeExpenseConfiguration(selectedMovementType: type, pfmMonth: pfmMonth)
        }
        self.incomeExpenseCoordinator?.start()
    }
    
    func goToMonthDebts(allDebts: TimeLineResultEntity) {
        self.legacyDependencies.register(for: MonthDebtsConfiguration.self) { _ in
            return MonthDebtsConfiguration(allDebts: allDebts)
        }
        
        self.monthDebtsCoordinator?.start()
    }
    
    func goToMonthSubscriptions(allSubscriptions: TimeLineResultEntity) {
        self.legacyDependencies.register(for: MonthSubscriptionsConfiguration.self) { _ in
            return MonthSubscriptionsConfiguration(allSubscriptions: allSubscriptions)
        }
        
        self.monthSubscriptionsCoordinator?.start()
    }
    
    func goToMonthReceipts(selectedReceipt: ExpenseType, allReceipts: TimeLineResultEntity) {
        self.legacyDependencies.register(for: MonthReceiptsConfiguration.self) { _ in
            return MonthReceiptsConfiguration(selectedReceipt: selectedReceipt, allReceipts: allReceipts)
        }
        
        self.monthReceiptsCoordinator?.start()
    }
    
    func showGenericError() {
        self.showGenericErrorDialog(withDependenciesResolver: legacyDependencies,
                                    closeAction: {
            self.dismiss()
                                    })
    }
        
    func goToGlobalSearch() {
        let coordinatorDelegate = self.legacyDependencies.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
        coordinatorDelegate.didSelectSearch()
    }
    
    func showMenu() {
        guard let coordinator = dependencies?.external.privateMenuCoordinator() else {
            return
        }
        coordinator.start()
        append(child: coordinator)
    }
}

extension OldAnalysisAreaCoordinator: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        self.navigationController?.topViewController ?? UIViewController()
    }
}

extension OldAnalysisAreaCoordinator: OldAnalysisAreaCoordinatorProtocol {
    
    func didSaveTimePeriodWith(_ configuration: TimePeriodConfiguration) {
        self.legacyDependencies.register(for: TimePeriodConfiguration.self) { _ in
            return configuration
        }
    }
    
    func showTimePeriodSelector() {
        let controller = self.legacyDependencies.resolve(for: TimePeriodSelectorViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func showExpensesAnalysisConfiguration() {
        self.expensesAnalysisConfigCoordinator?.start()
    }
    
    func didSelectCategoriesDetail(_ category: ExpensesIncomeCategoryType) {
        self.legacyDependencies.register(for: CategoriesDetailConfiguration.self) { _ in
            return CategoriesDetailConfiguration(category: category)
        }
        self.categoriesDetailCoordinator?.start()
    }
    
    func back() {
        navigationController?.popViewController(animated: !UIAccessibility.isVoiceOverRunning)
    }
}

private extension OldAnalysisAreaCoordinator {
    enum Constants {
        static let enabledNewAnalysisZone = "enabledNewAnalysisZone"
    }
    
    func setupDependencies() {
        self.legacyDependencies.register(for: OldAnalysisAreaCoordinator.self) { _ in
            return self
        }
        
        self.legacyDependencies.register(for: GetOffersCandidatesUseCase.self) { dependenciesResolver in
            return GetOffersCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: GetFinancialHealthUseCase.self) { dependenciesResolver in
            return GetFinancialHealthUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: AnalysisAreaPresenterProtocol.self) { dependenciesResolver in
            return AnalysisAreaPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: AnalysisAreaHomePresenterProtocol.self) { dependenciesResolver in
            return AnalysisAreaHomePresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: TimePeriodSelectorPresenterProtocol.self) { dependenciesResolver in
            return TimePeriodSelectorPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: ExpensesAnalysisPresenterProtocol.self) { dependenciesResolver in
            return ExpensesAnalysisPresenter(dependenciesResolver: dependenciesResolver)
        }

        self.legacyDependencies.register(for: LoadingTipViewController.self) { dependenciesResolver  in
            let tipsPresenter = LoadingTipPresenter(dependenciesResolver: dependenciesResolver)
            let viewController = LoadingTipViewController(presenter: tipsPresenter)
            tipsPresenter.view = viewController
            return viewController
        }
        
        self.legacyDependencies.register(for: TimeLineMovementsUseCase.self) {  dependenciesResolver in
            let timeLineMovementsUseCase = TimeLineMovementsUseCase(dependenciesResolver: dependenciesResolver)
            return timeLineMovementsUseCase
        }
        
        self.legacyDependencies.register(for: OldAnalysisAreaViewController.self) { dependenciesResolver in
            let presenter: AnalysisAreaPresenterProtocol = dependenciesResolver.resolve(for: AnalysisAreaPresenterProtocol.self)
            let viewController = OldAnalysisAreaViewController(nibName: "OldAnalysisAreaViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            presenter.view?.loadingTipsViewController = dependenciesResolver.resolve(for: LoadingTipViewController.self)
            return viewController
        }
        
        self.legacyDependencies.register(for: OldAnalysisAreaHomeViewController.self) { dependenciesResolver in
            let presenter: AnalysisAreaHomePresenterProtocol = dependenciesResolver.resolve()
            let viewController = OldAnalysisAreaHomeViewController(dependenciesResolver: self.legacyDependencies, presenter: presenter)
            presenter.view = viewController
            return viewController
        }

        self.legacyDependencies.register(for: TimePeriodSelectorViewController.self) { dependenciesResolver in
            let presenter: TimePeriodSelectorPresenterProtocol = dependenciesResolver.resolve()
            let viewController = TimePeriodSelectorViewController(presenter: presenter, dependenciesResolver: dependenciesResolver)
            presenter.view = viewController
            return viewController
        }
        
        self.legacyDependencies.register(for: ExpensesAnalysisViewController.self) { dependenciesResolver in
            let presenter: ExpensesAnalysisPresenterProtocol = dependenciesResolver.resolve()
            let viewController = ExpensesAnalysisViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.legacyDependencies.register(for: GetUserPrefWithoutUserIdUseCase.self) { dependenciesResolver in
            return GetUserPrefWithoutUserIdUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: UpdateUserPreferencesUseCase.self) { dependenciesResolver in
            return UpdateUserPreferencesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: GetAnalysisSectionsUseCase.self) { dependenciesResolver in
            return GetAnalysisSectionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: GetAllTricksUseCase.self) { dependenciesResolver in
            return GetAllTricksUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: ExpensesIncomeCategoriesUseCase.self) { dependenciesResolver in
            return ExpensesIncomeCategoriesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependencies.register(for: GetPiggyBankUseCase.self) { dependenciesResolver in
            return GetPiggyBankUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.legacyDependencies.register(for: GetAnalysisFinancialCushionUseCase.self) { dependenciesResolver in
            return GetAnalysisFinancialCushionUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.legacyDependencies.register(for: GetAnalysisFinancialBudgetHelpUseCase.self) { dependenciesResolver in
            return GetAnalysisFinancialBudgetHelpUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.legacyDependencies.register(for: OldAnalysisAreaCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.legacyDependencies.register(for: TimePeriodConfiguration.self) { dependenciesResolver in
            return TimePeriodConfiguration(.monthly, dependenciesResolver: dependenciesResolver)
        }
    }
    
    func initializeAuxiliaryCoordinators() {
        guard let navigationController = self.navigationController else {
            return
        }
        self.monthTransfersCoordinator = MonthTransfersCoordinator(dependenciesResolver: self.legacyDependencies,
                                                                   navigationController: navigationController)
        self.incomeExpenseCoordinator = IncomeExpenseCoordinator(dependenciesResolver: self.legacyDependencies,
                                                                 navigationController: navigationController)
        self.monthDebtsCoordinator = MonthDebtsCoordinator(dependenciesResolver: self.legacyDependencies,
                                                           navigationController: navigationController)
        self.monthSubscriptionsCoordinator = MonthSubscriptionsCoordinator(dependenciesResolver: self.legacyDependencies, navigationController: navigationController)
        self.monthReceiptsCoordinator = MonthReceiptsCoordinator(dependenciesResolver: self.legacyDependencies,
                                                                 navigationController: navigationController)
        self.expensesAnalysisConfigCoordinator = ExpensesAnalysisConfigCoordinator(dependenciesResolver: self.legacyDependencies, navigationController: navigationController)
        self.categoriesDetailCoordinator = CategoriesDetailCoordinator(dependenciesResolver: self.legacyDependencies,
                                                                       navigationController: navigationController)
    }
}

private extension OldAnalysisAreaCoordinator {
    struct Dependency: OldAnalysisAreaHomeDependenciesResolver {
        let dependencies: AnalysisAreaHomeExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: AnalysisAreaHomeExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
