//
//  ExpensesAnalysisPresenter.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 8/6/21.
//

import CoreFoundationLib

protocol ExpensesAnalysisPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: ExpensesAnalysisViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didTapOnFilter()
    func didTapOnConfig()
    func didSelectSegmentType(_ type: ExpensesIncomeCategoriesView.AnalysisCategoryType)
    func didSelectCategoryDetail(_ category: ExpensesIncomeCategoryType, chartType: ExpensesIncomeCategoriesChartType)
    func trackSwipeFor(chartType: ExpensesIncomeCategoriesChartType)
}

final class ExpensesAnalysisPresenter {
    weak var view: ExpensesAnalysisViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private weak var coordinator: OldAnalysisAreaCoordinatorProtocol? {
        return self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension ExpensesAnalysisPresenter: ExpensesAnalysisPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
    }
    
    func viewWillAppear() {
        self.view?.setTimeText(configuration.titleText, subtitleText: configuration.typeText)
    }
    
    func didTapOnFilter() {
        self.coordinator?.showTimePeriodSelector()
    }
    
    func didTapOnConfig() {
        self.coordinator?.showExpensesAnalysisConfiguration()
    }
    
    func didSelectSegmentType(_ type: ExpensesIncomeCategoriesView.AnalysisCategoryType) {
        switch type {
        case .income:
            self.trackEvent(.selectIncome)
        case .expenses:
            self.trackEvent(.selectExpenses)
        }
    }
    
    func didSelectCategoryDetail(_ category: ExpensesIncomeCategoryType, chartType: ExpensesIncomeCategoriesChartType) {
        self.trackerManager.trackEvent(screenId: trackerPage.page, eventId: "category_\(category.trackerIdentifier)_\(chartType.trackerString)", extraParameters: [:])
        self.coordinator?.didSelectCategoriesDetail(category)
    }
    
    func trackSwipeFor(chartType: ExpensesIncomeCategoriesChartType) {
        switch chartType {
        case .expenses:
            self.trackEvent(.swipeExpenses)
        case .payments:
            self.trackEvent(.swipeBuyings)
        default: break
        }
    }
}

extension ExpensesAnalysisPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve()
    }
    
    var trackerPage: ExpensesAnalysisPage {
        return ExpensesAnalysisPage()
    }
}

private extension ExpensesAnalysisPresenter {
    var configuration: TimePeriodConfiguration {
        return self.dependenciesResolver.resolve(for: TimePeriodConfiguration.self)
    }
}
