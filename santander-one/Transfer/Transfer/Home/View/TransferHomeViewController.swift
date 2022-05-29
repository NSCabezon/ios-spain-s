import UIKit
import UI
import CoreFoundationLib
import TransferOperatives
import CoreDomain

protocol TransferHomeViewProtocol: LoadingViewPresentationCapable, OldDialogViewPresentationCapable, NavigationBarWithSearchProtocol, ModuleLauncherDelegate, TransferHomeView {
    func showTransferActions(_ viewModels: [TransferActionViewModel])
    func showTransfersEmitted(_ viewModels: [TransferViewModel])
    func showContactsLoading()
    func showContacts(_ viewModels: [ContactViewModel])
    func showTransferEmittedEmptyView()
    func showTransferEmittedLoadingView()
    func showFaqs(_ viewModels: [TransfersFaqsViewModel], showVirtualAssistant: Bool)
    func clearEmittedTransfers()
    func showGeneralTooltipWithVideo(_ isVideoEnabled: Bool)
    func closeTooltip(_ completion: @escaping () -> Void)
}

public class TransferHomeViewController: UIViewController {
    private let presenter: TransferHomePresenterProtocol
    private let scrollableStackView = ScrollableStackView()
    private let moneyTransferView = MoneyTransferView()
    private let emittedTransfersView = EmittedTransfersView()
    private let transferActionHeader = TransferActionHeader()
    private let transferActionsView = TransferActionsStackView()
    private let dependencies: DependenciesResolver
    private var contactsView = ContactsView()
    private let maxElements = 25
    private weak var lastTooltipViewSender: UIView?
    private weak var tooltipViewController: UIViewController?
    
    public var isSearchEnabled: Bool = true
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: TransferHomePresenterProtocol,
         dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependencies = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setAppearance()
        self.setupViews()
        self.presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.presenter.viewWillAppear()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.viewWillDisappear()
    }
    
    private func setAppearance() {
        self.view.backgroundColor = .skyGray
        self.contactsView.view?.backgroundColor = .skyGray
    }
    
    private func setupViews() {
        self.contactsView.delegate = self
        self.moneyTransferView.isHidden = true
        self.scrollableStackView.setup(with: self.view)
        self.scrollableStackView.backgroundColor = .skyGray
        self.scrollableStackView.addArrangedSubview(moneyTransferView)
        self.scrollableStackView.addArrangedSubview(contactsView)
        self.scrollableStackView.addArrangedSubview(emittedTransfersView)
        self.scrollableStackView.addArrangedSubview(transferActionHeader)
        self.scrollableStackView.addArrangedSubview(transferActionsView)
        self.scrollableStackView.setScrollDelegate(self)
        self.emittedTransfersView.delegate = self
        self.moneyTransferView.delegate = self
        self.setUpHistoricalButton()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(titleKey: "toolbar_title_onePay", type: .red,
                action: { [weak self] sender in
                    self?.didSelectInfo(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions( .menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    private func doSearch() {
        presenter.didSelectSearch()
    }
        
    func didSelectInfo(_ sender: UIView) {
        self.lastTooltipViewSender = sender
        self.presenter.didTooltipAction()
    }
}

extension TransferHomeViewController: TransferHomeViewProtocol {
    func closeTooltip(_ completion: @escaping () -> Void) {
        self.tooltipViewController?.dismiss(animated: true, completion: completion)
    }
    
    func showGeneralTooltipWithVideo(_ isVideoEnabled: Bool) {
        guard let sender = self.lastTooltipViewSender else { return }
        let titleView = getTooltipText(text: "toolbar_title_sendMoney", font: UIFont.santander(family: .text, type: .bold, size: 20), separator: 8)
        let stickyItems: [FullScreenToolTipViewItemData] = [titleView]
        let scrolledItems: [FullScreenToolTipViewItemData] = getScrolledItems(isVideoEnabled)
        let configuration = FullScreenToolTipViewData(topMargin: 0, stickyItems: stickyItems, scrolledItems: scrolledItems)
        self.tooltipViewController = configuration.show(in: self, from: sender)
    }
    
    func getTooltipText(text: String, font: UIFont, separator: CGFloat) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: localized(text), left: 18, right: 18, font: font, textColor: .lisboaGray)
        let view = LabelTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    func getTooltipItem(text: String, image: String) -> FullScreenToolTipViewItemData {
        let configuration = ItemTooltipViewConfiguration(image: Assets.image(named: image), text: localized(text))
        let view = ItemTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 8)
        return item
    }
    
    func showTransferActions(_ viewModels: [TransferActionViewModel]) {
        self.transferActionsView.setOrigin(.home)
        self.transferActionsView.setViewModels(viewModels)
    }
    
    func showTransfersEmitted(_ viewModels: [TransferViewModel]) {
        self.emittedTransfersView.setViewModels(viewModels)
    }
    
    func showTransferEmittedEmptyView() {
        self.emittedTransfersView.showEmptyView()
    }
    
    func showTransferEmittedLoadingView() {
        self.emittedTransfersView.addLoadingView()
    }
    
    func showContactsLoading() {
        self.contactsView.showLoading()
    }
    
    func showContacts(_ viewModels: [ContactViewModel]) {
        guard viewModels.count > 0 else {
            self.hideContactView()
            return
        }
        self.contactsView.set(Array(viewModels.prefix(self.maxElements)))
    }
    
    func hideContactView() {
        self.contactsView.isHidden = true
        self.moneyTransferView.isHidden = false
    }
    
    func setUpHistoricalButton() {
        if !self.dependencies.resolve(for: LocalAppConfig.self).isEnabledHistorical {
            self.emittedTransfersView.hideHistoricalButton()
        }
    }
    
    func showFaqs(_ viewModels: [TransfersFaqsViewModel], showVirtualAssistant: Bool) {
        self.removeFaqView()
        if !viewModels.isEmpty {
            let faqsView = FAQSView(faqs: viewModels, self, showVirtualAssistant: showVirtualAssistant)
            self.scrollableStackView.addArrangedSubview(faqsView)
        }
    }
    
    private func removeFaqView() {
        self.scrollableStackView.getArrangedSubviews().forEach {
            guard $0 is FAQSView else { return }
            $0.removeFromSuperview()
        }
    }
    
    func clearEmittedTransfers() {
        self.emittedTransfersView.clearTransfers()
    }
    
    func getScrolledItems(_ isVideoEnabled: Bool) -> [FullScreenToolTipViewItemData] {
        var scrolledItems: [FullScreenToolTipViewItemData] = []
        if isVideoEnabled {
            let videoView = FullScreenToolTipViewItemData(view: VideoTooltipView(imageName: "imgVideoTransfer", action: { [weak self] in
                self?.presenter.didTooltipVideoAction()
            }), bottomMargin: 13)
            scrolledItems.append(videoView)
        }
        scrolledItems.append(
            getTooltipText(text: "sendMoneyTooltip_text_sendMoney",
                           font: UIFont.santander(family: .text, type: .light, size: 16),
                           separator: 19)
        )
        scrolledItems.append(
            getTooltipText(text: "tooltip_title_section",
                           font: UIFont.santander(family: .text, type: .bold, size: 16),
                           separator: 8)
        )
        let tooltipOptions = self.getOptions()
        for option in tooltipOptions {
            scrolledItems.append(
                getTooltipItem(text: option.textKey, image: option.iconKey)
            )
        }
        return scrolledItems
    }
    
    func defaultScrolledItems() -> [CustomOptionWithTooltipSendMoneyHome] {
        return [CustomOptionWithTooltipSendMoneyHome(text: "sendMoneyTooltip_text_favorites", icon: "icnSendToFavourite"),
                CustomOptionWithTooltipSendMoneyHome(text: "sendMoneyTooltip_text_atm", icon: "icnToACashier"),
                CustomOptionWithTooltipSendMoneyHome(text: "sendMoneyTooltip_text_onePay", icon: "icnOnePayFx"),
                CustomOptionWithTooltipSendMoneyHome(text: "sendMoneyTooltip_text_history", icon: "icnHistoryTransfer"),
                CustomOptionWithTooltipSendMoneyHome(text: "sendMoneyTooltip_text_periodic", icon: "icnScheduledShipments"),
                CustomOptionWithTooltipSendMoneyHome(text: "sendMoneyTooltip_text_donations", icon: "icnDonations")]
    }
}

private extension TransferHomeViewController {
    func getOptions() -> [CustomOptionWithTooltipSendMoneyHome] {
        if let sendMoneyHomeTooltipOptions: SendMoneyHomeTooltipProtocol = self.dependencies.resolve(forOptionalType: SendMoneyHomeTooltipProtocol.self) {
            return sendMoneyHomeTooltipOptions.getOptions()
        }
        return defaultScrolledItems()
    }
}

extension TransferHomeViewController: FAQSViewDelegate {
    func didSelectVirtualAssistant() {
        self.presenter.didSelectVirtualAssistant()
    }
    
    func didExpandAnswer(question: String) {
        self.presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        self.presenter.trackFaqEvent(question, url: url)
    }
}

extension TransferHomeViewController: EmittedTransfersViewDelegate {
    func didSelectHistoricalEmittedTransfers() {
        self.presenter.didSelectHistoricalEmittedTransfers()
    }
    
    func didSelectTransfer(_ viewModel: TransferViewModel) {
        self.presenter.didSelectViewModel(viewModel)
    }
    
    func didSelectScheduledTransfers() {
        self.presenter.didSelectScheduledTransfers()
    }
    
    func didSwipeEmmited() {
        self.presenter.didSwipeEmmited()
    }
}

extension TransferHomeViewController: ContactsViewDelegate {
    func didTapOnNewContact() {
        self.presenter.didSelectNewContact()
    }
    
    func didTapOnSeeContact() {
        self.presenter.didSelectContacts()
    }
    
    func didTapOnNewShipment() {
        self.presenter.didTapOnNewShipment()
    }
    
    func didTapOnContact(_ viewModel: ContactViewModel) {
        self.presenter.didSelectContact(viewModel)
    }
    
    func didSwipeContacts() {
        self.presenter.didSwipeContacts()
    }
}

extension TransferHomeViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .transfers
    }
}

extension TransferHomeViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollableStackView.getArrangedSubviews().isEmpty else { return }
        if scrollableStackView.scrollView.contentOffset.y >= 0 {
            scrollableStackView.scrollView.backgroundColor = .white
        } else {
            scrollableStackView.scrollView.backgroundColor = .skyGray
        }
    }
}

extension TransferHomeViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension TransferHomeViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int {
        1
    }
    
    public func searchButtonPressed() {
        doSearch()
    }
    
    func setIsSearchEnabled(_ enabled: Bool) {
        isSearchEnabled = enabled
    }
}
