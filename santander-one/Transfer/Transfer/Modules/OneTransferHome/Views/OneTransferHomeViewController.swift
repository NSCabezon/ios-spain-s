//
//  SceneViewController.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 3/12/21.
//

import UIOneComponents
import OpenCombine
import UIKit
import UI
import CoreFoundationLib
import CoreDomain

final class OneTransferHomeViewController: UIViewController {
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let viewModel: OneTransferHomeViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OneTransferHomeDependenciesResolver
    private var baseUrl: String?
    private lazy var favoritesView: OneFavoritesView = {
        let view = OneFavoritesView(frame: .zero)
        view.set(datasource: payeeDataSource)
        view.delegate = self
        return view
    }()
    
    private lazy var recentAndScheduledView: RecentAndScheduledView = {
        let view = RecentAndScheduledView(frame: .zero)
        view.set(datasource: recentAndScheduledDataSource)
        return view
    }()
    
    private lazy var payeeDataSource: PayeeCollectionDataSource = {
        return PayeeCollectionDataSource(initialState: .loading, delegate: self)
    }()
    
    private lazy var recentAndScheduledDataSource: RecentAndScheduledDataSource = {
        return RecentAndScheduledDataSource(delegate: self)
    }()
    
    private lazy var oneTransferOptionsView: OneTransferOptionsView = {
        let view = OneTransferOptionsView(frame: .zero)
        return view
    }()
    
    private lazy var oneFooterHelpView: OneFooterHelpView = {
        let view = OneFooterHelpView()
        view.delegate = self
        return view
    }()
    
    init(dependencies: OneTransferHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.baseUrl = dependencies.external.resolve().resolve(for: BaseURLProvider.self).baseURL
        super.init(nibName: "OneTransferHome", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        fillContainerStackView()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

extension OneTransferHomeViewController: OneFavoritesViewDelegate {
    func didTapOnSeeFavorites() {
        viewModel.showAllFavorites()
    }
    
    func didTapOnNewTransfer() {
        viewModel.showNewTransfer()
    }
    
    func didTapOnNewContact() {
        viewModel.showNewContact()
    }
    
    func didSelectFavoriteContact(_ contactName: String) {
        viewModel.showContactDetail(contactName)
    }
}

extension OneTransferHomeViewController: OnePastTransferCardViewDelegate {
    public func didSelectPastTransfer(_ viewModel: OnePastTransferViewModel) {
        self.viewModel.showPastTransfer(viewModel.transfer)
    }
}

extension OneTransferHomeViewController: OneFooterHelpViewDelegate {
    func didSelectVirtualAssistant() {
        self.viewModel.showVirtualAssistant()
    }
    
    func didSelectTip(_ offer: OfferRepresentable?) {
        self.viewModel.showTip(offer)
    }
}

// MARK: - Configuration
private extension OneTransferHomeViewController {
    func fillContainerStackView() {
        containerStackView.addArrangedSubview(favoritesView)
        containerStackView.addArrangedSubview(recentAndScheduledView)
        containerStackView.addArrangedSubview(oneTransferOptionsView)
        containerStackView.addArrangedSubview(oneFooterHelpView)
    }
    
    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_onePay")
            .setTooltip(didTapOnTooltip)
            .setLeftAction(.back)
            .setRightAction(.search, action: didTapOnSearch)
            .setRightAction(.menu, action: didTapOnMenu)
            .build(on: self)
    }
    
    func didTapOnTooltip(_ view: UIView) {
        viewModel.showTooltip()
    }
    
    func didTapOnSearch() {
        viewModel.showSearch()
    }
    
    func didTapOnMenu() {
        viewModel.showMenu()
    }
}

// MARK: - Bindings
private extension OneTransferHomeViewController {
    func bind() {
        bindFavorites()
        bindDisabledFavoritesCarousel()
        bindRecentAnsScheduled()
        bindDisabledRecentAndScheduled()
        bindSendMoneyActions()
        bindHelpFooter()
        bindNewSendType()
        bindDisabledHelpFooter()
    }
    
    func bindFavorites() {
        viewModel.state
            .case(OneTransferHomeState.receivedPayee)
            .map { [unowned self] items in
                return items.compactMap {
                    return OneFavoriteContactCardViewModel(
                        cardStatus: .inactive,
                        avatar: OneAvatarViewModel(
                            fullName: $0.payeeAlias,
                            dependenciesResolver: self.dependencies.external.resolve()
                        ),
                        payee: $0,
                        dependenciesResolver: self.dependencies.external.resolve()
                    )
                }
            }
            .sink { [unowned self] items in
                payeeDataSource.state = .filled(items)
                favoritesView.reloadData()
                favoritesView.didSwipe = {
                    viewModel.favoritesSwipe()
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindDisabledFavoritesCarousel() {
        viewModel.state
            .case(OneTransferHomeState.disableFavoritesCarousel)
            .sink { [unowned self] _ in
                payeeDataSource.state = .disabled
                favoritesView.disableFavoritesButton()
                favoritesView.reloadData()
                favoritesView.didSwipe = {
                    viewModel.favoritesSwipe()
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindDisabledRecentAndScheduled() {
        viewModel.state
            .case(OneTransferHomeState.disableRecentAndScheduledTransfers)
            .sink { [unowned self] _ in
                recentAndScheduledView.isHidden = true
            }
            .store(in: &subscriptions)
    }
    
    func bindRecentAnsScheduled() {
        viewModel.state
            .case(OneTransferHomeState.recentAndScheduledTransfers)
            .map { [unowned self] items in
                return items.compactMap {
                    return OnePastTransferViewModel(
                        cardStatus: .disabled,
                        transfer: $0,
                        avatar: OneAvatarViewModel(
                            fullName: $0.name,
                            dependenciesResolver: self.dependencies.external.resolve()),
                        dependenciesResolver: self.dependencies.external.resolve()
                    )
                }
            }
            .sink { [unowned self] items in
                recentAndScheduledDataSource.setList(items)
                recentAndScheduledView.setView(items.isEmpty)
                recentAndScheduledView.isHidden = false
                recentAndScheduledView.didSelectSeeHistoricalButton = {
                    viewModel.showHistorical()
                }
                recentAndScheduledDataSource.didSwipe = {
                    viewModel.recentAndScheduledSwipe()
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindSendMoneyActions() {
        viewModel.state
            .case(OneTransferHomeState.sendMoneyActionsLoaded)
            .map { actions in
                actions.compactMap { sendMoneyAction in
                    guard let action = sendMoneyAction else { return nil }
                    let value = action.values()
                    return SendMoneyHomeOption(
                        title: value.title,
                        description: value.description,
                        imageName: value.imageName,
                        actionType: action,
                        action: self.didSelectActionType
                    )
                }
            }
            .sink { viewModels in
                self.oneTransferOptionsView.setActions(viewModels)
            }
            .store(in: &subscriptions)
    }
    
    func didSelectActionType(_ actionType: SendMoneyHomeActionType) {
        viewModel.didSelectSendMoneyAction(actionType)
    }
    
    func bindHelpFooter() {
        viewModel.state
            .case(OneTransferHomeState.faqsLoaded)
            .sink { [unowned self] oneFooterData in
                guard !oneFooterData.faqs.isEmpty || !oneFooterData.tips.isEmpty || oneFooterData.virtualAssistant else {
                    oneFooterHelpView.isHidden = true
                    return
                }
                let viewModel = OneFooterHelpViewModel(
                    faqs: oneFooterData.faqs.map { FaqsViewModel($0) },
                    tips: oneFooterData.tips.map { OfferTipViewModel($0, baseUrl: baseUrl ?? "") },
                    showVirtualAssistant: oneFooterData.virtualAssistant
                )
                oneFooterHelpView.setFooterHelp(viewModel)
            }
            .store(in: &subscriptions)
    }
    
    func bindNewSendType() {
        viewModel.state
            .case(OneTransferHomeState.newSendType)
            .sink { [unowned self] type in
                payeeDataSource.newTransferType = type
            }
            .store(in: &subscriptions)
    }
    
    func bindDisabledHelpFooter() {
        viewModel.state
            .case(OneTransferHomeState.disableHelpFooter)
            .sink { [unowned self] _ in
                oneFooterHelpView.isHidden = true
            }
            .store(in: &subscriptions)
    }
}

extension OneTransferHomeViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if oneFooterHelpView.isHidden {
            self.scrollView.backgroundColor = .clear
        } else {
            self.scrollView.backgroundColor = scrollView.contentOffset.y > 0 ? .oneDarkEmerald: .clear
        }
    }
}
