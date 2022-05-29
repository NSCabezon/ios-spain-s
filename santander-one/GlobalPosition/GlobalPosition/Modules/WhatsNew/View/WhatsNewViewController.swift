//
//  WhatsNewViewController.swift
//  GlobalPosition
//
//  Created by Laura González on 24/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol WhatsNewViewProtocol: AnyObject {
    func setNewWelcomeViewModel(_ viewModel: WhatsNewWelcomeViewModel?)
    func loadOfferBanners(_ location: WhatsNewLocations, viewModel: OfferBannerViewModel)
    func setOfferBannerWithUrl(_ url: String?, offerView: OfferBannerView, updateConstraint: NSLayoutConstraint)
    func showUpdate(_ update: Bool)
    func setPendingRequestViewPresenter(_ pendigPresenter: PendingSolicitudesPresenterProtocol)
    func setPreconceivedBanner(_ viewModel: PreconceivedBannerViewModel?)
    func showPreconceived(_ isPreconceived: Bool)
    func showWelcomeView()
    func setLastMovementViewModel(_ viewModel: WhatsNewLastMovementsViewModel?)
    func showFutureBills(_ viewModels: [FutureBillViewModel])
    func showFutureBillsEmpty()
    func setFractionableAccounts(_ viewModel: WhatsNewLastMovementsViewModel?)
    func setFractionableCards(_ viewModel: WhatsNewLastMovementsViewModel?)
    func isPreconceivedOfferCandidate() -> Bool
    var loadingTipsViewController: LoadingTipViewController? { get set }
    func showTipLoading()
    func hideTipLoading()
}

class WhatsNewViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var updateAppView: UpdateAppView!
    @IBOutlet private weak var welcomeView: WhatsNewWelcomeView!
    @IBOutlet private weak var operationInfoOffer: OfferBannerView!
    @IBOutlet private weak var recobroOffer: OfferBannerView!
    @IBOutlet private weak var agentMessageOffer: OfferBannerView!
    @IBOutlet private weak var operationInfoOfferHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var recobroOfferHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var agentMessageOfferHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pendingRequestView: PendingRequestView!
    @IBOutlet private weak var spaceView: UIView!
    @IBOutlet weak private var futureBillView: FutureBillContainer!
    @IBOutlet private weak var preconceivedOffer: OfferBannerView!
    @IBOutlet private weak var preconceivedOfferHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var preconceivedBanner: WhatsNewPreconceivedBanner!
    @IBOutlet private weak var lastMovementsView: LastMovementsListView!
    @IBOutlet private weak var lastMovementsViewHeightConstraint: NSLayoutConstraint!
    private var isPreconceived: Bool = false
    @IBOutlet private weak var emptyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var emptyView: WhatsNewEmptyView!
    @IBOutlet weak private var emptyViewContainer: UIView!
    private var welcomeViewModel: WhatsNewWelcomeViewModel?
    
    @IBOutlet private weak var fractionedPaymentsView: FractionedPaymentSectionView!
    @IBOutlet private weak var shadowView: UIView!
    
    let presenter: WhatsNewPresenterProtocol
    public var loadingTipsViewController: LoadingTipViewController?

    init(presenter: WhatsNewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "WhatsNewViewController", bundle: Bundle(for: WhatsNewViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegates()
        self.view.backgroundColor = .iceBlue
        self.welcomeView.isHidden = true
        self.operationInfoOffer.isHidden = true
        self.recobroOffer.isHidden = true
        self.agentMessageOffer.isHidden = true
        self.preconceivedOffer.isHidden = true
        self.preconceivedBanner.isHidden = true
        self.updateAppView.isHidden = true
        self.lastMovementsView.delegate = self
        self.lastMovementsView.isHidden = true
        self.lastMovementsViewHeightConstraint.constant = 0
        presenter.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressUpdate))
        updateAppView.addGestureRecognizer(tap)
        preconceivedBanner.isUserInteractionEnabled = true
        let bannerTap = UITapGestureRecognizer(target: self, action: #selector(didPressBanner))
        preconceivedBanner.addGestureRecognizer(bannerTap)
        setAccessibilityIdentifiers()
        setupEmptyView()
        self.configInitialFractionedPayments()
        addNavBarShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    func setPendingRequestViewPresenter(_ pendigPresenter: PendingSolicitudesPresenterProtocol) {
        pendingRequestView.viewDidLoad(presenter: pendigPresenter, delegate: self)
    }
    
    func showTipLoading() {
        let parent = self
        guard let child = loadingTipsViewController else { return }
        parent.view.addSubview(child.view)
        child.view.fullFit()
        parent.addChild(child)
        child.didMove(toParent: parent)
    }
    
    func hideTipLoading() {
        guard let child = loadingTipsViewController else { return }
        child.willMove(toParent: nil)
        child.removeFromParent()
        child.view.removeFromSuperview()
    }
}

private extension WhatsNewViewController {
    func configureDelegates() {
        self.operationInfoOffer.delegate = self
        self.recobroOffer.delegate = self
        self.agentMessageOffer.delegate = self
        self.futureBillView.setDelegate(self)
        self.preconceivedOffer.delegate = self
        self.fractionedPaymentsView.delegate = self
        self.scrollView.delegate = self
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .santanderRed),
            title: .title(key: "toolbar_title_yourLastVisit")
        )
        builder.setLeftAction(.none)
        builder.setRightActions(
            .close(action: #selector(dismissViewController))
        )
        builder.build(on: self, with: nil)
    }
    
    private func addNavBarShadow() {
        shadowView.backgroundColor = self.view.backgroundColor
        shadowView.drawShadow(offset: (x: 0, y: 0), opacity: 1, color: .coolGray, radius: 0)
    }
    
    @objc private func didPressUpdate() {
        self.presenter.didPressUpdate()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc private func didPressBanner() {
        self.presenter.didSelectPreconceivedBanner(preconceivedBanner.viewModel)
    }
    
    func setAccessibilityIdentifiers() {
        self.welcomeView.accessibilityIdentifier = "whatsNewHeaderLastSesion"
        self.operationInfoOffer.accessibilityIdentifier = "whatsnewBtnOperationInfo"
        self.recobroOffer.accessibilityIdentifier = "whatsnewBtnBreach"
        self.agentMessageOffer.accessibilityIdentifier = "whatsnewBtnManager"
        self.preconceivedOffer.accessibilityIdentifier = "whatsnewBtnLoan"
    }
    
    func setupEmptyView() {
        emptyViewContainer.backgroundColor = .clear
        let shadowConfiguration = ShadowConfiguration(color: UIColor.darkTorquoise.withAlphaComponent(0.33), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        emptyView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .lightSkyBlue, borderWith: 1.0)
    }
}

extension WhatsNewViewController: WhatsNewViewProtocol {
    func showFutureBillsEmpty() {
        self.futureBillView.setFutureBillState(.empty)
    }
    
    func showFutureBills(_ viewModels: [FutureBillViewModel]) {
        self.futureBillView.setFutureBillState(.filled(viewModels))
    }
    
    func setFractionableCards(_ viewModel: WhatsNewLastMovementsViewModel?) {
        guard let viewModel = viewModel else { return }
        let numberOfFractionedCards = viewModel.unreadFractionedMovements.cards.count
        let totalFractionedCards = viewModel.fractionedPaymentsSum.cards
        self.fractionedPaymentsView.configCardSection(numberOfFractionedCards, totalFractionedCards)
    }
    
    func setFractionableAccounts(_ viewModel: WhatsNewLastMovementsViewModel?) {
        guard let viewModel = viewModel else { return }
        let numberOfFractionedAccounts = viewModel.unreadFractionedMovements.accounts.count
        let totalFractionedAccounts = viewModel.fractionedPaymentsSum.accounts
        self.fractionedPaymentsView.configAccountSection(numberOfFractionedAccounts, totalFractionedAccounts)
    }
    
    func setLastMovementViewModel(_ viewModel: WhatsNewLastMovementsViewModel?) {
        guard let viewModel = viewModel else { return }
        if viewModel.numberOfSections() == 0 {
            lastMovementsViewHeightConstraint.constant = 0
            emptyViewHeightConstraint.constant = 210
            guard let emptyTextLocalized = welcomeViewModel?.emptyViewText else {
                return
            }
            emptyView.updateTitle(emptyTextLocalized)
            emptyViewContainer.isHidden = false
        } else {
            emptyViewHeightConstraint.constant = 0.0
            lastMovementsView.isHidden = false
            lastMovementsView.configList(viewModel, isSmallList: true, section: LastMovementsConfiguration.FractionableSection.lastMovements)
            emptyViewContainer.isHidden = true
            self.updatedTableView()
        }
    }
    
    func showWelcomeView() {
        self.welcomeView.isHidden = false
    }
    
    func setNewWelcomeViewModel(_ viewModel: WhatsNewWelcomeViewModel?) {
        self.welcomeViewModel = viewModel
        welcomeView.setViewModelData(viewModel)
    }
    
    func loadOfferBanners(_ location: WhatsNewLocations, viewModel: OfferBannerViewModel) {
        switch location {
        case .operationInfo:
            self.operationInfoOffer.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: operationInfoOfferHeightConstraint)
        case .recobro:
            self.recobroOffer.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: recobroOfferHeightConstraint)
        case .agentMessage:
            self.agentMessageOffer.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: agentMessageOfferHeightConstraint)
        case .noPreconceived:
            self.preconceivedBanner.isHidden = true
        case  .preconceivedRobinson:
            self.preconceivedOffer.type = .preconceived
            self.preconceivedOffer.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: preconceivedOfferHeightConstraint)
            self.presenter.trackPreconceivedBannerAppearance(offerId: viewModel.offer.id ?? "")
        case .preconceived:
            self.preconceivedBanner.viewModel = viewModel
            self.presenter.getLimitsPreconceivedBanner()
            let date = presenter.getBannerDate(viewModel)
            if self.isPreconceivedOfferCandidate() && self.presenter.isPreconceived() {
                self.preconceivedOffer.isHidden = true
            }
            guard let dateString = date else { return }
            self.preconceivedBanner.setDate(dateString)
        }
    }
    
    func setOfferBannerWithUrl(_ url: String?, offerView: OfferBannerView, updateConstraint: NSLayoutConstraint) {
        if let urlUnwrapped = url {
            offerView.imageView.loadImage(urlString: urlUnwrapped) { 
                if let image = offerView.imageView.image {
                    let aspectRatio = image.size.height / image.size.width
                    let height = ((offerView.imageView.frame.width) * aspectRatio)
                    UIView.performWithoutAnimation {
                        if height > 0 {
                            updateConstraint.constant = (height+25)
                            offerView.setNeedsLayout()
                            offerView.layoutIfNeeded()
                        }
                    }
                }
            }
        } else {
            offerView.imageView.image = nil
        }
    }
    
    func showUpdate(_ update: Bool) {
        updateAppView.isHidden = !update
    }
    
    func setPreconceivedBanner(_ viewModel: PreconceivedBannerViewModel?) {
        preconceivedBanner.setLabelsInfo(viewModel: viewModel)
    }
    
    func showPreconceived(_ isPreconceived: Bool) {
        self.preconceivedBanner.isHidden = !isPreconceived
        self.preconceivedOffer.isHidden = isPreconceived
        if isPreconceived {
            self.presenter.trackPreconceivedBannerAppearance(offerId: self.preconceivedBanner.viewModel?.offer.id ?? "")
        }
    }
    
    func isPreconceivedOfferCandidate() -> Bool {
        return self.preconceivedBanner.viewModel?.offer == nil ? false : true
    }
}

extension WhatsNewViewController: OfferBannerViewProtocol {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectOffer(viewModel)
    }

    func didSelectPreconceivedBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectPreconceivedBanner(viewModel)
    }
}

extension WhatsNewViewController: PendingRequestCollectionViewDelegate {
    func pendingRequestIsHidden(_ isHidden: Bool) {
        spaceView.isHidden = isHidden
        pendingRequestView.isHidden = isHidden
    }
    
    func pendingRequestSelected(_ viewModel: PendingSolicitudeViewModel) {
        presenter.pendingRequestSelected(viewModel)
    }
}

extension WhatsNewViewController: FutureBillCollectionDatasourceDelegate {
    func didSelectTimeLine() {
        self.presenter.didSelectTimeLine()
    }
    
    func scrollViewDidEndDecelerating() {}
    
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel) {
        self.presenter.didSelectFutureBill(futureBillViewModel)
    }
}

extension WhatsNewViewController: LastMovementsListDelegate {
    func updatedTableView() {
        DispatchQueue.main.async {
            self.lastMovementsViewHeightConstraint.constant = self.lastMovementsView.tableView.contentSize.height
        }
    }
    
    func didSelectItem(_ item: UnreadMovementItem) {
        presenter.showMovementDetailForItem(item)
    }
    
    func didTapInGoToMoreMovements() {
        self.presenter.didSelectSeeMoreMovements(LastMovementsConfiguration.FractionableSection.lastMovements)
    }
    
    func didTapCrossSellingButton(_ item: UnreadMovementItem) {
        self.presenter.loadCandidatesOffersForViewModel(item)
    }

}

// MARK: - Fractioned Payments
private extension WhatsNewViewController {
    func configInitialFractionedPayments() {
        self.fractionedPaymentsView.configCardSection(0, NSAttributedString(string: "0"))
        self.fractionedPaymentsView.configAccountSection(0, NSAttributedString(string: "0"))
    }
}

extension WhatsNewViewController: FractionedPaymentSectionDelegate {
    func didSelectAccounts() {
        self.presenter.didSelectSeeMoreMovements(LastMovementsConfiguration.FractionableSection.fundableAccounts)
    }
    
    func didSelectCards() {
        self.presenter.didSelectSeeMoreMovements(LastMovementsConfiguration.FractionableSection.fractionableCards)
    }
}

extension WhatsNewViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.layer.shadowRadius = scrollView.contentOffset.y > 0.0 ? 2.0 : 0.0
    }
}
