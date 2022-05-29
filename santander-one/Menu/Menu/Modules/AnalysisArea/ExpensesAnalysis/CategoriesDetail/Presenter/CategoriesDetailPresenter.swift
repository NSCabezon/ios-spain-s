//
//  CategoriesDetailPresenter.swift
//  Menu
//
//  Created by David Gálvez Alonso on 29/06/2021.
//

import CoreFoundationLib

protocol CategoriesDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: CategoriesDetailViewProtocol? { get set }
    func viewWillAppear()
    func didSelectDismiss()
    func didSelectMenu()
    func didTapOnConfig()
    func didSelectedSubcategory(_ subcategory: String)
    func didSelectedTimePeriod(_ periodViewModel: TimePeriodTotalAmountFilterViewModel)
    func didTapOnFilter()
    func removeFilter(_ filter: ActiveFilters?)
    func didTapOnPeriodSelector()
}

final class CategoriesDetailPresenter {
    weak var view: CategoriesDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    private var filter = DetailFilter()
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension CategoriesDetailPresenter: CategoriesDetailPresenterProtocol {
    
    func viewWillAppear() {
        self.view?.setListViewModel(CategoriesDetailViewModel(category: configuration.category, filter: CategoryDetailFilterViewModel(filter), timePeriodConfiguration: timeConfiguration))
        self.view?.setHeaderTexts(timeConfiguration.titleText, subtitleText: timeConfiguration.typeText)
    }
    
    func didSelectedTimePeriod(_ periodViewModel: TimePeriodTotalAmountFilterViewModel) {
        self.filter.setTimeFilter(periodViewModel)
        self.reloadTransactions()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didTapOnConfig() {
        self.coordinator.showExpensesAnalysisConfiguration()
    }
    
    func didSelectedSubcategory(_ subcategory: String) {
        self.filter.setSubcategory(subcategory)
        self.reloadTransactions()
    }
    
    func didTapOnFilter() {
        self.coordinator.didTapOnFilter(filterDelegate: self)
    }
    
    func removeFilter(_ filter: ActiveFilters?) {
        let newFilter = DetailFilter(cloning: self.filter)
        guard let filter = filter else {
            let cleanFilter = DetailFilter()
            cleanFilter.setSubcategory(newFilter.getSubcategory())
            self.filter = cleanFilter
            return
        }
        newFilter.removeFilter(filter)
        self.filter = newFilter
        self.reloadTransactions()
    }
    
    func reloadTransactions() {
        let viewModel = CategoriesDetailViewModel(category: configuration.category, filter: CategoryDetailFilterViewModel(filter), timePeriodConfiguration: timeConfiguration)
        self.view?.setListViewModel(viewModel)
        self.view?.setHeaderTexts(viewModel.timePeriodConfiguration.titleText, subtitleText: viewModel.periodText ?? viewModel.timePeriodConfiguration.typeText)
    }
    
    func didTapOnPeriodSelector() {
        self.coordinator.showTimePeriodSelector()
    }
}

extension CategoriesDetailPresenter: ExpensesIncomeFilterDelegate {
    func getFilters() -> DetailFilter {
        return filter
    }
    
    func didApplyFilters(_ filters: DetailFilter) {
        self.filter = filters
        self.reloadTransactions()
    }
}

private extension CategoriesDetailPresenter {
    var coordinator: CategoriesDetailCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: CategoriesDetailCoordinatorProtocol.self)
    }
    
    var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    var configuration: CategoriesDetailConfiguration {
        return self.dependenciesResolver.resolve(for: CategoriesDetailConfiguration.self)
    }
    
    var timeConfiguration: TimePeriodConfiguration {
        return self.dependenciesResolver.resolve(for: TimePeriodConfiguration.self)
    }
}
