//
//  FundsHomeViewController.swift
//  Funds
//
import UI
import UIKit
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIOneComponents

private enum FundsHomeIdentifiers {
    static let fundCell = "FundCollectionViewCell"
}

public protocol FundsHomeOperativeSource: UIViewController {}

final class FundsHomeViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var carouselContainerView: FundProductsHeaderView!
    @IBOutlet private weak var compressedHeaderView: CompressedFundsHomeHeaderView!
    @IBOutlet private weak var compressedHeaderViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var detailsHeaderView: UIView!
    @IBOutlet private weak var detailsHeaderLabel: UILabel!
    @IBOutlet private weak var detailContainerView: FundDetailView!
    @IBOutlet private weak var lastMovementsHeaderView: UIView!
    @IBOutlet private weak var lastMovementsLabel: UILabel!
    @IBOutlet private weak var lastMovementsContainerView: FundLastMovementsView!
    @IBOutlet private weak var showDetailsButton: UIButton!
    @IBOutlet private weak var showLastMovementsButton: UIButton!

    private let viewModel: FundHomeViewModel
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: FundsHomeDependenciesResolver
    private let scrollViewDelegate = ScrollViewDelegate()
    private var fullScreenLoading: LoadingActionProtocol?

    private lazy var fundsCollectionView: FundsHomeCollectionView = {
        return self.carouselContainerView.collectionView
    }()

    private var fundsHomeHeaderModifier: FundsHomeHeaderModifier? {
        self.dependencies.external.resolve()
    }

    private var isDetailExpanded: Bool { !detailContainerView.isHidden }

    private var isLoadingFullScreen: Bool {
        didSet {
            isLoadingFullScreen ?
                configureAndShowFullScreenLoading() :
                fullScreenLoading?.hideLoading(completion: nil)
        }
    }

    init(dependencies: FundsHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.isLoadingFullScreen = false
        super.init(nibName: "FundsHomeViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAccessibilityIdentifiers()
        setAccessibility { [weak self] in
            self?.setAccessibilityLabels()
        }
        self.setAppearance()
        self.scrollView.delegate = self.scrollViewDelegate
        self.detailsHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showDetails)))
        self.lastMovementsHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showLastMovements)))
        self.detailContainerView.delegate = self
        self.bind()
        self.viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    @IBAction func showDetails(_ sender: Any) {
        let newIsHidden = !self.detailContainerView.isHidden
        if !newIsHidden,
           let lastUnexpandedFund = detailContainerView.fund {
            viewModel.needsToLoadDetail(lastUnexpandedFund)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.changeSectionVisibility(isHidden: newIsHidden, view: self?.detailContainerView, headerButton: self?.showDetailsButton)
        }
        setAccessibility { [weak self] in
            self?.setAccessibilityLabels()
        }
    }

    @IBAction func showLastMovements(_ sender: Any) {
        let newIsHidden = !self.lastMovementsContainerView.isHidden
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.changeSectionVisibility(isHidden: newIsHidden, view: self?.lastMovementsContainerView, headerButton: self?.showLastMovementsButton)
        }
        setAccessibility { [weak self] in
            self?.setAccessibilityLabels()
        }
    }
}
private extension FundsHomeViewController {
    func setAppearance() {
        self.view.backgroundColor = .white
        self.detailsHeaderLabel.text = localized("funds_title_details")
        self.detailsHeaderLabel.font = .santander(family: .headline, type: .bold, size: 20)
        self.lastMovementsLabel.text = localized("funds_title_ordersTransactions")
        self.lastMovementsLabel.font = .santander(family: .headline, type: .bold, size: 20)
        self.changeSectionVisibility(isHidden: true, view: self.detailContainerView, headerButton: self.showDetailsButton, initialSetUp: true)
        self.changeSectionVisibility(isHidden: false, view: self.lastMovementsContainerView, headerButton: self.showLastMovementsButton, initialSetUp: true)
    }

    func setAccessibilityIdentifiers() {
        detailsHeaderView.accessibilityIdentifier = AccessibilityIdFundHome.fundsBgDetails.rawValue
        detailsHeaderLabel.accessibilityIdentifier = AccessibilityIdFundHome.fundsTitleDetails.rawValue
        showDetailsButton.accessibilityIdentifier = AccessibilityIdFundHome.icnArrowUp.rawValue
        showDetailsButton.isAccessibilityElement = true
        showDetailsButton.accessibilityTraits = .button
        lastMovementsHeaderView.accessibilityIdentifier = AccessibilityIdFundHome.fundsBgOrders.rawValue
        lastMovementsLabel.accessibilityIdentifier = AccessibilityIdFundHome.fundsTitleOrdersTransactions.rawValue
        showLastMovementsButton.accessibilityIdentifier = AccessibilityIdFundHome.icnArrowUp.rawValue
        showLastMovementsButton.isAccessibilityElement = true
        showLastMovementsButton.accessibilityTraits = .button
    }

    func setAccessibilityLabels() {
        let detailsButtonState = StringPlaceholder(.value, detailContainerView.isHidden ? localized("voiceover_folded") : localized("voiceover_unfolded"))
        showDetailsButton.accessibilityLabel = localized("voiceover_detailsFund", [detailsButtonState]).text
        let transactionsButtonState = StringPlaceholder(.value, lastMovementsContainerView.isHidden ? localized("voiceover_folded") : localized("voiceover_unfolded"))
        showLastMovementsButton.accessibilityLabel = localized("voiceover_detailsOrder", [transactionsButtonState]).text
    }

    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_funds")
            .setLeftAction(.back, customAction: {
                self.didSelectGoBack()
            })
            .setRightAction(.menu) {
                self.didSelectOpenMenu()
            }
            .build(on: self)
    }

    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }

    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }

    func trackSectionFoldEvents(_ view: UIView?, _ isHidden: Bool) {
        guard view == detailContainerView || view == lastMovementsContainerView else { return }
        view == detailContainerView ?
            viewModel.trackEvent(isHidden ? .foldDetails : .unfoldDetails) :
            viewModel.trackEvent(isHidden ? .foldOrdersAndTransactions : .unfoldOrdersAndTransactions)
    }
    
    func changeSectionVisibility(isHidden: Bool, view: UIView?, headerButton: UIButton?, initialSetUp: Bool = false) {
        view?.isHidden = isHidden
        let headerButtonImage = isHidden ? "icnArrowDown" : "icnArrowUp"
        headerButton?.setImage(UIImage(named: headerButtonImage, in: .module, compatibleWith: nil), for: .normal)
        if !initialSetUp {
            trackSectionFoldEvents(view, isHidden)
        }
    }

    func hideCollapsedHeader() {
        guard self.compressedHeaderViewTopConstraint.constant == 0 else { return }
        self.compressedHeaderView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.compressedHeaderViewTopConstraint.constant = -(self?.compressedHeaderView.frame.height ?? 0)
            self?.view.layoutIfNeeded()
        }) { _ in
            self.compressedHeaderView.isHidden = true
        }
    }

    func showCollapsedHeader() {
        guard self.compressedHeaderViewTopConstraint.constant == -self.compressedHeaderView.frame.height else { return }
        self.compressedHeaderView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.compressedHeaderViewTopConstraint.constant = 0
            self?.view.layoutIfNeeded()
        })
    }

    func updateHeaderState(offset: CGPoint) {
        if offset.y < self.carouselContainerView.frame.height {
            self.hideCollapsedHeader()
        } else {
            self.showCollapsedHeader()
        }
    }

    func updateDetailLastUnexpandedFund(_ fund: Fund) {
        detailContainerView.fund = fund
    }

    func configureAndShowFullScreenLoading() {
        let info = LoadingInfo(type: .onScreenCentered(controller: self.associatedLoadingView, completion: nil),
                               loadingText: LoadingText(title: localized("")),
                               loadingImageType: .jumps,
                               loaderAccessibilityIdentifier: AccessibilityIdFundLoading.icnLoader.rawValue)
        fullScreenLoading = LoadingCreator.createAndShowLoading(info: info)
    }

    func bind() {
        self.bindFunds()
        self.bindSelectDefaultFund()
        self.bindSelectFund()
        self.bindFundsOptions()
        self.bindScrollManager()
        self.bindFundDetail()
        self.bindFundMovements()
        self.bindPageControl()
    }

    func bindFunds() {
        self.viewModel.state
            .case(FundState.fundsLoaded)
            .filter { !$0.isEmpty }
            .map {[unowned self] in
                $0.map { Fund(funds: $0, dependencies: self.dependencies) }}
            .sink {[unowned self] items in
                self.fundsCollectionView.bind(
                    identifier: FundsHomeIdentifiers.fundCell,
                    cellType: FundCollectionViewCell.self,
                    items: items) { (indexPath, cell, item) in
                        cell?.configure(withViewModel: item)
                        cell?.didSelectShare = { [weak self] fund in
                            self?.viewModel.didSelectShare(fund, trackAction: .share)
                        }
                        cell?.didSelectProfitabilityTooltip = { [weak self] in
                            self?.viewModel.didSelectProfitabilityTooltip()
                        }
                        let ids = FundCollectionViewCellIdentifiers(fundsBgCard: AccessibilityIdFundCarouselCell.fundsBgCard.rawValue)
                        cell?.setAccessibilityIds(ids)
                        cell?.setAccessibility(setViewAccessibility: {
                            cell?.contentView.accessibilityLabel = localized("voiceover_fundsCarouselPosition",
                                                                             [StringPlaceholder(.number, "\(items.count)"),
                                                                              StringPlaceholder(.number, "\(indexPath.row + 1)"),
                                                                              StringPlaceholder(.number, "\(items.count)")]).text
                        })
                }
                self.fundsCollectionView.reloadData()
                self.fundsCollectionView.layoutIfNeeded()
            }.store(in: &self.anySubscriptions)

        self.viewModel.state
            .case(FundState.fundsLoaded)
            .map(\.count)
            .sink {[unowned self] numberOfPages in
                self.carouselContainerView.pageControl.numberOfPages = numberOfPages
                self.carouselContainerView.pageControl.isHidden = numberOfPages <= 1
            }.store(in: &self.anySubscriptions)
    }

    func bindSelectDefaultFund() {
        let selectFundPublisher = self.viewModel.state
            .case(FundState.selectedFund)
            .compactMap { $0 }
            .map {[unowned self] in
                Fund(funds: $0, dependencies: self.dependencies)
            }.share()

        selectFundPublisher
            .sink {[unowned self] fund in
                self.fundsCollectionView.scrollTo(fund)
                self.carouselContainerView.updatePageControlDots()
            }.store(in: &self.anySubscriptions)

        selectFundPublisher
            .subscribe(self.compressedHeaderView.selectFundSubject)
            .store(in: &self.anySubscriptions)

        selectFundPublisher
            .optional()
            .assign(to: \.fund, on: self.carouselContainerView)
            .store(in: &self.anySubscriptions)
    }

    func bindSelectFund() {
        self.fundsCollectionView
            .didSelectFundsSubject
            .sink {[unowned self] fund in
                viewModel.needsToLoadMovements(fund)
                isDetailExpanded ?
                    viewModel.needsToLoadDetail(fund) :
                    updateDetailLastUnexpandedFund(fund)
            }.store(in: &self.anySubscriptions)

        self.fundsCollectionView
            .didSelectFundsSubject
            .subscribe(self.compressedHeaderView.selectFundSubject)
            .store(in: &self.anySubscriptions)

        self.fundsCollectionView
            .didSelectFundsSubject
            .optional()
            .assign(to: \.fund, on: self.carouselContainerView)
            .store(in: &self.anySubscriptions)
    }

    func bindFundsOptions() {
        self.viewModel.state
            .case(FundState.options)
            .map { values in
                values.map { FundHomeOption($0) }
            }.subscribe(self.carouselContainerView.optionsSubject)
            .store(in: &self.anySubscriptions)

        self.carouselContainerView
            .didSelectOptionSubject
            .sink {[unowned self] values in
                self.viewModel.didSelectOption(values.option, fund: values.fund)
            }.store(in: &self.anySubscriptions)
    }

    func bindScrollManager() {
        self.scrollViewDelegate
            .scrollViewDidScroll
            .sink { [unowned self] point in
                self.updateHeaderState(offset: point)
            }.store(in: &self.anySubscriptions)

        self.scrollViewDelegate
            .scrollViewDidEndDecelerating
            .sink { [unowned self] point in
                self.updateHeaderState(offset: point)
            }.store(in: &self.anySubscriptions)
    }

    func bindFundDetail() {
        let fundDetailPublisher = viewModel.state
            .case(FundState.detailLoaded)
            .map {[unowned self] in
                Fund(funds: $0.fund, detail: $0.detail, dependencies: self.dependencies)
            }.share()

        let fundDetailLoadingPublisher = viewModel.state
            .case(FundState.isDetailLoading)
            .share()

        if let detailViewController = self.detailContainerView {
            fundDetailPublisher
                .subscribe(detailViewController.detailSubject)
                .store(in: &anySubscriptions)
            fundDetailLoadingPublisher
                .subscribe(detailViewController.detailIsLoadingSubject)
                .store(in: &anySubscriptions)
        }
    }

    func bindFundMovements() {
        let fundMovementsPublisher = viewModel.state
            .case(FundState.movementsLoaded)
            .map { [unowned self] in
                FundMovements(fund: $0.fund, movements: $0.movementList.transactions, dependencies: self.dependencies)
            }.share()

        self.viewModel.state
            .case(FundState.movementsError)
            .subscribe(self.lastMovementsContainerView.lastMovementsErrorSubject)
            .store(in: &anySubscriptions)

        let fundMovementDetailsPublisher = viewModel.state
            .case(FundState.movementDetailLoaded)
            .map {
                FundMovementDetails(fund: $0.fund, movement: $0.movement, movementDetails: $0.movementDetails, homeDependencies: self.dependencies)
            }.share()

        if let movementsViewController = self.lastMovementsContainerView {
            fundMovementsPublisher
                .optional()
                .assign(to: \.viewModel, on: movementsViewController)
                .store(in: &anySubscriptions)

            fundMovementsPublisher
                .subscribe(movementsViewController.lastMovementsSubject)
                .store(in: &anySubscriptions)

            fundMovementDetailsPublisher
                .subscribe(movementsViewController.movementDetailsSubject)
                .store(in: &anySubscriptions)

            movementsViewController
                .didSelectMoreMovementsSubject
                .sink {[unowned self] fundMovements in
                    self.viewModel.didSelectTransactions(fundMovements)
                }.store(in: &anySubscriptions)

            movementsViewController
                .didSelectMovementDetailSubject
                .sink { [unowned self] (movement: FundMovementRepresentable, fund: FundRepresentable) in
                    self.viewModel.didSelectMovementDetail(for: movement, in: fund)
                    self.viewModel.trackEvent(.units)
                }.store(in: &anySubscriptions)

            movementsViewController
                .didSelectMoreMovementsSubject
                .sink { [unowned self] _ in
                    self.viewModel.trackEvent(.more)
                }.store(in: &anySubscriptions)
        }

        viewModel.state
            .case(FundState.isMovementDetailLoading)
            .sink { [unowned self] isMovementDetailLoading in self.isLoadingFullScreen = isMovementDetailLoading }
            .store(in: &anySubscriptions)

        let fundMovementsLoadingPublisher = viewModel.state
            .case(FundState.isMovementsLoading)
            .share()

        if let movementsViewController = self.lastMovementsContainerView {
            fundMovementsLoadingPublisher
                .subscribe(movementsViewController.movementsIsLoadingSubject)
                .store(in: &anySubscriptions)
        }
    }

    func bindPageControl() {
        fundsCollectionView
            .positionChangesSubject
            .assign(to: \.currentPage, on: carouselContainerView.pageControl)
            .store(in: &anySubscriptions)

        fundsCollectionView
            .positionChangesSubject
            .sink { [unowned self] _ in
                self.carouselContainerView.updatePageControlDots()
            }.store(in: &self.anySubscriptions)
    }
}

private extension FundsHomeViewController {
    class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
        let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndDecelerating = PassthroughSubject<CGPoint, Never>()

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.scrollViewDidScroll.send(scrollView.contentOffset)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.scrollViewDidEndDecelerating.send(scrollView.contentOffset)
        }
    }
}

extension FundsHomeViewController: FundDetailViewDelegate {
    func didTapOnShare(_ shareable: Shareable) {
        viewModel.didSelectShare(shareable, trackAction: .shareAssociatedAccount)
    }
}

extension FundsHomeViewController: LoadingViewPresentationCapable {}

extension FundsHomeViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension FundsHomeViewController: AccessibilityCapable {}
