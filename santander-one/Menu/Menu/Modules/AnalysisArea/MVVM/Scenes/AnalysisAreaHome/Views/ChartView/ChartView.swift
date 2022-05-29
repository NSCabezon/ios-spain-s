//
//  ChartView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 19/1/22.
//

import Foundation
import UI
import UIKit
import UIOneComponents
import OpenCombine
import CoreFoundationLib
import CoreDomain

enum ChartViewStates: State {
    case chartSectorSelected(_ sector: CategoryRepresentable)
    case chartTooltipSelected(_ message: (title: LocalizedStylableText, subtitle: LocalizedStylableText))
    case categoriesChanged(_ categories: AnalysisAreaCategoriesRepresentable)
}

final class ChartView: XibView {
    @IBOutlet private weak var filterView: OneFilterView!
    @IBOutlet private weak var filterParentView: UIView!
    @IBOutlet private weak var chartsCollectionView: ChartsCollectionView!
    private var subject = PassthroughSubject<ChartViewStates, Never>()
    public var publisher: AnyPublisher<ChartViewStates, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var subscriptions: Set<AnyCancellable> = []
    
    private var associatedTabCategory: [ExpensesIncomeCategoriesChartType] = [.expenses, .incomes]
    lazy var loadingSummaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .oneWhite
        return view
    }()
    @IBOutlet weak var piechart: InteractiveSectoredPieChartView!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setSummary(_ summary: [AnalysisAreaSummaryItemRepresentable]) {
        let representable = ChartViewRepresented(summary: summary)
        chartsCollectionView.setCollectionViewInfo(summary: representable)
    }
    
    func showLoadingSummaryView() {
        loadingSummaryView.isHidden = false
    }
    
    func hideSummaryLoadingView() {
        loadingSummaryView.isHidden = true
    }
}

private extension ChartView {
    func setupView() {
        setupLoadingViews()
        setupFilterView()
        bindChartCollectionView()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setupLoadingViews() {
        setupLoadingCategoryView()
    }
    
    func setupLoadingCategoryView() {
        self.chartsCollectionView.addSubview(loadingSummaryView)
        loadingSummaryView.fullFit()
        loadingSummaryView.isHidden = true
    }
    
    func setupFilterView() {
        filterParentView.clipsToBounds = true
        filterView.setupDouble(with: ["analysis_label_expenses", "analysis_label_income"])
        filterView.addTarget(self, action: #selector(didTapFilterTab(sender:)), for: .valueChanged)
    }
    
    @objc func didTapFilterTab(sender: OneFilterView) {
        chartsCollectionView.didTapFilterTab(to: sender.selectedSegmentIndex)
    }
    
    func bindChartCollectionView() {
        chartsCollectionView
            .publisher
            .case { ChartsCollectionViewState.shownChartChanged }
            .sink { [unowned self] categories in
                self.subject.send(.categoriesChanged(categories))
            }.store(in: &subscriptions)
        
        chartsCollectionView
            .publisher
            .case { ChartsCollectionViewState.tooltipTapped }
            .sink { [unowned self] message in
                self.subject.send(.chartTooltipSelected(message))
            }.store(in: &subscriptions)
        
        chartsCollectionView
            .publisher
            .case { ChartsCollectionViewState.chartSectorSelected }
            .sink { [unowned self] sectorData in
                self.subject.send(.chartSectorSelected(sectorData))
            }.store(in: &subscriptions)
    }
    
    func setAccessibilityInfo() {
        filterParentView.isAccessibilityElement = true
        filterParentView.accessibilityLabel = localized("voiceover_twoOptionsDifferentGraphics")
        accessibilityElements = [filterParentView, filterView, chartsCollectionView].compactMap {$0}
    }
}

extension ChartView: AccessibilityCapable {}
