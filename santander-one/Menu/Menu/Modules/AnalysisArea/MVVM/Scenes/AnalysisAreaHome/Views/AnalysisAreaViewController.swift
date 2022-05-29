//
//  AnalysisAreaViewController.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 4/1/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import UIOneComponents
import CoreFoundationLib
import CoreDomain

final class AnalysisAreaViewController: UIViewController {
    
    @IBOutlet weak var filterContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    private let viewModel: AnalysisAreaViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaHomeDependenciesResolver
    private lazy var oneFilterView: OneFilterView = {
        let view = OneFilterView(frame: .zero)
        view.setupDouble(with: ["analysis_label_expenditureAnalysis", "categorization_label_saving"],
                         accessibilityHints: ["", localized("generic_alert_notAvailableOperation")])
        view.addTarget(self, action: #selector(didChangeSegment(sender:)), for: .valueChanged)
        return view
    }()
    private lazy var intervalTimeAndTotalizatorView: IntervalTimeAndTotalizatorView = {
        let view = IntervalTimeAndTotalizatorView(frame: .zero)
        return view
    }()
    private lazy var chartView: ChartView = {
        let view = ChartView(frame: .zero)
        return view
    }()
    private lazy var listView: CategoriesListView = {
        let view = CategoriesListView(frame: .zero)
        return view
    }()
    private lazy var analysisAreaFooterView: AnalysisAreaFooterView = {
        let view = AnalysisAreaFooterView(frame: .zero)
        return view
    }()
    private lazy var loadingCompaniesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    private lazy var infoStatusView: InfoStatusView = {
        let view = InfoStatusView()
        return view
    }()
    private lazy var periodSelectorView: PeriodSelectorView = {
        let view = PeriodSelectorView()
        return view
    }()
    private let bottomSheet = BottomSheet()
    private lazy var promptSCABottomSheetView: PromptAnalysisAreaBottomSheetView = {
        let view = PromptAnalysisAreaBottomSheetView()
        view.setTitle(titleKey: "otpSCA_alert_title_safety", subtitleKey: "otpSCA_alert_text_safety")
        return view
    }()
    
    init(dependencies: AnalysisAreaHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "AnalysisAreaViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
}

private extension AnalysisAreaViewController {
    func setAppearance() {
        configureLoadingViews()
        configureScrollView()
        configureFilterView()
        configureIntervalTimeAndTotalizatorView()
        configureInfoStatusView()
        configurePeriodSelectorView()
        configureChartView()
        configureList()
        configureFooterView()
    }
    
    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_financialHealth")
            .setLeftAction(.back, customAction: goBack)
            .setRightAction(.search, action: openSearchView)
            .setRightAction(.menu, action: openPrivateMenu)
            .build(on: self)
    }
    
    func bind() {
        bindViewModel()
        bindCategories()
        bindIntervalTimeAndTotalizatorView()
        bindPeriodSelectorView()
        bindInfoStatusView()
        bindChartView()
        bindFooterView()
    }
    
    func bindViewModel() {
        viewModel.state
            .case(AnalysisAreaHomeState.loadingCompanies)
            .sink { [unowned self] show in
                show ? self.showCompaniesLoadingView() : self.hideCompaniesLoadingView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.loadingStatus)
            .sink { [unowned self] show in
                show ? infoStatusView.showGetStatusLoadingView() : infoStatusView.hideGetStatusLoadingView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.loadingSummary)
            .sink { [unowned self] show in
                show ? chartView.showLoadingSummaryView() : chartView.hideSummaryLoadingView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.showDataOutdatedAlert)
            .sink { [unowned self] _ in
                infoStatusView.showUpdateStatusErrorView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.showNetworkErrorAlert)
            .sink { [unowned self] _ in
                infoStatusView.showNetworkErrorView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.statusInfoReceived)
            .sink { [unowned self] representable in
                infoStatusView.setStatusInfo(representable)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.intervalTimeInfoReceived)
            .sink { [unowned self] data in
                intervalTimeAndTotalizatorView.setIntervalTimeData(data)
                periodSelectorView.updateInfo(userDataSelected: data)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.productsInfoReceived)
            .sink { [unowned self] data in
                intervalTimeAndTotalizatorView.setTotalizatorData(data)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.showGenericError)
            .sink { [unowned self] _ in
                showGenericError()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaHomeState.updateFooter)
            .sink { [unowned self] showAddOtherBanks in
                analysisAreaFooterView.updateAddOtherBanks(show: showAddOtherBanks)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case { AnalysisAreaHomeState.showMoreThan90daysPeriod }
            .sink { [unowned self] _ in
                bottomSheet.show(in: self,
                                 type: .custom(isPan: true, bottomVisible: false),
                                 component: .all,
                                 view: self.promptSCABottomSheetView)
            }.store(in: &subscriptions)
    }
    
    func bindIntervalTimeAndTotalizatorView() {
        intervalTimeAndTotalizatorView
            .publisher
            .filter { event in
                event == .didTapChangeButton }
            .sink { [unowned self] _ in
                self.viewModel.didTapChangeIntervalTime()
            }.store(in: &subscriptions)
        
        intervalTimeAndTotalizatorView
            .publisher
            .filter { event in
                event == .didTapEditTotalizator }
            .sink { [unowned self] _ in
                self.viewModel.didTapOpenConfiguration()
            }.store(in: &subscriptions)
    }
    
    func bindCategories() {
        viewModel.state
            .case(AnalysisAreaHomeState.summaryReceived)
            .sink { [unowned self] model in
                self.chartView.setSummary(model)
                self.listView.layoutIfNeeded()
            }.store(in: &subscriptions)
        bindCategoryTaps()
    }
    
    func bindCategoryTaps() {
        listView
            .publisher
            .sink { [unowned self] category in
                self.viewModel.didSelectCategory(category)
            }.store(in: &subscriptions)
    }
    
    func bindInfoStatusView() {
        infoStatusView
            .publisher
            .sink { [unowned self] action in
                viewModel.didTapUpdateInfoStatus(action)
            }.store(in: &subscriptions)
    }
    
    func bindChartView() {
        chartView
            .publisher
            .case(ChartViewStates.chartSectorSelected)
            .sink { [unowned self] _ in
                debugPrint("Sector Selected")
            }.store(in: &subscriptions)
        
        chartView
            .publisher
            .case(ChartViewStates.chartTooltipSelected)
            .sink { [unowned self] message in
                didTapOnTooltip(message: message)
            }.store(in: &subscriptions)
        chartView
            .publisher
            .case(ChartViewStates.categoriesChanged)
            .sink { [unowned self] categories in
                setCategoriesList(categories)
            }.store(in: &subscriptions)
    }
    
    func bindFooterView() {
        analysisAreaFooterView
            .publisher
            .case(AnalysisAreaFooterViewState.didTapConfigurationButton)
            .sink { [unowned self] _ in
                self.viewModel.didTapOpenConfiguration()
            }.store(in: &subscriptions)
        
        analysisAreaFooterView
            .publisher
            .case(AnalysisAreaFooterViewState.didTapAddNewBankButton)
            .sink { [unowned self] _ in
                self.viewModel.didTapAddNewBank()
            }.store(in: &subscriptions)
    }
    
    func bindPeriodSelectorView() {
        periodSelectorView
            .publisher
            .case(PeriodSelectorStates.didTapChangeDate)
            .sink { [unowned self] dateModel in
                viewModel.didChangePeriodSelected(dateModel)
            }.store(in: &subscriptions)
    }
    
    func didTapOnTooltip(message: (title: LocalizedStylableText, subtitle: LocalizedStylableText)) {
        viewModel.didTapToolTip(message)
    }
    
    func didChangeChartType(charType: ExpensesIncomeCategoriesChartType) {
        viewModel.didSelectChartType(charType)
    }
    
    @objc func didChangeSegment(sender: OneFilterView) {
        viewModel.didSelectOneFilterSegment(sender.selectedSegmentIndex)
    }
    
    @objc func openPrivateMenu() {
        viewModel.openPrivateMenu()
    }
    
    @objc func openSearchView() {
        viewModel.openSearchView()
    }
    
    @objc func goBack() {
        viewModel.goBack()
    }
    
    func createLoadingInfoForCompaniesView(_ view: UIView) -> LoadingInfo {
        let type = LoadingViewType.onView(view: view,
                                          frame: nil,
                                          position: .betweenTopAndCenter,
                                          controller: self)
        let text = LoadingText(title: localized("analysis_loading_collectingInfo"),
                               subtitle: localized("analisys_loading_soon"))
        let info = LoadingInfo(type: type,
                               loadingText: text,
                               loadingImageType: .jumps,
                               style: .bold,
                               gradientViewStyle: .topToBottom,
                               spacingType: .basic,
                               loaderAccessibilityIdentifier: AnalysisAreaAccessibility.analysisViewLoader,
                               titleAccessibilityIdentifier: AnalysisAreaAccessibility.analysisLoadingCollectingInfo,
                               subtitleAccessibilityIdentifier: AnalysisAreaAccessibility.analysisLoadingSoon)
        
        return info
    }
    
    func createLoadingInfoForSummaryView(_ view: UIView) -> LoadingInfo {
        let type = LoadingViewType.onView(view: view,
                                          frame: nil,
                                          position: .betweenTopAndCenter,
                                          controller: self)
        let text = LoadingText(title: localized("analysis_loading_collectingInfo"),
                               subtitle: localized("analisys_loading_soon"))
        let info = LoadingInfo(type: type,
                               loadingText: text,
                               loadingImageType: .jumps,
                               style: .bold,
                               gradientViewStyle: .solid,
                               spacingType: .basic,
                               loaderAccessibilityIdentifier: AnalysisAreaAccessibility.analysisViewLoader,
                               titleAccessibilityIdentifier: AnalysisAreaAccessibility.analysisLoadingCollectingInfo,
                               subtitleAccessibilityIdentifier: AnalysisAreaAccessibility.analysisLoadingSoon)
        
        return info
    }
  
    func showCompaniesLoadingView() {
        loadingCompaniesView.isHidden = false
    }
    
    func hideCompaniesLoadingView() {
        loadingCompaniesView.isHidden = true
    }
    
    func configureLoadingViews() {
        configureLoadingCompaniesView()
        configureLoadingSummaryView()
    }
    
    func configureLoadingCompaniesView() {
        self.view.addSubview(loadingCompaniesView)
        loadingCompaniesView.fullFit()
        loadingCompaniesView.isHidden = true
        let info = createLoadingInfoForCompaniesView(loadingCompaniesView)
        showLoadingOnViewWithLoading(info: info)
    }
    
    func configureLoadingSummaryView() {
        let info = createLoadingInfoForSummaryView(chartView.loadingSummaryView)
        showLoadingOnViewWithLoading(info: info)
    }
    
    func configureScrollView() {
        scrollView.delegate = self
    }
    
    func configureFilterView() {
        filterContentView.backgroundColor = .oneWhite
        filterContentView.addSubview(oneFilterView)
        oneFilterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            oneFilterView.topAnchor.constraint(equalTo: filterContentView.topAnchor, constant: 4),
            oneFilterView.bottomAnchor.constraint(equalTo: filterContentView.bottomAnchor, constant: -16),
            oneFilterView.leadingAnchor.constraint(equalTo: filterContentView.leadingAnchor, constant: 16),
            filterContentView.trailingAnchor.constraint(equalTo: oneFilterView.trailingAnchor, constant: 16)
        ])
    }
    
    func configureIntervalTimeAndTotalizatorView() {
        stackView.addArrangedSubview(intervalTimeAndTotalizatorView)
    }
    
    func configureChartView() {
        stackView.addArrangedSubview(chartView)
    }
    
    func configureList() {
        stackView.addArrangedSubview(listView)
    }
    
    func configureFooterView() {
        stackView.addArrangedSubview(analysisAreaFooterView)
    }
    
    func configureInfoStatusView() {
        stackView.addArrangedSubview(infoStatusView)
    }
    
    func configurePeriodSelectorView() {
        stackView.addArrangedSubview(periodSelectorView)
    }
    
    func setAccessibilityInfo() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func setCategoriesList(_ categories: AnalysisAreaCategoriesRepresentable) {
        listView.setCategoriesListInfo(summary: categories)
        listView.layoutIfNeeded()
    }
    
    func showGenericError() {
        self.showGenericErrorDialog(withDependenciesResolver: dependencies.external.resolve(),
                                    closeAction: self.viewModel.goBack)
    }
}

extension AnalysisAreaViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            filterContentView.setOneShadows(type: .oneShadowLarge)
            self.view.bringSubviewToFront(filterContentView)
        } else {
            filterContentView.setOneShadows(type: .none)
        }
    }
}

extension AnalysisAreaViewController: AccessibilityCapable {}
extension AnalysisAreaViewController: LoadingViewPresentationCapable {}
extension AnalysisAreaViewController: GenericErrorDialogPresentationCapable {}
extension AnalysisAreaViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return PrivateMenuOptions.analysisArea
    }
}
