import CoreFoundationLib
import UIKit
import UI
import CoreDomain

protocol SecurityAreaViewProtocol: NavigationBarWithSearchProtocol {
    func setSecurityAreaActions(_ viewModels: [SecurityActionViewModelProtocol])
    func setSecurityTips(_ viewModels: [HelpCenterTipViewModel])
    func showBiometryMessage(localizedKey: String, biometryType: BiometryTypeEntity)
    func showBiometryAlert(localizedKey: String, biometryText: String)
    func setContainer(_ view: UIView)
}

final class SecurityAreaViewController: UIViewController {
    let presenter: SecurityAreaPresenterProtocol
    let biometryViewHelper: BiometryViewHelper
    let scrollableStackView = ScrollableStackView()
    let securityActionView = SecurityAreaActionsView()
    var tipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView()
        view.setTitleAccessibilityIdentifier("security_title_securityTips")
        return view
    }()
    public var isSearchEnabled: Bool = false {
        didSet { self.setUpNavigationBar() }
    }
    
    init(dependenciesResolver: DependenciesResolver, presenter: SecurityAreaPresenterProtocol) {
        self.presenter = presenter
        self.biometryViewHelper = BiometryViewHelper(dependenciesResolver: dependenciesResolver)
        super.init(nibName: "SecurityAreaViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var isReplacingViewControllersStack: Bool = false 
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        guard !isReplacingViewControllersStack else { return }
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        guard !isReplacingViewControllersStack else { return }
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
        self.presenter.didBecomeActive()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(didBecomeActive),
                         name: UIApplication.didBecomeActiveNotification,
                         object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        guard !isReplacingViewControllersStack else { return }
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didBecomeActive() {
        self.presenter.didBecomeActive()
    }
    
    private func setupView() {
        self.scrollableStackView.setup(with: self.view)
        self.securityActionView.delegate = self
        self.scrollableStackView.addArrangedSubview(self.securityActionView)
    }
    
    private func setUpNavigationBar() {
        let builder: NavigationBarBuilder
        if presenter.showIconTitleHeader {
            builder = NavigationBarBuilder(
                style: .sky,
                title: .tooltip(
                    titleKey: "menu_link_security",
                    type: .red,
                    action: { sender in
                        self.showGeneralTooltip(sender)
                    }
                )
            )
        } else {
            builder = NavigationBarBuilder(
                style: .sky,
                title: .title(key: "menu_link_security")
            )
        }
        builder.setRightActions(
            .menu(action: #selector(openMenu))
        )
        builder.setLeftAction(
            .back(action: #selector(dismissViewController))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    func getTooltipText(text: String, font: UIFont, separator: CGFloat) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: localized(text), left: 18, right: 18, font: font, textColor: .lisboaGray, labelAccessibilityID: text)
        let view = LabelTooltipView(configuration: configuration, labelIdentifier: text)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    func getTooltipItem(text: String, image: String) -> FullScreenToolTipViewItemData {
        let configuration = SecurityTooltipViewConfiguration(image: Assets.image(named: image),
                                                             text: localized(text),
                                                             imageAccessibilityId: image,
                                                             labelAccessibilityId: text)
        let view = SecurityTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 8)
        return item
    }
    
    func showGeneralTooltip(_ sender: UIView) {
        let titleView = getTooltipText(text: "securityTooltip_title_security",
                                       font: UIFont.santander(family: .text, type: .bold, size: 20),
                                       separator: 8)
        let descriptionView = getTooltipText(text: "securityTooltip_text_security",
                                             font: UIFont.santander(family: .text, type: .light, size: 16),
                                             separator: 19)
        let optionsTitle = getTooltipText(text: "tooltip_title_section",
                                          font: UIFont.santander(family: .text, type: .bold, size: 16),
                                          separator: 8)
        let tooltips = presenter.tooltipItems.map { getTooltipItem(text: $0.text, image: $0.image) }
        let stickyItems = [titleView]
        let scrolledItems = [descriptionView, optionsTitle] + tooltips
        let configuration = FullScreenToolTipViewData(topMargin: 0, stickyItems: stickyItems, scrolledItems: scrolledItems)
        configuration.show(in: self, from: sender)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc func searchButtonPressed() {
        self.presenter.didSelectSearch()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

extension SecurityAreaViewController: SecurityAreaViewProtocol {
    public var searchButtonPosition: Int {
        return 1
    }
    
    public func isSearchEnabled(_ enabled: Bool) {
        self.isSearchEnabled = enabled
    }
    
    func setSecurityAreaActions(_ viewModels: [SecurityActionViewModelProtocol]) {
        self.securityActionView.setViewModels(viewModels)
    }
    
    func setSecurityTips(_ viewModels: [HelpCenterTipViewModel]) {
        if !viewModels.isEmpty {
            self.tipsView.setViewModels(viewModels, addAccessibilitySuffix: true)
            self.tipsView.setStyle(.securityTipsStyle())
            self.tipsView.setTitle(localized("security_title_securityTips"))
            self.scrollableStackView.addArrangedSubview(self.tipsView)
           self.tipsView.tipDelegate = self
        }
    }
    
    func showBiometryMessage(localizedKey: String, biometryType: BiometryTypeEntity) {
        self.biometryViewHelper.showBiometryMessage(
            localizedKey: localizedKey,
            biometryType: biometryType
        )
    }
    
    func showBiometryAlert(localizedKey: String, biometryText: String) {
        self.biometryViewHelper.showBiometryAlert(
            localizedKey: localizedKey,
            biometryText: biometryText
        )
    }
    
    func setContainer(_ view: UIView) {
        self.scrollableStackView.insetArrangedSubview(view, at: 0)
    }
}

extension SecurityAreaViewController: SecurityAreaActionsViewProtocol {
    func didSelectSecurityAction(_ action: SecurityActionType) {
        self.presenter.didSelectAction(action)
    }
    
    func didSelectSecuritySwitchAction(_ action: SecurityActionType, isSwitchOn: Bool) {
        self.presenter.didSelectSwitchAction(action, isSwitchOn)
    }
    
    func didSelectSecuritySwitchCustomAction(_ action: CustomAction, isSwitchOn: Bool) {
        self.presenter.didSelectSwitchCustomAction(action, isSwitchOn)
    }
    
    func didSelectVideo(_ viewModel: SecurityVideoViewModel) {
        self.presenter.didSelectVideo(viewModel)
    }
}

extension SecurityAreaViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return nil
    }
}

extension SecurityAreaViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension SecurityAreaViewController: HelpCenterTipsViewDelegate {
    func didSelectTip(_ viewModel: Any) {
        guard let viewModel = viewModel as? HelpCenterTipViewModel else { return }
        self.presenter.didSelectSecurityTip(viewModel)
    }
    
    func didSelectSeeAllTips() {
    }
    
    func scrollViewDidEndDecelerating() {
        presenter.securityTipsScrollViewDidEndDecelerating()
    }
}
