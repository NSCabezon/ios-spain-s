import UIKit
import UI
import CoreFoundationLib

protocol InboxHomeViewProtocol: NavigationBarWithSearchProtocol {
    func showPendingSolicitudes(_ viewModels: [PendingSolicitudeInboxViewModel])
    func showActions(_ viewModels: [InboxActionViewModel])
    func didToast()
}

final class InboxHomeViewController: UIViewController {
    private let presenter: InboxHomePresenterProtocol
    private let pendingSolicitudesView = PendingSolicitudesView()
    private let scrollableStackView = ScrollableStackView()
    public var isSearchEnabled: Bool = false {
        didSet { self.setupNavigationBar() }
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: InboxHomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    private func setupView() {
        self.view.backgroundColor = UIColor.bg
        self.scrollableStackView.setup(with: self.view)
        self.scrollableStackView.addArrangedSubview(pendingSolicitudesView)
        self.pendingSolicitudesView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParent { // View is being presented
            self.setupNavigationBar()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBeingPresented && !isMovingToParent { // Returned from detail view
            self.setupNavigationBar()
        }
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_mailbox")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc func searchButtonPressed() {
        presenter.didSelectSearch()
    }
}

extension InboxHomeViewController: InboxHomeViewProtocol {
    
    func showPendingSolicitudes(_ viewModels: [PendingSolicitudeInboxViewModel]) {
        self.pendingSolicitudesView.isHidden = false
        self.pendingSolicitudesView.setViewModels(viewModels)
    }
    
    func showActions(_ viewModels: [InboxActionViewModel]) {
        self.removeIboxActionView()
        self.addSeparatorView()
        viewModels.forEach {
            let action = InboxActionView($0)
            action.delegate = self
            self.scrollableStackView.addArrangedSubview(action)
            self.addSeparatorView()
        }
    }
    
    func didToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func removeIboxActionView() {
        for view in self.scrollableStackView.getArrangedSubviews() {
            if  view is PendingSolicitudesView {
                continue
            } else {
                view.removeFromSuperview()
            }
        }
    }
    
    func addSeparatorView() {
        let separatorView = UIView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.backgroundColor = UIColor.mediumSkyGray
        self.scrollableStackView.addArrangedSubview(separatorView)
    }
    
    public var searchButtonPosition: Int {
        return 1
    }
    
    public func isSearchEnabled(_ enabled: Bool) {
        self.isSearchEnabled = enabled
    }
}

extension InboxHomeViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension InboxHomeViewController: InboxActionViewDelegate {
    func didSelectAction(type: InboxActionType) {
        self.presenter.didSelectAction(type: type)
    }
}
