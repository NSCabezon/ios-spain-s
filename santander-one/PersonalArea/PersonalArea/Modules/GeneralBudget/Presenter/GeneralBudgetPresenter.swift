//
//  GeneralBudgetPresenter.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 01/04/2020.
//

import CoreFoundationLib
import CoreDomain

protocol GeneralBudgetPresenterProtocol {
    var view: GeneralBudgetViewProtocol? { get set }
    var moduleCoordinator: GeneralBudgetCoordinator? { get set }
    func viewDidLoad()
    func backDidPressed()
    func closeDidPressed()
    func didPressSaveButton(budget: Double)
    func sliderTouchCancel()
}

final class GeneralBudgetPresenter {
    
    var view: GeneralBudgetViewProtocol?
    internal weak var moduleCoordinator: GeneralBudgetCoordinator?
    private let dependenciesResolver: DependenciesDefault
    private var userPref: UserPrefWrapper
    var dataManager: PersonalAreaDataManagerProtocol
    private var getMonthlyBalanceUseCase: GetMonthlyBalanceUseCase {
        dependenciesResolver.resolve(firstTypeOf: GetMonthlyBalanceUseCase.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
        self.userPref = self.dependenciesResolver.resolve(for: UserPrefWrapper.self)
        self.dataManager = self.dependenciesResolver.resolve(for: PersonalAreaDataManagerProtocol.self)
    }
    
    private var months: [MonthlyBalanceRepresentable]?

    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
}

extension GeneralBudgetPresenter: GeneralBudgetPresenterProtocol {
    func viewDidLoad() {
        loadMonthlyExpenses()
        trackScreen()
    }
    
    func backDidPressed() {
        moduleCoordinator?.end()
    }
    
    func closeDidPressed() {
        moduleCoordinator?.end()
    }
    
    func didPressSaveButton(budget: Double) {
        self.userPref.userPrefEntity?.setBudget(budget)
        if let userPrefEntity = userPref.userPrefEntity {
            dataManager.updateUserPreferencesValues(userPrefEntity: userPrefEntity, onSuccess: nil, onError: nil)
        }
        trackEvent(.save, parameters: [.textSearch: "\(budget)"])
        moduleCoordinator?.end()
    }
    
    func sliderTouchCancel() {
        trackEvent(.slide, parameters: [:])
    }
}

private extension GeneralBudgetPresenter {
    func loadMonthlyExpenses() {
        self.view?.loadingIsHidden(false)
        Scenario(useCase: getMonthlyBalanceUseCase)
            .execute(on: dependenciesResolver.resolve())
            .map { $0.data }
            .onSuccess { [weak self]  months in
                self?.loadBudget(months: months)
            }
            .onError { [weak self] _ in
                self?.setPfmBarsToZero()
            }
    }
}

extension GeneralBudgetPresenter: EditBudgetHelper {
    func loadBudget(months: [MonthlyBalanceRepresentable]) {
        self.months = months
        let editBudget = getEditBudgetData(userBudget: self.userPref.userPrefEntity?.getBudget(),
                                           threeMonthsExpenses: self.months,
                                           resolver: self.dependenciesResolver)
        view?.setBudget(editBudget)
        view?.loadingIsHidden(true)
    }
}

extension GeneralBudgetPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: GeneralBudgetPage {
        return GeneralBudgetPage()
    }
}

private extension GeneralBudgetPresenter {
    func setPfmBarsToZero() {
        let monthEntities: [MonthlyBalanceRepresentable] = [
            DefaultMonthlyBalance(date: Date().getDateByAdding(months: -2, ignoreHours: true), expense: 0.0, income: 0.0),
            DefaultMonthlyBalance(date: Date().getDateByAdding(months: -1, ignoreHours: true), expense: 0.0, income: 0.0),
            DefaultMonthlyBalance(date: Date(), expense: 0.0, income: 0.0)]
        let editBudget = self.getEditBudgetData(userBudget: self.userPref.userPrefEntity?.getBudget(),
                                           threeMonthsExpenses: monthEntities,
                                           resolver: self.dependenciesResolver)
        self.view?.setBudget(editBudget)
        self.view?.loadingIsHidden(true)
    }
}
