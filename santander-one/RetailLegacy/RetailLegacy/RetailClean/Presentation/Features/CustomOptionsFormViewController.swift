import UIKit

protocol CustomFormPresenterProtocol: Presenter {
}

class CustomOptionsFormViewController: BaseViewController<CustomFormPresenterProtocol> {
    @IBOutlet weak var optionsView: CustomFormOptionsView!
    @IBOutlet weak var separtorView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var optionsContainerView: UIView!
    private lazy var notificationCenter = NotificationCenter.default
    private var executeWhenReturnFromBackground: (() -> Void)?

    lazy var dataSource: StackDataSource = { StackDataSource(stackView: stackView, delegate: self) }()
    override class var storyboardName: String {
        return "CustomOptionsForm"
    }
    var isSideMenuCapable = false
    var showMenuClosure: (() -> Void)?
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiWhite
        stackView.backgroundColor = .uiBackground
        scrollView.backgroundColor = .uiBackground
        separtorView.backgroundColor = .lisboaGray
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30.0, right: 0)
        optionsContainerView.isHidden = true
    }
    
    func executeWhenReturnFromBackground(_ closure: @escaping () -> Void) {
        notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        executeWhenReturnFromBackground = closure
    }
    
    @objc func appMovedFromBackground() {
        executeWhenReturnFromBackground?()
    }
    
    // MARK: - Bottom Options
    
    func setActionOptions(_ actions: [CustomFormOptionActionType]) {
        optionsContainerView.isHidden = actions.isEmpty
        optionsView.setActions(actions)
    }
    
    // MARK: - Side Menu
    
    @objc override func showMenu() {
        showMenuClosure?()
    }
    
    func setTitle(_ title: String) {
        self.title = title
    }
    
    deinit {
        if executeWhenReturnFromBackground != nil {
            notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
}

// MARK: - ToolTipDisplayer

extension CustomOptionsFormViewController: ToolTipDisplayer {}

// MARK: - StackDataSourceDelegate

extension CustomOptionsFormViewController: StackDataSourceDelegate {
    func scrollToVisible(view: UIView) {
        scrollView.scrollRectToVisible(view.frame, animated: true)
    }
}

extension CustomOptionsFormViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return isSideMenuCapable
    }
}
