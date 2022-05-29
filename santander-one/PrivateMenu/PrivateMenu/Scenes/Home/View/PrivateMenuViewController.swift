//
//  PrivateMenuViewController.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 16/12/21.
//

import UI
import CoreFoundationLib
import OpenCombine
import Dispatch
import CoreDomain
import CoreGraphics

final class PrivateMenuViewController: UIViewController {
    private enum Constants {
        static let tableAnimationDelay: TimeInterval = 0.2
        static let cellAnimationDelay: TimeInterval = 0.5
        static let animationDuration: TimeInterval = 0.2
        static let maxAlpha: CGFloat = 1.0
        static let defaultOpacity: Float = 1.0
        static let tableInsetTop: CGFloat = 16.0
        static let tableInsetBottom: CGFloat = 15.0
        static let componentDefaultRadio: CGFloat = 2.0
        static let managerAnchorPoint: CGFloat = 10
        static let managerAnchorPointPositionWith: CGFloat = 50
        static let managerAnchorPointPositionHeight: CGFloat = 110
        static let managerMultiplier: CGFloat = 0.8
        static let languageChangedNotification: Notification.Name = Notification.Name("ChangedLanguageApp")
        static let menuCellIdentifier = "MenuItemTableViewCell"
        static let viewControllerNib = "PrivateMenuViewController"
    }
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var menuHeaderView: PrivateUserHeader!
    @IBOutlet private weak var optionsBarContainer: UIView!
    @IBOutlet private weak var bottomOptionsBarView: OptionsBarView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var dashSeparatorView: UIView!
    @IBOutlet private weak var helpUsButton: BannerPressFXView!
    private let viewModel: PrivateMenuViewModel
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: PrivateMenuDependenciesResolver
    private var localAppConfig: LocalAppConfig {
        self.dependencies.external.resolve()
    }
    private weak var backgroundMyManagerView: BackgroundMyManagerView?

    init(dependencies: PrivateMenuDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: Constants.viewControllerNib, bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuHeaderView.isUserInteractionEnabled = true
        prepareView()
        bindViews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - ViewController Actions

private extension PrivateMenuViewController {
    
    func setNotificationBadgeVisible(_ visible: Bool) {
        bottomOptionsBarView.setNotificationBadgeVisible(visible)
    }
    
    @objc private func changedLanguageReceived() {
        setupHeader()
        setupFooter()
    }
    
    func animateTableView() {
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: Constants.tableAnimationDelay,
                       options: .curveEaseIn, animations: { [weak self] in
            self?.tableView.alpha = Constants.maxAlpha
        }, completion: nil )
    }
    
    func animateFeaturedCells() {
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: Constants.cellAnimationDelay,
                       options: .curveEaseIn, animations: { [weak self] in
            if let visibleCells = self?.tableView.visibleCells as? [MenuItemTableViewCell] {
                let featuredCells =  visibleCells.filter { $0.isFeaturedCell == true }
                featuredCells.forEach { $0.animateViewCell() }
            }
        }, completion: nil)
    }
}

// MARK: - ViewController Setup UI

private extension PrivateMenuViewController {
    func registerCell() {
        let menuFeaturedCell = UINib(nibName: "MenuItemTableViewCell", bundle: .module)
        self.tableView.register(menuFeaturedCell, forCellReuseIdentifier: Constants.menuCellIdentifier)
    }
    
    func setupHeader() {
        self.menuHeaderView.setLeftView()
        self.menuHeaderView.backgroundColor = .skyGray
        let hideDigitalProfile = !self.localAppConfig.isEnabledDigitalProfileView
        self.menuHeaderView.hideDigitalProfileView(isHidden: hideDigitalProfile)
    }
    
    func setupFooter() {
        separatorView.backgroundColor = .mediumSkyGray
        optionsBarContainer.backgroundColor = .skyGray
        dashSeparatorView.drawShadow(offset: (x: .zero, y: .zero),
                                     opacity: Constants.defaultOpacity,
                                     color: .coolGray,
                                     radius: Constants.componentDefaultRadio)
        bottomOptionsBarView.backgroundColor = .skyGray
        helpUsButton.setIcon("icnHelpUs")
        helpUsButton.setTitleWithKey("menu_link_improve")
        helpUsButton.pressFXColor = .lightSky
        helpUsButton.isHidden = false
        helpUsButton.action = { [weak self] in
            self?.viewModel.didSelectHelpUs()
        }
        
    }
    
    func setupTable() {
        tableView.alwaysBounceVertical = false
        tableView.accessibilityIdentifier = "PrivateSideMenuTable"
        tableView.separatorStyle = .none
        tableView.alpha = .zero
        tableView.contentInset = UIEdgeInsets(top: Constants.tableInsetTop,
                                              left: .zero,
                                              bottom: Constants.tableInsetBottom,
                                              right: .zero)
        registerCell()
    }
    
    func setAccessibilityIdentifiers() {
        helpUsButton.accessibilityIdentifier = AccessibilitySideMenu.btnHelpUsImprove
        helpUsButton.isAccessibilityElement = true
    }
    
    func prepareView() {
        view.backgroundColor = .skyGray
        setupTable()
        setupHeader()
        setupFooter()
        setAccessibilityIdentifiers()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedLanguageReceived),
                                               name: Constants.languageChangedNotification,
                                               object: nil)
    }
    
    func displayMyManager(_ info: ManagerCoachmarkInfoRepresentable) {
        guard info.showsManagerCoach == true else { return }
        let backgroundView = BackgroundMyManagerView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.embedInto(container: view)
        let managerView = createManagerCoachmarkView(info)
        managerView.translatesAutoresizingMaskIntoConstraints = false
        managerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        backgroundView.addSubview(managerView)
        self.backgroundMyManagerView = backgroundView
        guard let managerAnchorPoint = getAnchorManagerPoint() else { return }
        managerView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor,
                                           multiplier: Constants.managerMultiplier).isActive = true
        managerView.relativeCenterXAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: managerAnchorPoint.x - Constants.managerAnchorPoint).isActive = true
        managerView.relativeCenterYAnchor.constraint(equalTo: backgroundView.topAnchor, constant: managerAnchorPoint.y + Constants.managerAnchorPoint).isActive = true
        managerView.topAnchor.constraint(greaterThanOrEqualTo: backgroundView.topAnchor).isActive = true
    }
    
    func createManagerCoachmarkView(_ info: ManagerCoachmarkInfoRepresentable) -> ManagerCoachmarkView {
        let managerView = ManagerCoachmarkView()
        managerView.subject.send(info)
        managerView.tapCloseSubject
            .sink { [unowned self] in
                hideMyManager()
            }.store(in: &anySubscriptions)
        managerView.tapOfferSubject
            .sink { [unowned self] in
                hideMyManager()
                viewModel.didSelectMyManager(info.offerRepresentable)
            }.store(in: &anySubscriptions)
        return managerView
    }
    
    func getAnchorManagerPoint() -> CGPoint? {
        return CGPoint(x: view.frame.width - Constants.managerAnchorPointPositionWith,
                       y: view.frame.height - Constants.managerAnchorPointPositionHeight)
    }
    
    func hideMyManager() {
        backgroundMyManagerView?.removeFromSuperview()
    }
}

// MARK: - Binding

private extension PrivateMenuViewController {
    func bindViews() {
        bindFooterOptions()
        bindHeaderView()
        bindMenuOptions()
        bindMenuEvents()
        bindYourManager()
        bindShowMyManager()
        bindDidHideMenu()
    }
    
    func bindMenuOptions() {
        viewModel.state
            .case (PrivateMenuState.menuOptions)
            .map { values in
                values.map { PrivateMenuMainOption(item: $0) }
            }
            .bind(subscriber: self.tableView.rowsSubscriber(cellIdentifier: Constants.menuCellIdentifier,
                                                            cellType: MenuItemTableViewCell.self)
                  { cell, indexpath, model in
                cell.configureWithModel(model)
            })
            .store(in: &anySubscriptions)
        
        // MARK: - TableView Events
        self.tableView.selectedCellSubject()?.sink(receiveValue: { [weak self] item in
            guard let self = self,
                  let selectedIem = item as? PrivateMenuOptionRepresentable else { return }
            self.viewModel.didSelectOption(selectedIem)
        })
        .store(in: &anySubscriptions)
    }

    func bindFooterOptions() {
        viewModel.state
            .case (PrivateMenuState.footerOptions)
            .map { values in
                values.map { PrivateMenuFooterOption(option: $0) }
            }
            .subscribe(bottomOptionsBarView.optionsSubject)
            .store(in: &anySubscriptions)
        
        viewModel.state
            .case (PrivateMenuState.personalManagerBadge)
            .subscribe(bottomOptionsBarView.personalManagerBadgeSubject)
            .store(in: &anySubscriptions)
        
        bottomOptionsBarView
            .didSelectOptionSubject
            .sink { [unowned self] value in
                switch value {
                case .atm:
                    self.viewModel.didSelectATM()
                case .helpCenter:
                    self.viewModel.didSelectHelpCenter()
                case .myManager:
                    self.viewModel.didSelectMyManager()
                case .security:
                    self.viewModel.didSelectSecurity()
                }
            }.store(in: &anySubscriptions)
    }
    
    func bindHeaderView() {
        viewModel.state
            .case(PrivateMenuState.isDigitalProfileEnabled)
            .map { $0 }
            .subscribe(menuHeaderView.isDigitalProfileEnabledSubject)
            .store(in: &anySubscriptions)
        
        viewModel.state
            .case (PrivateMenuState.digitalProfilePercentage)
            .map { $0 }
            .subscribe(menuHeaderView.digitalProfilePercentageSubject)
            .store(in: &anySubscriptions)
        
        viewModel.state
            .case (PrivateMenuState.nameOrAlias)
            .map { $0 }
            .subscribe(menuHeaderView.nameOrAliasSubject)
            .store(in: &anySubscriptions)
        
        viewModel.state
            .case (PrivateMenuState.avatarImage)
            .map { $0 }
            .subscribe(menuHeaderView.avatarImageSubject)
            .store(in: &anySubscriptions)
        
        menuHeaderView
            .tapPersonalAreaSubject
            .sink { [unowned self] _ in
                self.viewModel.didSelectPersonalArea()
            }.store(in: &anySubscriptions)
        
        menuHeaderView
            .tapCloseMenuButtonSubject
            .sink { [unowned self] _ in
                self.viewModel.closeSideMenu()
            }.store(in: &anySubscriptions)
        
        menuHeaderView
            .tapLogOutSubject
            .sink { [unowned self] _ in
                self.viewModel.didSelectLogOut()
            }.store(in: &anySubscriptions)
    }
    
    func bindMenuEvents() {
        viewModel.state
            .case (PrivateMenuState.menuVisible)
            .sink { [unowned self] _ in
                self.animateTableView()
                self.animateFeaturedCells()
            }.store(in: &anySubscriptions)
    }
    
    func bindYourManager() {
        viewModel.state
            .case(PrivateMenuState.yourManager)
            .sink { _ in
            } receiveValue: { [unowned self] manager in
                guard let imageData = manager.thumbnailData,
                        let image = UIImage(data: imageData) else { return }
                self.bottomOptionsBarView.personalManagerImageSubject.send(image)
            }.store(in: &anySubscriptions)
    }
    
    func bindShowMyManager() {
        viewModel.state
            .case(PrivateMenuState.showCoachManager)
            .sink { [unowned self] info in
                displayMyManager(info)
            }.store(in: &anySubscriptions)
    }
    
    func bindDidHideMenu() {
        viewModel.state
            .case(PrivateMenuState.didHideMenu)
            .sink { [unowned self] _ in
                self.hideMyManager()
            }
            .store(in: &anySubscriptions)
    }
}
