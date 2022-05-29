//
//  ChartsCollectionView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 3/2/22.
//

import UIKit
import UI
import OpenCombine
import CoreFoundationLib
import CoreMIDI

enum ChartsCollectionViewState: State {
    case shownChartChanged(_ categories: AnalysisAreaCategoriesRepresentable)
    case tooltipTapped(_ message: (title: LocalizedStylableText, subtitle: LocalizedStylableText))
    case chartSectorSelected(CategoryRepresentable)
}

protocol ChartsCollectionViewRepresentable {
    var tabData: [Int: [AnalysisAreaCategoriesRepresentable]] { get }
}

final class ChartsCollectionView: XibView {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    private var subscriptions: Set<AnyCancellable> = []
    private var subject = PassthroughSubject<ChartsCollectionViewState, Never>()
    public var publisher: AnyPublisher<ChartsCollectionViewState, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var dataSource: [Int: [AnalysisAreaCategoriesRepresentable]] = [:] {
        didSet {
            guard let categories = (dataSource[0]?[0]) else { return }
            subject.send(.shownChartChanged(categories))
        }
    }
    private var tootlipMessages: [(title: LocalizedStylableText, subtitle: LocalizedStylableText)] {
        return [(title: localized("analysis_title_tooltipExpenses"), subtitle: localized("analysis_text_tooltipExpenses")),
         (title: localized("analysis_title_tooltipPayments"), subtitle: localized("analysis_text_tooltipPayments"))]
    }
    private var selectedTab: Int = 0 {
        didSet {
            toggleTab()
        }
    }
    private var selectedChart: Int = 0 {
        didSet {
            switchChart()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setCollectionViewInfo(summary: ChartsCollectionViewRepresentable) {
        self.dataSource = summary.tabData
        self.collectionView.reloadData()
    }
    
    func didTapFilterTab(to index: Int) {
        self.selectedTab = index
    }
    
    @IBAction func pageControlValueChange(_ sender: Any) {
        selectedChart = pageControl.currentPage
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
}

private extension ChartsCollectionView {
    func setupView() {
        collectionView.backgroundColor = .oneWhite
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = currentNumberOfPages
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .oneLisboaGray
        pageControl.pageIndicatorTintColor = .oneMediumSkyGray
        let nib = UINib(nibName: chartCellidentifier, bundle: .module)
        collectionView.register(nib, forCellWithReuseIdentifier: chartCellidentifier)
        let emptyCellNib = UINib(nibName: emptyChartCellIdentifier, bundle: .module)
        collectionView.register(emptyCellNib, forCellWithReuseIdentifier: emptyChartCellIdentifier)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func toggleTab() {
        if selectedTab == 1 {
            pageControl.currentPage = 0
            pageControl.numberOfPages = currentNumberOfPages
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            guard let categories = dataSource[selectedTab]?[0] else { return }
            subject.send(.shownChartChanged(categories))
            layoutSubviews()
            collectionView.reloadData()
        } else if selectedTab == 0 {
            pageControl.numberOfPages = currentNumberOfPages
            selectedChart = 0
            switchChart()
        }
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func switchChart() {
        pageControl.currentPage = selectedChart
        layoutSubviews()
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: selectedChart, section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
        guard let categories = dataSource[selectedTab]?[selectedChart] else { return }
        subject.send(.shownChartChanged(categories))
    }
    
    func configureChartCell(_ cell: ChartCollectionViewCell?, indexPath: IndexPath) {
        guard let info = dataSource[selectedTab]?[indexPath.row] else { return }
        let tooltipLabelKey = selectedTab == 0 ? getTooltipLabelKey(for: indexPath.row) : nil
        let cellRepresentable = ChartCellRepresentation(tooltipLabelKey: tooltipLabelKey, chartData: info.chartCategories)
        let isVisible = selectedTab == 1 || (indexPath.item == self.selectedChart)
        cell?.setCellInfo(cellRepresentable, isVisible: isVisible)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func getTooltipLabelKey(for row: Int) -> String {
        if selectedTab == 1 {
            return ""
        }
        return row == 0 ? "analysis_label_infoExpenses" : "analysis_label_infoPurchases"
    }
    
    func bind(cell: ChartCollectionViewCell?, at indexPath: IndexPath) {
        cell?
            .publisher
            .case { ChartCollectionViewCellState.didSelectSector }
            .sink { [unowned self] sectorData in
            subject.send(.chartSectorSelected(sectorData))
        }.store(in: &subscriptions)
        
        cell?
            .publisher
            .case { ChartCollectionViewCellState.didTapToolTip }
            .sink { [unowned self] _ in
            subject.send(.tooltipTapped(tootlipMessages[indexPath.row]))
        }.store(in: &subscriptions)
    }
    
    func bind(cell: EmptyChartCollectionViewCell?, at indexPath: IndexPath) {
        cell?
            .publisher
            .case { ChartCollectionViewCellState.didTapToolTip }
            .sink { [unowned self] _ in
            subject.send(.tooltipTapped(tootlipMessages[indexPath.row]))
        }.store(in: &subscriptions)
    }

    func setAccessibilityInfo() {
        let goToPaymentsVoiceOver: String = localized("voiceover_swipeUpSeePayments")
        let goToExpensesVoiceOver: String = localized("voiceover_swipeDownSeeExpenses")
        pageControl.accessibilityValue = pageControl.currentPage == 0 ? goToPaymentsVoiceOver : goToExpensesVoiceOver
        let visibleChartIndex = getVisibleChartIndex() ?? 0
        if visibleChartIndex < collectionView.visibleCells.count {
            self.accessibilityElements = [collectionView.visibleCells[safe: visibleChartIndex], pageControl].compactMap {$0}
        } else {
            self.accessibilityElements = [collectionView.subviews[safe: selectedChart], pageControl].compactMap {$0}
        }
    }
    
    func getVisibleChartIndex() -> Int? {
        if selectedTab == 0 {
            switch pageControl.currentPage {
            case 0:
                return 1
            default:
                return 0
            }
        }
        return 0
    }
}

extension ChartsCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    private var currentNumberOfPages: Int {
        selectedTab == 0 ? 2 : 1
    }
    
    private var chartCellidentifier: String {
        String(describing: type(of: ChartCollectionViewCell()))
    }
    
    private var emptyChartCellIdentifier: String {
        String(describing: type(of: EmptyChartCollectionViewCell()))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentNumberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let info = dataSource[selectedTab]?[indexPath.row], !info.chartCategories.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chartCellidentifier, for: indexPath) as? ChartCollectionViewCell
            configureChartCell(cell, indexPath: indexPath)
            bind(cell: cell, at: indexPath)
            return cell ?? UICollectionViewCell()
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyChartCellIdentifier, for: indexPath) as? EmptyChartCollectionViewCell
            let isVisible = selectedTab == 1 || (indexPath.item == self.selectedChart)
            let categories = dataSource[selectedTab]?[indexPath.row]
            let info = dataSource[selectedTab]?[indexPath.row]
            let literalKey = (info?.oppositeSignCategoriesCount ?? 0 > 0) ? "analysis_label_emptyMovesPositive" : "analysis_label_emptyMovesNegative"
            cell?.setCellInto("analysis_label_emptyMovesNegative", tooltipLabelKey: getTooltipLabelKey(for: indexPath.row), isVisible: isVisible)
            bind(cell: cell, at: indexPath)
            return cell ?? UICollectionViewCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - width/2) / width) + 1)
        let shouldReload = page != pageControl.currentPage
        self.pageControl.currentPage = page
        if shouldReload {
            guard let categories = dataSource[selectedTab]?[safe: page] else { return }
            subject.send(.shownChartChanged(categories))
            selectedChart = page
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        changeFocusToVisibleChart()
    }
    
    func changeFocusToVisibleChart() {
        let chartVisibleIndex = getVisibleChartIndex() ?? 0
        if let chartVisible = collectionView.visibleCells[safe: chartVisibleIndex] {
            DispatchQueue.main.async {
                UIAccessibility.post(notification: .layoutChanged, argument: chartVisible)
            }
        }
    }
}

extension ChartsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 327, height: 362)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard !(selectedTab == 1) else {
            let cellCount = selectedTab == 1 ? 1 : 2
            let totalCellWidth = 327 * cellCount
            let totalSpacingWidth = 13 * (cellCount - 1)
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            return UIEdgeInsets(top: 16, left: leftInset, bottom: 16, right: rightInset)
        }
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

extension ChartsCollectionView: AccessibilityCapable {}
