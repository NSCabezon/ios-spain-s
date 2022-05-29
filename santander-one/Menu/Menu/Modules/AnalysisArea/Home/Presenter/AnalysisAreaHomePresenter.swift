//
//  AnalysisAreaHomePresenter.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 7/6/21.
//
import CoreFoundationLib

protocol AnalysisAreaHomePresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: OldAnalysisAreaHomeViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSegment(_ type: OldAnalysisAreaHomeViewController.SegmentedType)
    func searchButtonPressed()
}

final class AnalysisAreaHomePresenter {
    let dependenciesResolver: DependenciesResolver
    weak var view: OldAnalysisAreaHomeViewProtocol?
    
    private var segmentedIndex: OldAnalysisAreaHomeViewController.SegmentedType
    
    init(dependenciesResolver: DependenciesResolver, segmentedIndex: OldAnalysisAreaHomeViewController.SegmentedType = .expenseAnalysis) {
        self.dependenciesResolver = dependenciesResolver
        self.segmentedIndex = segmentedIndex
    }
}

extension AnalysisAreaHomePresenter: AnalysisAreaHomePresenterProtocol {
    func viewDidLoad() {
        loadIsSearchEnabled()
        view?.setSegmentedControlView(
            list: self.segmentedTitles,
            accessibilityIdentifiers: self.segmentedAccessibilityIdentifiers
        )
        view?.selectSegmentTo(self.segmentedIndex)
    }
    
    func didSelectMenu() {
        coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectSegment(_ type: OldAnalysisAreaHomeViewController.SegmentedType) {
        self.segmentedIndex = type
        view?.selectSegmentTo(type)
    }
    
    func searchButtonPressed() {
        self.coordinatorDelegate.didSelectSearch()
    }
}

private extension AnalysisAreaHomePresenter {
    var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    private var segmentedTitles: [String] {
        return ["analysis_label_expenditureAnalysis", "analysis_label_savingsHealth"]
    }
    private var segmentedAccessibilityIdentifiers: [String] {
        return [AccessibilityExpensesAnalysisHome.expenditureSegmented, AccessibilityExpensesAnalysisHome.savingsHealthSegmented]
    }
}

extension AnalysisAreaHomePresenter: GlobalSearchEnabledManagerProtocol {
    private func loadIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] resp in
            self?.view?.isSearchEnabled = resp
        }
    }
}
