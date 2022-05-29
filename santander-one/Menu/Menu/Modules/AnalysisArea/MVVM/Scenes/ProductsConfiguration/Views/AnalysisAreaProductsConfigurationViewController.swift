//
//  AnalysisAreaProductsConfigurationViewController.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 15/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIOneComponents

final class AnalysisAreaProductsConfigurationViewController: UIViewController {
    
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    private let viewModel: AnalysisAreaProductsConfigurationViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaProductsConfigurationDependenciesResolver
    private var bankSelectedToDelete: ProducListConfigurationOtherBanksRepresentable?
    private let bottomSheet = BottomSheet()
    private var arrayProducts: [ProductListConfigurationRepresentable] = []
    private var otherBanksBottomSheetView = OtherBanksBottomSheetView()
    private var promptBottomSheetView = PromptAnalysisAreaBottomSheetView()
    private var scrollViewOffset: CGPoint = CGPoint(x: 0, y: 0)
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(15)
        return view
    }()
    private lazy var headerView: AnalysisAreaHeaderView = {
        let view = AnalysisAreaHeaderView()
        return view
    }()
    private lazy var stackProductsSections: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    private lazy var footerView: UIStackView = {
        let footer = UIStackView()
        return footer
    }()
    private lazy var spacer: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 94.0).isActive = true
        return view
    }()
    private lazy var loadingPreferencesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
     
    init(dependencies: AnalysisAreaProductsConfigurationDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "AnalysisAreaProductsConfigurationViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
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
        DispatchQueue.main.async { [weak self] in
            UIAccessibility.post(notification: .layoutChanged, argument: self?.navigationItem.titleView)
        }
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        viewModel.didTapContinue()
    }
}

private extension AnalysisAreaProductsConfigurationViewController {
    func configureViews() {
        configureFloatingButton()
        view.addSubview(scrollableStackView)
        configureScrollableStack()
        configureProductsStackView()
        configureFooterView()
        configureLoadingPreferencesViews()
    }
    
    func setAppearance() {}
    
    func bind() {
        bindViewModel()
        bindHeaderView()
        bindOtherBanksButtonSheet()
        bindMinimumProductsBottomSheet()
    }
    
    func bindViewModel() {
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.updateErrorReceived)
            .sink { [unowned self] _ in
                headerView.showUpdateError()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.networkErrorReceived)
            .sink { [unowned self] _ in
                headerView.showNetworkError()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.companiesInfoReceived)
            .sink { [unowned self] products in
                arrayProducts = products
                addProductsView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.updateButtonStatus)
            .sink { [unowned self] isEnabled in
                floatingButton.isEnabled = isEnabled
                setAccessibility(setViewAccessibility: setAccessibilityInfo)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.showMinimumProductsBottomSheet)
            .sink { [unowned self] _ in
                showMinimumProductsBottomSheet()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.updateProductsView)
            .sink { [unowned self] in
                updateProducts()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.showFullScreenLoader)
            .sink { [unowned self] in
                showFullScreenLoading()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.hideFullScreenLoader)
            .sink { [unowned self] completion in
                hideFullScreenLoading(completion: completion)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.loadingPreferences)
            .sink { [unowned self] loading in
                loading ? showPreferencesLoadingView() : hidePreferencesLoadingView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.showGenericError)
            .sink { [unowned self] goToPgWhenClose in
                showGenericError(goToPgWhenClose: goToPgWhenClose)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(AnalysisAreaProductsConfigurationState.updateFooterAndOtherBanksBottomSheet)
            .sink { [unowned self] showFooter, showUpdateBank in
                footerView.isHidden = !showFooter
                otherBanksBottomSheetView.updateUpdateBankButton(show: showUpdateBank)
            }.store(in: &subscriptions)
    }

    func bindHeaderView() {
        headerView
            .publisher
            .sink { [unowned self] _ in
                viewModel.didTapUpdateProducts()
            }.store(in: &subscriptions)
    }

    func bindOtherBanksButtonSheet() {
        otherBanksBottomSheetView
            .publisher
            .case(OtherBanksBottomSheetViewState.didTapUpdateButton)
            .sink { [unowned self] _ in
                self.dismiss(animated: true)
                viewModel.didTapUpdatePermissions()
            }.store(in: &subscriptions)

        otherBanksBottomSheetView
            .publisher
            .case(OtherBanksBottomSheetViewState.didTapDeleteBank)
            .sink { [unowned self] _ in
                guard let bankInfo = bankSelectedToDelete else { return }
                self.dismiss(animated: true)
                viewModel.didTapDeleteBank(bankInfo)
            }.store(in: &subscriptions)
    }
    
    func bindMinimumProductsBottomSheet() {
        promptBottomSheetView
            .publisher
            .sink { [unowned self] _ in
                self.dismiss(animated: true)
                self.viewModel.didTapMinimumProductsPopupAcceptButton()
            }.store(in: &subscriptions)
    }
    
    func showPreferencesLoadingView() {
        loadingPreferencesView.isHidden = false
    }
    
    func hidePreferencesLoadingView() {
        loadingPreferencesView.isHidden = true
    }
    
    func configureLoadingPreferencesViews() {
        self.view.addSubview(loadingPreferencesView)
        loadingPreferencesView.fullFit()
        loadingPreferencesView.isHidden = true
        let info = createLoadingInfoForCompaniesView(loadingPreferencesView)
        showLoadingOnViewWithLoading(info: info)
    }
    
    func createLoadingInfoForCompaniesView(_ view: UIView) -> LoadingInfo {
        let type = LoadingViewType.onView(view: view,
                                          frame: nil,
                                          position: .betweenTopAndCenter,
                                          controller: self)
        let text = LoadingText(title: localized("analysis_loading_savingPreferences"),
                               subtitle: localized("loading_label_moment"))
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

    func configureFloatingButton() {
        floatingButton.configureWith(type: .primary,
                                     size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized("generic_button_confirm"), icons: .none, fullWidth: false)),
                                     status: .ready)
        floatingButton.isEnabled = false
    }

    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_setting")
            .setAccessibilityTitleHint(hint: localized("voiceover_referencePoint"))
            .setLeftAction(.back, customAction: {
                self.viewModel.didTapBackOrCloseButton()
            })
            .setRightAction(.close, action: {
                self.viewModel.didTapBackOrCloseButton()
            })
            .build(on: self)
    }

    func configureScrollableStack() {
        scrollableStackView.setScrollDelegate(self)
        scrollableStackView.setup(with: self.view)
        scrollableStackView.addArrangedSubview(headerView)
        scrollableStackView.addArrangedSubview(stackProductsSections)
        scrollableStackView.addArrangedSubview(footerView)
        scrollableStackView.addArrangedSubview(spacer)
        self.view.bringSubviewToFront(floatingButton)
    }
    
    func configureProductsStackView() {
        stackProductsSections.axis = .vertical
        stackProductsSections.distribution = .fill
        stackProductsSections.alignment = .fill
    }
    
    func addProductsView() {
        deleteProducts()
        for products in arrayProducts {
            let productView = ProductListConfigurationView()
            productView.setupProductList(products)
            stackProductsSections.addArrangedSubview(productView)
            productView.publisher
                .case(ProductListConfigurationViewState.didTappedMoreOption)
                .sink { [unowned self] bankInfo in
                    bankSelectedToDelete = bankInfo
                    showOtherBanksBottomSheet()
                }.store(in: &subscriptions)

            productView.publisher
                .case(ProductListConfigurationViewState.optionDidChanged)
                .sink { [unowned self] model in
                    self.viewModel.didModifiedProductState(productId: model.productId ?? "0")
                }.store(in: &subscriptions)
            
            productView.publisher
                .case(ProductListConfigurationViewState.didTapReviewCredentials)
                .sink { [unowned self] _ in
                    viewModel.didTapUpdatePermissions()
                }.store(in: &subscriptions)
        }
    }
    
    func updateProducts() {
        stackProductsSections.subviews.forEach {
            if let productView = $0 as? ProductListConfigurationView {
                productView.updateProducts()
            }
        }
    }
    
    func deleteProducts() {
        stackProductsSections.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func configureFooterView() {
        footerView.axis = .horizontal
        footerView.alignment = .center
        let button = UIButton()
        button.setImage(Assets.image(named: "oneIcnAddCurrency")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(Assets.image(named: "oneIcnAddCurrency")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        button.tintColor = .oneDarkTurquoise
        button.imageEdgeInsets.left = -8
        button.setTitle(localized("analysis_button_addOtherBanks"), for: .normal)
        button.titleLabel?.font = UIFont.typography(fontName: .oneB300Bold)
        button.setTitleColor(.oneDarkTurquoise, for: .normal)
        button.setTitleColor(.oneTurquoise, for: .highlighted)
        button.addTarget(self, action: #selector(addOtherBanksDidTap), for: .touchUpInside)
        button.imageView?.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnAddCurrency
        button.titleLabel?.accessibilityIdentifier = AnalysisAreaAccessibility.btnAnalysisAddOtherBanks
        footerView.addArrangedSubview(button)
    }
    
    func showOtherBanksBottomSheet() {
        bottomSheet.show(in: self,
                         type: .custom(isPan: true, bottomVisible: false),
                         component: .all,
                         view: self.otherBanksBottomSheetView)
    }
    
    func showMinimumProductsBottomSheet() {
        bottomSheet.show(in: self,
                         type: .custom(isPan: true, bottomVisible: false),
                         component: .all,
                         view: self.promptBottomSheetView,
                         delegate: self)
    }
    
    @objc func addOtherBanksDidTap() {
        viewModel.didTapAddOtherBanks()
    }
    
    func showGenericError(goToPgWhenClose: Bool) {
        self.showGenericErrorDialog(withDependenciesResolver: dependencies.external.resolve()) {
            if goToPgWhenClose {
                self.viewModel.goToPG()
            }
        }
    }
    
    func createLoadingInfoForFullScreenLoading() -> LoadingInfo {
        let type = LoadingViewType.onScreen(controller: self, completion: nil)
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
    
    func showFullScreenLoading() {
        let info = createLoadingInfoForFullScreenLoading()
        self.showLoadingWithLoading(info: info)
    }
    
    func hideFullScreenLoading(completion: @escaping (() -> Void)) {
        self.dismissLoading(completion: completion)
    }
}

extension AnalysisAreaProductsConfigurationViewController: BottomSheetViewProtocol {
    func didTapCloseButton() {
        viewModel.didTapMinimumProductsPopupAcceptButton()
    }
    
    func setAccessibilityInfo() {
        floatingButton.accessibilityLabel = localized("generic_button_confirm")
        floatingButton.accessibilityHint = self.floatingButton.isEnabled ? localized("voiceover_activated") : localized("voiceover_deactivated")
    }
}

extension AnalysisAreaProductsConfigurationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollingToBottom = scrollViewOffset.y < scrollView.contentOffset.y
        let footerIsVisible = scrollView.contentOffset.y > (scrollView.contentSize.height - view.frame.maxY)
        if footerIsVisible && scrollingToBottom {
            scrollableStackView.scrollRectToVisible(spacer.frame, animated: true)
        }
        scrollViewOffset = scrollView.contentOffset
    }
}
extension AnalysisAreaProductsConfigurationViewController: GenericErrorDialogPresentationCapable {}
extension AnalysisAreaProductsConfigurationViewController: LoadingViewPresentationCapable {}
extension AnalysisAreaProductsConfigurationViewController: AccessibilityCapable {}
