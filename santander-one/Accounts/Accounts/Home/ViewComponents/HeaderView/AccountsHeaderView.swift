//
//  AccountsHeaderView.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import UI
import CoreFoundationLib
import OfferCarousel

protocol AccountsHeaderViewDelegate: AnyObject {
    func didSelectAccountViewModel(_ viewModel: AccountViewModel)
    func didTapOnShareViewModel(_ viewModel: AccountViewModel)
    func didTapOnWithHolding(_ viewModel: AccountViewModel)
    func didBeginScrolling()
    func didEndScrolling()
    func didEndScrollingSelectedItem()
    func didSelectBanner(_ viewModel: OfferBannerViewModel?)
    func headerLayoutSubviews()
    func updateHeaderViewFrame()
}

protocol PageControlDelegate: AnyObject {
    func didPageChange(page: Int)
}

final class AccountsHeaderView: XibView {
    
    weak var delegate: AccountsHeaderViewDelegate?
    private var actionButtons: [ActionButton] = []
    @IBOutlet weak var actionButtonStackView: UIStackView!
    @IBOutlet weak var collectionView: AccountsCollectionView!
    @IBOutlet weak var pageControlContainerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionsHeaderView: AccountHeaderActionsView?
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var piggyOfferBannerView: OfferBannerView!
    @IBOutlet private weak var heightBannerConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionStackContentView: UIView!
    @IBOutlet private weak var bannerContentView: UIView!
    @IBOutlet private weak var accountOfferCarousel: AccountOfferCarouselView!
    var tagsContainerView: TagsContainerView?
    private var selectedViewModel: AccountViewModel?
    public var dependenciesResolver: DependenciesResolver!
    
    // MARK: - Initilizers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Actions

    @objc func performAccountAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton,
              let viewModel = self.selectedViewModel,
              let accountActionViewModel = actionButton.getViewModel() as? AccountActionViewModel else { return }
        accountActionViewModel.action?(accountActionViewModel.type, viewModel.entity)
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Public methods
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        delegate?.headerLayoutSubviews()
    }
    
    func updateAccountsViewModels(_ viewModels: [AccountViewModel],
                                  selecteViewModel: AccountViewModel,
                                  height: CGFloat? = nil) {
        self.updatePageControl(viewModels.count)
        self.collectionView.updateAccountsViewModels(viewModels, selectedViewModel: selecteViewModel)
        guard let height = height else { return }
        self.collectionView.updateHeight(height)
    }
    
    func updateAccountViewModel(_ viewModel: AccountViewModel) {
        self.collectionView.updateAccountViewModel(viewModel)
    }
    
    func setAccountActions(_ viewModels: [AccountActionViewModel]) {
        self.actionButtonStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        self.actionButtons.removeAll()
        viewModels.forEach { (viewModel) in
            let accountAction = self.makeAccountActionForViewModel(viewModel)
            self.actionButtons.append(accountAction)
        }
        self.addActionButtonToStackView()
        self.actionsHeaderView?.setIsHiddenPlusButonView(viewModels.count == 0)
        self.actionStackContentView.isHidden = viewModels.count == 0
    }
    
    func addTagContainer(withTags tags: [TagMetaData], delegate: TagsContainerViewDelegate) {
        let tagsContainerView = TagsContainerView()
        tagsContainerView.delegate = delegate
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        self.stackView.addArrangedSubview(tagsContainerView)
        tagsContainerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
        self.tagsContainerView = tagsContainerView
    }
    
    func setOfferBannerForLocation(viewModel: OfferBannerViewModel?) {
        bannerContentView.isHidden = viewModel == nil
        guard let viewModel = viewModel else {
            return
        }
        piggyOfferBannerView.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: heightBannerConstraint)
    }
    
    public func setAccountOfferCarousel(offers: [OfferCarouselViewModel]) {
        self.accountOfferCarousel.isHidden = (offers.count == 0)
        self.accountOfferCarousel?.setOffers(offers)
        self.accountOfferCarousel?.setDependeciesResolver(self.dependenciesResolver)
        self.delegate?.updateHeaderViewFrame()
    }
    
    public func reloadAccountOfferCarousel() {
        self.accountOfferCarousel?.reloadAllTable()
    }
    
    func detectTopOfferCarouselScrolled(_ scrollView: UIScrollView) {
        let topOfferCarouselPosition = self.accountOfferCarousel.frame
        let container = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)
        if topOfferCarouselPosition.intersects(container) {
            self.accountOfferCarousel.readyToAutoscroll = true
        } else if self.accountOfferCarousel.readyToAutoscroll {
            self.accountOfferCarousel.reloadAllTable()
        }
    }
    
    func setAccountOfferCarouselViewDelegate(_ accountOfferCarouselViewDelegate: AccountOfferCarouselViewDelegate) {
        self.accountOfferCarousel.delegate = accountOfferCarouselViewDelegate
    }
    
    func hideCarousel() {
        self.accountOfferCarousel.isHidden = true
        self.delegate?.updateHeaderViewFrame()
    }
    
    func hidePDFButton() {
        self.actionsHeaderView?.hidePDFButton()
    }
    
    func hidePlusButton(_ isHidden: Bool) {
        self.actionsHeaderView?.setIsHiddenPlusButonView(isHidden)
    }
}

extension AccountsHeaderView: PageControlDelegate {
    func didPageChange(page: Int) {
        self.pageControl.currentPage = page
    }
}

extension AccountsHeaderView: AccountsCollectionViewDelegate {
    func didSelectAccountViewModel(_ viewModel: AccountViewModel) {
        self.selectedViewModel = viewModel
        self.delegate?.didSelectAccountViewModel(viewModel)
    }
    
    func didTapOnShareViewModel(_ viewModel: AccountViewModel) {
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
    
    func didTapOnWithHolding(_ viewModel: AccountViewModel) {
        self.delegate?.didTapOnWithHolding(viewModel)
    }
    
    func didBeginScrolling() {
        self.delegate?.didBeginScrolling()
        self.setupActionButtons(enabled: false)
    }
    
    func didEndScrolling() {
        self.delegate?.didEndScrolling()
        self.setupActionButtons(enabled: true)
    }
    
    func didEndScrollingSelectedItem() {
        self.delegate?.didEndScrollingSelectedItem()
        self.setupActionButtons(enabled: true)
    }
}

extension AccountsHeaderView: ProductHomeHeaderWithTagsViewProtocol {
    
    func updateHeaderAlpha(_ alpha: CGFloat) {
        self.actionsHeaderView?.fadePlushButton(alpha)
        self.collectionView.alpha = alpha
        self.pageControl.alpha = alpha
        self.actionButtonStackView.alpha = alpha
        self.bannerContentView.alpha = alpha
        self.accountOfferCarousel.alpha = alpha
    }
}

extension AccountsHeaderView: OfferBannerViewProtocol {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.delegate?.didSelectBanner(viewModel)
    }
}

private extension AccountsHeaderView {

    func setupActionButtons(enabled: Bool) {
        self.actionButtonStackView.isUserInteractionEnabled = enabled
        self.actionsHeaderView?.isUserInteractionEnabled = enabled
    }

    func addActionButtonToStackView() {
        self.actionButtons.forEach {
            self.actionButtonStackView.addArrangedSubview($0)
        }
    }
    
    func makeAccountActionForViewModel(_ viewModel: AccountActionViewModel) -> ActionButton {
        let accountAction = ActionButton()
        accountAction.setExtraLabelContent(viewModel.highlightedInfo)
        accountAction.setViewModel(viewModel)
        accountAction.addSelectorAction(target: self, #selector(performAccountAction))
        accountAction.accessibilityIdentifier = viewModel.accessibilityIdentifier
        return accountAction
    }
    
    func setupView() {
        self.setupPageControl()
        self.collectionView.backgroundColor = UIColor.skyGray
        self.collectionView.pageControlDelegate = self
        self.collectionView.accountsDelegate = self
        self.piggyOfferBannerView.delegate = self
        self.accountOfferCarousel.isHidden = true
    }
    
    func setupPageControl() {
        let pages = collectionView.numberOfItems(inSection: 0)
        updatePageControl(pages)
        pageControl.pageIndicatorTintColor = .silverDark
        pageControl.currentPageIndicatorTintColor = .botonRedLight
        if #available(iOS 14.0, *) {
            pageControlHeightConstraint.isActive = false
        }
    }
    
    func updatePageControl(_ numberOfItems: Int) {
        pageControl.numberOfPages = numberOfItems
        pageControl.isHidden = numberOfItems <= 1
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
}
