//
//  AnalysisAreaCategoryDetailViewController.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 29/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents

final class AnalysisAreaCategoryDetailViewController: UIViewController {
    @IBOutlet private weak var transactionView: FHTransactionsView!
    private let viewModel: AnalysisAreaCategoryDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaCategoryDetailDependenciesResolver
    private let bottomSheet = BottomSheet()
    private var bottomSheetView = PromptAnalysisAreaBottomSheetView()
    private var categoryTitleSelected: String?
    private lazy var headerView: CategoryDetailHeaderView = {
        return CategoryDetailHeaderView()
    }()
    private let scaBottomSheet = BottomSheet()
    private lazy var promptSCABottomSheetView: PromptAnalysisAreaBottomSheetView = {
        let view = PromptAnalysisAreaBottomSheetView()
        view.setTitle(titleKey: "otpSCA_alert_title_safety", subtitleKey: "otpSCA_alert_text_safety")
        return view
    }()
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    private var filterViewModel: AnalysisAreaFilterModelRepresentable?
    
    init(dependencies: AnalysisAreaCategoryDetailDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "AnalysisAreaCategoryDetailViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        configureViews()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transactionView.layoutSubviews()
    }
}

private extension AnalysisAreaCategoryDetailViewController {
    func setAppearance() {}
    
    func configureViews() {
        configureTransactionsView()
        configureMinimumSubcategoriesBottomSheet()
        configureLoadingPreferencesViews()
    }
    
    func bind() {
        bindViewModel()
        bindHeaderView()
        bindMinimumProductsBottomSheet()
        bindPromptSCABottomSheetView()
        bindPagination()
    }
    
    func configureNavigationBar() {
        let title = categoryTitleSelected ?? ""
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: title)
            .setLeftAction(.back)
            .setRightAction(.search, action: {
                self.viewModel.didTapSearch()
            })
            .setRightAction(.menu, action: {
                self.viewModel.didTapMenu()
            })
            .build(on: self)
    }
    
    func configureTransactionsView() {
        transactionView.setupHeaderView(headerView)
    }
    
    func configureMinimumSubcategoriesBottomSheet() {
        bottomSheetView.setTitle(titleKey: "analysis_title_selectSubcategory",
                                 subtitleKey: "analysis_text_selectSubcategory")
        bottomSheetView.enableButton(true)
    }
    
    func configureExpectedTooltipBottomSheet() {
        bottomSheetView.setTitle(titleKey: "analysis_label_forecastExpense",
                                 subtitleKey: "analysis_text_expenseForecast")
        bottomSheetView.enableButton(false)
    }
    
    func showLoadingView() {
        loadingView.isHidden = false
    }
    
    func hideLoadingView() {
        loadingView.isHidden = true
    }
    
    func configureLoadingPreferencesViews() {
        self.view.addSubview(loadingView)
        loadingView.fullFit()
        loadingView.isHidden = true
        let info = createLoadingInfoForCompaniesView(loadingView)
        showLoadingOnViewWithLoading(info: info)
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
    
    func showBottomSheet() {
        bottomSheet.show(in: self,
                         type: .custom(isPan: true, bottomVisible: false, tapOutsideDismiss: true),
                         component: .all,
                         view: self.bottomSheetView)
    }
    
    func setListFilters(_ filter: AnalysisAreaFilterModelRepresentable) {
        self.filterViewModel = filter
        if filter.filtersCount > 0 {
            self.setTagsOnHeader()
        } else {
            self.filterViewModel = nil
            self.tagsContainerView?.removeFromSuperview()
        }
    }
    
    func setTagsOnHeader() {
        guard let filterViewModel = filterViewModel else { return }
        self.tagsContainerView?.removeFromSuperview()
        let tagsMetadata = filterViewModel.buildTags()
        self.headerView.addTagContainer(withTags: tagsMetadata)
    }
    
    var tagsContainerView: OneTagsContainerView? {
        return self.headerView.getTagsContainerView()
    }
}

private extension AnalysisAreaCategoryDetailViewController {
    func bindViewModel() {
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.updateTransactions)
            .sink { [unowned self] transactions in
                self.transactionView.layoutIfNeeded()
                self.transactionView.setTransactions(transactions)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.updateNumberOfTransactions)
            .sink { [unowned self] numberOfTransactions in
                self.headerView.updateNumberOfMovements(numberOfTransactions)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.updateCategoryInfoTitle)
            .sink { [unowned self] title in
                self.categoryTitleSelected = title
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.didUpdateGraphData)
            .sink { [headerView] graphData in
                headerView.setGraphInfo(graphData)
                self.hideLoadingView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.updateTotalizatorAndSubcategoriesFilter)
            .sink { [headerView] totalizatorAndSubcategoriesData in
                headerView.setTotalizatorAndSubcategoriesFilterInfo(totalizatorAndSubcategoriesData)
            }.store(in: &subscriptions)
        
        viewModel.state
        .case(AnalysisAreaCategoryDetailState.showFullTransactionLoader)
            .sink { [unowned self] _ in
                self.transactionView.showFullLoader()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case { AnalysisAreaCategoryDetailState.didRequestedPrior90daysMovement }
            .sink { [unowned self] _ in
                showSCABottomSheet()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.filters)
            .sink { [unowned self] filters in
                self.setListFilters(filters)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.isFilterApplied)
            .sink { [unowned self] isFilterApplied in
                self.headerView.filterIsApplied(isFilterApplied)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.showLoading)
            .sink { [unowned self] _ in
                showLoadingView()
            }.store(in: &subscriptions)
    }
    
    func bindHeaderView() {
        headerView.publisher
            .case(CategoryDetailHeaderViewState.didTappedPdf)
            .sink { [unowned self] _ in
                self.viewModel.didTapPDF()
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case(CategoryDetailHeaderViewState.didTappedFilter)
            .sink { [unowned self] _ in
                self.viewModel.didTapFilters()
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case(CategoryDetailHeaderViewState.didChangeHeaderHeight)
            .sink { [unowned self] _ in
                self.headerView.layoutIfNeeded()
                self.transactionView.didChangeHeaderHeight()
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case { CategoryDetailHeaderViewState.didSelectGraphBar }
            .sink { [viewModel] barIndex in
                viewModel.didSelectGraphPeriod(index: barIndex)
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case(CategoryDetailHeaderViewState.didSelectSubcategories)
            .sink { [unowned self] subcategoriesSelected in
                self.viewModel.didUpdateCheckedSubcategories(subcategories: subcategoriesSelected)
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case(CategoryDetailHeaderViewState.showMinimunBottomSheet)
            .sink { [unowned self] _ in
                configureMinimumSubcategoriesBottomSheet()
                showBottomSheet()
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case(CategoryDetailHeaderViewState.didTappedExpectedTooltip)
            .sink { [unowned self] _ in
                configureExpectedTooltipBottomSheet()
                showBottomSheet()
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case { CategoryDetailHeaderViewState.removeAllFilter }
            .sink { [unowned self] _ in
                // eliminar todos
                self.filterViewModel = nil
                self.viewModel.removeAllFilters()
            }
            .store(in: &subscriptions)
        
        headerView.publisher
            .case { CategoryDetailHeaderViewState.removeFilter }
            .sink { [unowned self] tags in
                let filter = self.filterViewModel?.filterActivesFrom(remainingFilters: tags)
                self.viewModel.removeFilter(filter)
            }
            .store(in: &subscriptions)
    }
    
    func bindPromptSCABottomSheetView() {
        promptSCABottomSheetView
            .publisher
            .sink { [unowned self] _ in
                self.dismiss(animated: true) {
                    viewModel.showSCAProcess()
                }
            }.store(in: &subscriptions)
    }
    
    func bindPagination() {
        viewModel.state
            .case(AnalysisAreaCategoryDetailState.isPaginationLoading)
            .sink {[unowned self] show in
                show ? self.transactionView.showPaginationLoading() : self.transactionView.hidePaginationLoading()
            }.store(in: &subscriptions)
        
        transactionView.paginationSubject
            .sink {[unowned self]  in
                self.viewModel.loadMoreTransactions()
            }.store(in: &subscriptions)
    }
    
    func showSCABottomSheet() {
        scaBottomSheet.show(in: self,
                         type: .custom(isPan: true, bottomVisible: false),
                         component: .all,
                         view: self.promptSCABottomSheetView, delegate: self)
    }
    func bindMinimumProductsBottomSheet() {
        bottomSheetView
            .publisher
            .sink { [unowned self] _ in
                self.dismiss(animated: true)
            }.store(in: &subscriptions)
    }
}

extension AnalysisAreaCategoryDetailViewController: UIScrollViewDelegate {}
extension AnalysisAreaCategoryDetailViewController: LoadingViewPresentationCapable {}
extension AnalysisAreaCategoryDetailViewController: BottomSheetViewProtocol {
    func didTapCloseButton() {
        viewModel.didCloseSCABottomSheet()
    }
}
