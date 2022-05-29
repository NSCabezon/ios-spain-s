//
//  FinancingDistributionViewController.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 28/08/2020.
//  Copyright © 2020 Ciber. All rights reserved.

import UI
import CoreFoundationLib

protocol FinancingDistributionViewProtocol: AnyObject, LoadingViewPresentationCapable {
    var viewState: ViewState<FinanceDistributionViewModel> { get set }
    func loadLastContributionsView(_ lastContributionsViewModel: LastContributionsViewModel?)
    func loadOfferBanner(_ viewModel: OfferBannerViewModel)
    func showFractionatedPurchasesCarouselView(_ viewModels: [FractionatePurchasesCarouselViewModel], numOfItems: Int)
    func showFractionatedPurchasesCarouselEmptyView()
    func showFractionatedPurchasesCarouselLoadingView()
    func hiddeFractionatedPurchasesCarousel()
}

final class FinancingDistributionViewController: UIViewController {
    @IBOutlet private weak var financingDistributionView: FinancingDistributionView!
    @IBOutlet private weak var financingDistributionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var lastContributionsView: LastContributionsView!
    @IBOutlet private weak var lastContributionsViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var financingDistributionOffer: OfferBannerView!
    @IBOutlet private weak var financingDistributionOfferHeight: NSLayoutConstraint!
    @IBOutlet private weak var fractionatedPurchasesCarouselView: FractionatedPurchasesCarouselView!
    @IBOutlet private weak var fractionatedPurchasesCarouselViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    let presenter: FinancingDistributionPresenterProtocol
    var viewState: ViewState<FinanceDistributionViewModel> = .empty {
        didSet {
            switch viewState {
            case let .filled(viewModel):
                financingDistributionView.viewState = .filled(viewModel)
                self.financingDistributionView.isHidden = false
            case .empty:
                financingDistributionView.viewState = .empty
                self.financingDistributionView.isHidden = true
            default:
                break
            }
        }
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: FinancingDistributionPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegates()
        self.setIdentifiers()
        presenter.viewDidLoad()
    }
}

private extension FinancingDistributionViewController {
    func setDelegates() {
        self.financingDistributionView.delegate = self
        self.lastContributionsView.delegate = self
        self.financingDistributionOffer.delegate = self
        self.fractionatedPurchasesCarouselView.delegate = self
        self.financingDistributionView.isHidden = true
        self.financingDistributionOffer.isHidden = true
        self.scrollView.delegate = self
    }
    
    func setIdentifiers() {
        self.lastContributionsView.accessibilityIdentifier = "financingListLoan"
        self.financingDistributionOffer.updateIdentifier(with: "financingDistributionBannerFinancingOffer")
    }
}

extension FinancingDistributionViewController: FinancingDistributionViewProtocol {
    func loadLastContributionsView(_ lastContributionsViewModel: LastContributionsViewModel?) {
        guard let viewModel = lastContributionsViewModel,
            let loans = viewModel.loans,
            let cards = viewModel.cards,
            !(loans.isEmpty && cards.isEmpty)
            else {
                self.lastContributionsView.configEmptyView()
                return
        }
        self.lastContributionsView.configView(viewModel)
    }

    func loadOfferBanner(_ viewModel: OfferBannerViewModel) {
        self.financingDistributionOffer.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: financingDistributionOfferHeight)
    }
    
    // MARK: - FractionatedPurchases Carousel
    func showFractionatedPurchasesCarouselView(_ viewModels: [FractionatePurchasesCarouselViewModel], numOfItems: Int) {
        self.fractionatedPurchasesCarouselView.configView(viewModels, numOfItems: numOfItems)
    }
    
    func showFractionatedPurchasesCarouselEmptyView() {
        self.fractionatedPurchasesCarouselView.showEmptyView()
    }
    
    func showFractionatedPurchasesCarouselLoadingView() {
        self.fractionatedPurchasesCarouselView.showLoadingView()
    }
    
    func hiddeFractionatedPurchasesCarousel() {
        self.fractionatedPurchasesCarouselView.isHidden = true
        self.fractionatedPurchasesCarouselViewHeight.constant = .zero
    }
}

// MARK: - Resize component heights
extension FinancingDistributionViewController: LastContributionsDelegate {
    func updateComponentHeight(_ tableHeight: CGFloat) {
        self.lastContributionsViewHeight.constant = tableHeight
    }
}

extension FinancingDistributionViewController: FinancingDistributionDelegate {
    func updateTableViewHeight(_ height: CGFloat) {
        self.financingDistributionViewHeight.constant = height
    }
}

extension FinancingDistributionViewController: OfferBannerViewProtocol {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectedOffer(viewModel)
    }
}

extension FinancingDistributionViewController: FractionatedPurchasesCarouselViewDelegate {
    func updatedFractionatedPurchasesCarouselHeight(_ height: CGFloat) {
        self.fractionatedPurchasesCarouselViewHeight.constant = height
    }
    
    func didTapInFractionatedPurchase(_ viewModel: FractionatePurchasesCarouselViewModel) {
        self.presenter.didTapInFractionatedPurchase(viewModel)
    }
    
    func didTapInSeeMoreFractionatedPurchases() {
        self.presenter.didTapInSeeMoreFractionatedPurchases()
    }
    
    func didSwipeCollectionView() {
        presenter.didSwipeCollectionView()
    }
}

extension FinancingDistributionViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollEnabled = self.scrollView.contentOffset.y > 0
        let shadowColor: UIColor = isScrollEnabled
        ? .brownishGray.withAlphaComponent(0.44)
        : .clear
        shadowView.drawShadow(
            offset: (x: 0, y: 3),
            color: shadowColor,
            radius: 2
        )
    }
}
