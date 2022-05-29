import UIKit
import UI
import CoreFoundationLib
import MessageUI
import CoreDomain

protocol PersonalManagerViewProtocol: class, NavigationBarWithSearchProtocol {
    func setBanker(managers: [ManagerViewModel])
    func setPersonal(managers: [ManagerViewModel], toBankerView: Bool)
    func setOffice(managers: [ManagerViewModel])
    func personalManagerBanner(isVisible: Bool)
    func openMailComposerWith(subject: String?, to email: String)
    func showManagerDetailViewWith(viewModel: ManagerDetailViewModel)
    func setNotificationBadgeVisible(_ visible: Bool, inView identifier: String)
    func setOnlyOneBankerBackground()
    func changeToBankerNavigationBar()
}

protocol LaunchManagerActionsDelegate: class {
    func start(_ action: ManagerAction, managerType: ManagerType, forManagerWithCode code: String)
    func rateManager(withCode code: String)
    func imageActionForManager(withCode code: String)
}

protocol CanShowNotificationsBadgeProtocol {
    func showNotificationBadge(_ show: Bool, in viewIdentifier: String)
}

final class PersonalManagerViewController: UIViewController {
    @IBOutlet weak var fakeTopView: UIView?
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var banner: PersonalManagerBannerView?
    @IBOutlet weak var bannerBottomConstraint: NSLayoutConstraint?
    let separatorView = UIView()
    private let presenter: PersonalManagerPresenterProtocols
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewPressed)))
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.isUserInteractionEnabled = true
        return dimmingView
    }()
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    
    private var navigationBarType: ManagersNavigationBar? {
        didSet {
            checkNavigationBar()
        }
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: PersonalManagerPresenterProtocols) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNavigationBar()
        presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeDimmingView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
    }
    
    private func configureView() {
        self.banner?.isHidden = true
        self.bannerBottomConstraint?.constant = -(self.banner?.frame.height ?? 0.0)
        banner?.delegate = self
    }
    
    private func addBankerManager(_ manager: ManagerViewModel, with style: ManagerViewStyle) {
        let managerView = BankerManagerView()
        managerView.setStyle(style)
        managerView.setManagerInfo(manager, delegate: self)
        addArrangedView(managerView)
    }
    
    private func addPersonalManager(_ manager: ManagerViewModel) {
        let managerView = PersonalManagerView()
        managerView.setManagerInfo(manager, delegate: self)
        addArrangedView(managerView)
    }
    
    private func addOfficeManager(_ manager: ManagerViewModel) {
        let managerView = OfficeManagerView()
        managerView.setManagerInfo(manager, delegate: self)
        addArrangedView(managerView)
    }
    
    private func addArrangedView(_ view: UIView) {
        guard let stackView = stackView else { return }
        stackView.addArrangedSubview(view)
        view.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    private func configureBlueNavigationBar() {
        fakeTopView?.backgroundColor = UIColor.blueAnthracita
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .white),
            title: .title(key: "toolbar_title_manager")
        )
        builder.setRightActions(
            .image(image: "iconMenuWhite", action: #selector(drawerPressed))
        )
        builder.setLeftAction(
            .back(action: #selector(backButtonPressed))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_manager")
        )
        builder.setLeftAction(.back(action: #selector(backButtonPressed)))
        builder.setRightActions(.menu(action: #selector(drawerPressed)))
        builder.build(on: self, with: self.presenter)
    }
    
    private func checkNavigationBar() {
        switch navigationBarType {
        case .some(.banker):
            configureBlueNavigationBar()
        case .none, .normal:
            configureNavigationBar()
        }
    }
    
    @objc private func backButtonPressed() { presenter.goBackAction() }
    @objc public func searchButtonPressed() { presenter.searchAction() }
    @objc private func drawerPressed() { presenter.drawerAction() }
}

extension PersonalManagerViewController: PersonalManagerViewProtocol {
    
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
    
    func setBanker(managers: [ManagerViewModel]) {
        managers.forEach { addBankerManager($0, with: .bankerStyle)}
        hideLastSeparator()
    }
    
    func setPersonal(managers: [ManagerViewModel], toBankerView: Bool) {
        if toBankerView {
            managers.forEach { addBankerManager($0, with: .personalStyle) }
        } else {
            managers.forEach { addPersonalManager($0) }
        }
        hideLastSeparator()
    }
    
    func setOffice(managers: [ManagerViewModel]) {
        managers.forEach { addOfficeManager($0) }
        hideLastSeparator()
    }
    
    func personalManagerBanner(isVisible: Bool) {
        guard isVisible else {
            self.banner?.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.bannerBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
            return
        }
        self.bannerBottomConstraint?.constant = 10.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            self?.banner?.isHidden = false
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.bannerBottomConstraint?.constant = 0.0
                UIView.animate(withDuration: 0.1) {
                    self?.view.layoutIfNeeded()
                }
        })
    }
    
    func openMailComposerWith(subject: String?, to email: String) {
        let share: ShareCase = .mail(delegate: self, content: "", subject: subject, toRecipients: [email], isHTML: false)
        guard share.canShare() else {
            self.presenter.showEmailAlert()
            return
        }
        share.show(from: self)
    }
    
    func showManagerDetailViewWith(viewModel: ManagerDetailViewModel) {
        addDimmingView()
        let managerDetailView = ManagerDetailView(viewModel: viewModel)
        dimmingView.addSubview(managerDetailView)
        managerDetailView.translatesAutoresizingMaskIntoConstraints = false
        managerDetailView.leadingAnchor.constraint(equalTo: dimmingView.leadingAnchor, constant: 31.0).isActive = true
        dimmingView.trailingAnchor.constraint(equalTo: managerDetailView.trailingAnchor, constant: 31.0).isActive = true
        if #available(iOS 11.0, *) {
            managerDetailView.topAnchor.constraint(equalTo: dimmingView.safeAreaLayoutGuide.topAnchor, constant: 80.0).isActive = true
        } else {
            managerDetailView.topAnchor.constraint(equalTo: dimmingView.topAnchor, constant: 80).isActive = true
        }
        
        managerDetailView.closeAction = { [weak self] in
            self?.removeDimmingView()
        }
        
        managerDetailView.show()
    }
    
    func setOnlyOneBankerBackground() {
        view.backgroundColor = UIColor(red: 51 / 255, green: 59 / 255, blue: 69 / 255, alpha: 1)
    }
    
    func changeToBankerNavigationBar() {
        navigationBarType = .banker
    }
    
    func setNotificationBadgeVisible(_ visible: Bool, inView identifier: String) {
        self.stackView?.arrangedSubviews.forEach({
            ($0 as? CanShowNotificationsBadgeProtocol)?.showNotificationBadge(visible, in: identifier)
        })
    }
    
    private func addDimmingView() {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        guard !(currentWindow?.subviews.contains(dimmingView) ?? true) else { return }
        currentWindow?.addSubview(dimmingView)
    }
    
    @objc private func dimmingViewPressed() {
        if let managerDetailView = (dimmingView.subviews.first { $0 is ManagerDetailView }) as? ManagerDetailView {
            managerDetailView.hide()
        } else {
            removeDimmingView()
        }
    }
    
    private func removeDimmingView() {
        dimmingView.removeFromSuperview()
    }
    
    private func hideLastSeparator() {
        guard let stackView = stackView else { return }
        stackView.arrangedSubviews.enumerated().forEach({
            ($0.element as? PersonalManagerView)?.hideBottomSeparation($0.element == stackView.arrangedSubviews.last)
        })
    }
}

extension PersonalManagerViewController: LaunchManagerActionsDelegate {
    func start(_ action: ManagerAction, managerType: ManagerType, forManagerWithCode code: String) {
        self.presenter.start(action, managerType: managerType, forManagerWithCode: code)
    }
    
    func rateManager(withCode code: String) {
        presenter.rateManager(withCode: code)
    }
    
    func imageActionForManager(withCode code: String) {
        presenter.imageActionForManager(withCode: code)
    }
}

extension PersonalManagerViewController: PersonalManagerBannerViewDelegate {
    func moreInfoDidPressed() {
        presenter.moreInfoAction()
    }
}

extension PersonalManagerViewController: RootMenuController {
    
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension PersonalManagerViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return nil
    }
}
enum ManagersNavigationBar {
    case normal
    case banker
}
