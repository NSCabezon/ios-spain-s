import UIKit.UIImage
import CoreFoundationLib
import UI

protocol PrivateSideMenuPresenterProtocol: MultiTableViewSectionsDelegate, PrivateSideMenuFooterProtocol, Presenter {
    var personalAreaTitle: LocalizedStylableText { get }
    var digitalProfileTitle: LocalizedStylableText { get }
    var hideDigitalProfile: Bool { get }
    func didTapPersonalArea()
    func didTapDigitalProfile()
    func topOption() -> PrivateMenuOption
    func didTapHelpUs()
    func didTapCloseCoachmark()
    func coachmarkDisplayed()
    func menuItems() -> [MenuItemViewModelSection]
    func selectSection(_ section: TableModelViewSection)
    func didShowSideMenu(_ isVisible: Bool)
    func reloadNameHeader()
}

final class PrivateSideMenuViewController: BaseViewController<PrivateSideMenuPresenterProtocol>, TableDataSourceDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuHeaderView: PrivateUserHeader!
    @IBOutlet weak var optionsBarContainer: UIView!
    @IBOutlet weak var bottomOptionsBarView: OptionsBarView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dashSeparatorView: UIView!
    @IBOutlet weak var helpUsButton: BannerPressFXView!
    private var digitalProfileView: DigitalProfileView!
    private var userNameView: UserNameView = UserNameView()
    private lazy var avatarView: UserAvatarView = {
        let view = UserAvatarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    private weak var coachmarkView: BackgroundCoachmarkView?

    private func createCoachMarkView() -> BackgroundCoachmarkView {
        return BackgroundCoachmarkView()
    }
    
    override var isKeyboardDismisserActivated: Bool {
        return false
    }

    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .clear(tintColor: .clear)
    }
    
    lazy private var adapter: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()
    
    override func prepareView() {
        view.backgroundColor = .sky30
        tableView.alwaysBounceVertical = false
        tableView.accessibilityIdentifier = "PrivateSideMenuTable"
        tableView.alpha = 0.0
        setupHeader()
        setupFooter()
        self.setAccessibilityIdentifiers()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedLanguageReceived),
                                               name: Notification.Name("ChangedLanguageApp"),
                                               object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityElementsHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupHeader() {
        if let option = presenter?.topOption() {
            self.menuHeaderView.setOptions([option])
        }
        self.avatarView.addAction { [weak self] in
            self?.presenter.didTapPersonalArea()
        }
        self.menuHeaderView.setLeftView(avatarView)
        self.userNameView.setSubTitle(presenter?.personalAreaTitle)
        self.userNameView.setIconImageKey("icnSetting")
        self.userNameView.addAction { [weak self] in
            self?.presenter.didTapPersonalArea()
        }
        let digitalProfileView = DigitalProfileView()
        digitalProfileView.addAction { [weak self] in
            self?.presenter.didTapDigitalProfile()
        }
        self.digitalProfileView = digitalProfileView
        self.digitalProfileView.isHidden = self.presenter.hideDigitalProfile
        digitalProfileView.setSubTitle(presenter?.digitalProfileTitle)
        self.menuHeaderView.setMiddleViews([userNameView, digitalProfileView])
        self.menuHeaderView.backgroundColor = .sky30
    }
    
    private func setupFooter() {
        separatorView.backgroundColor = .mediumSkyGray
        optionsBarContainer.backgroundColor = .sky30
        dashSeparatorView.drawShadow(offset: (x: 0, y: 0), opacity: 1, color: .coolGray, radius: 2.0)
        bottomOptionsBarView.backgroundColor = .sky30

        if let opinatorTitle = presenter?.opinatorTitle {
            helpUsButton.setTitle(opinatorTitle)
            helpUsButton.setIcon("icnHelpUs")
            helpUsButton.action = { [weak self] in
                self?.presenter?.didTapHelpUs()
            }
            helpUsButton.pressFXColor = .lightSky
            helpUsButton.isHidden = false
        } else {
            helpUsButton.isHidden = true
        }
    }
    
    func setBottomOptions(_ options: [PrivateMenuOption]) {
        bottomOptionsBarView.setOptions(options)
    }
    
    func setNotificationBadgeVisible(_ visible: Bool, inCoachmark id: CoachmarkIdentifier?) {
        bottomOptionsBarView.setNotificationBadgeVisible(visible, inCoachmark: id)
    }
	
	private func setAccessibilityIdentifiers() {
		// Up area
		avatarView.accessibilityIdentifier = AccessibilitySideMenu.btnPhoto
		userNameView.accessibilityIdentifier = AccessibilitySideMenu.btnPersonalArea
		digitalProfileView.accessibilityIdentifier = AccessibilitySideMenu.btnDigitalProfile
		// Exit Button created by MenuOptionData
		
        self.helpUsButton.isAccessibilityElement = true
        self.helpUsButton.accessibilityIdentifier = AccessibilitySideMenu.btnHelpUsImprove
		bottomOptionsBarView.accessibilityIdentifier = AccessibilitySideMenu.btnImprove.rawValue
		// Bottom buttons created by MenuOptionData
	}
    
    @objc private func changedLanguageReceived() {
        presenter?.loadViewData()
        setupHeader()
        setupFooter()
        if let option = presenter?.topOption() {
            menuHeaderView.setOptions([option])
        }
        
    }
    
    func setUserName(_ name: String) {
        userNameView.setTitle(name)
    }
    
    func setDigitalProfileProgress(value: Float, text: String) {
        digitalProfileView.setPercentage(value: value, text: text)
    }
    
    func resetProgress() {
        digitalProfileView.resetProgress()
    }
    
    func setUserInitials(_ initials: String) {
        avatarView.setTitle(initials)
    }
    
    func setAvatarImage(_ data: Data) {
        avatarView.setImage(UIImage(data: data))
    }
        
    func reloadOptions() {
        adapter.clearSections()
        let options = presenter.menuItems()
        adapter.addSections(options)
        self.presenter.reloadNameHeader()
        tableView.reloadData()
        tableView.delegate = adapter
        tableView.dataSource = adapter
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 15.0, right: 0)
        tableView.registerCells(["MenuFeaturedItemTableViewCell"])
    }
    
    func animateTableViewOptions() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            self?.tableView.alpha = 1.0
        }, completion: nil)
        
        _ = self.adapter.sections.filter { $0.isFeatured == true }.map({
            let item = $0.items[0] as? SideMenuFeaturedItemTableViewModel
            item?.animationCell()
        })
    }
    
    func resetTableViewOptions() {
        self.tableView.alpha = 0.0
        
        _ = self.adapter.sections.filter { $0.isFeatured == true }.map({
            let item = $0.items[0] as? SideMenuFeaturedItemTableViewModel
            item?.resetAnimationCell()
        })
    }
    
    override class var storyboardName: String {
        return "PrivateMenuStoryboard"
    }
        
    // MARK: - TableDataSourceDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
        let section = adapter.sections[indexPath.section]
        presenter.selectSection(section)
    }
    
    func hideCoachmark() {
        coachmarkView?.removeFromSuperview()
    }
    
    func displayCoachmarkIfNeeded(_ coachmarkInfo: ManagerCoachmarkInfo) {
        let content = ManagerCoachmarkView()

        content.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        content.onCloseAction = { [weak self] in
            self?.presenter.didTapCloseCoachmark()
        }
        let coachmarkView = createCoachMarkView()
        coachmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        if let currentWindow: UIWindow = UIApplication.shared.keyWindow {
            coachmarkView.embedInto(container: currentWindow)
            presenter.coachmarkDisplayed()
        }
        
        guard let coachmarkedView = view.findView(prot: CoachmarkPointableView.self).filter({$0.coachmarkId == .sideMenuManager}).first as? UIView & CoachmarkPointableView else {
            return
        }

        let finalPoint = coachmarkedView.coachmarkPoint
        let convertedPoint = coachmarkedView.convert(finalPoint, to: coachmarkView)
                
        content.translatesAutoresizingMaskIntoConstraints = false
        content.setCoachmarkInfo(coachmarkInfo)
        coachmarkView.addSubview(content)
        content.widthAnchor.constraint(equalTo: coachmarkView.widthAnchor, multiplier: 0.8).isActive = true
        content.relativeCenterXAnchor.constraint(equalTo: coachmarkView.leftAnchor, constant: convertedPoint.x + 10).isActive = true
        content.relativeCenterYAnchor.constraint(equalTo: coachmarkView.topAnchor, constant: convertedPoint.y - 10).isActive = true
        content.topAnchor.constraint(greaterThanOrEqualTo: coachmarkView.topAnchor, constant: 0).isActive = true
        
        self.coachmarkView = coachmarkView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideCoachmark()
    }
}

extension PrivateSideMenuViewController: MenuEventCapable {
    
    func didShowSideMenu(_ isVisible: Bool) {
        presenter.didShowSideMenu(isVisible)
    }
}
