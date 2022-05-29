import CoreFoundationLib
import UI
import CoreDomain

enum RightBarButton {
    case menu
    case close
    case share
    case title
    case none
    
    var image: UIImage? {
        switch self {
        case .menu:
            return Assets.image(named: "icnMenu")
        case .close:
            return Assets.image(named: "icnClose")
        case .share:
            return Assets.image(named: "icnShareWhite")
        case .title:
            return nil
        case .none:
            return nil
        }
    }
}

extension RightBarButton: AccessibilityProtocol {
    var accessibilityIdentifier: String? {
        switch self {
        case .menu:
            return AccessibilityOthers.btnMenu.rawValue
        case .close:
            return AccessibilityOthers.btnClose.rawValue
        default:
            return nil
        }
    }
    var accessibilityLabel: String? {
        switch self {
        case .menu: return localized("generic_label_menu")
        case .close: return localized("siri_voiceover_close")
        case .share: return localized("generic_button_share")
        default: return nil
        }
    }
}

class BaseViewController<P>: UIViewController, NotRotatable, WillAppearActionable {
    
    class func create<T>(stringLoader: StringLoader) -> T where T: BaseViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .module)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? T else {
            fatalError("View Controller not found!!")
        }
        viewController.stringLoader = stringLoader
        return viewController
    }
    
    class var storyboardName: String {
        fatalError("FatalError: View controller storyboard not set")
    }
    class var viewControllerIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var navigationBarTitleLabel: UILabel = UILabel()
    var logTag: String {
        return String(describing: type(of: self))
    }
    var willAppearAction: (() -> Void)? {
        set {
            var willAppearActionable = (presenter as? WillAppearActionable)
            willAppearActionable?.willAppearAction = newValue
        }
        get {
            return (presenter as? WillAppearActionable)?.willAppearAction
        }
    }
    var stringLoader: StringLoader!
    var customTitle: String?
    var styledTitle: LocalizedStylableText? {
        didSet {
            title = styledTitle?.text
        }
    }
    
    var localizedSubTitleKey: String?
    
    var isKeyboardDismisserActivated: Bool {
        return true
    }
    
    private var isKeyboardDismisserAllowed: Bool {
        return parent == nil || parent is UINavigationController
    }
    
    override var title: String? {
        get {
            return super.title
        }
        set {
            guard view.window != nil || super.title == nil else {
                return
            }
            super.title = newValue
            if navigationItem.titleView == nil {
                navigationItem.titleView = navigationBarTitleLabel
            }
            if let title = styledTitle {
                navigationBarTitleLabel.set(localizedStylableText: title)
            } else {
                navigationBarTitleLabel.text = title
            }
            guard let title = title, title != blankTitle else {
                return
            }
            customTitle = title
            navigationBarTitleLabel.sizeToFit()
        }
    }
    
    var titleIdentifier: String? {
        didSet {
            navigationBarTitleLabel.isAccessibilityElement = true
            navigationBarTitleLabel.accessibilityIdentifier = titleIdentifier
        }
    }
    
    var hidesBackButton: Bool {
        return navigationItem.hidesBackButton
    }
    
    var presenter: P!
    
    private lazy var keyboardDismisser: KeyboardDismisser? = {
        guard isKeyboardDismisserActivated, isKeyboardDismisserAllowed else {
            return nil
        }
        return KeyboardDismisser(viewController: self)
    }()
    
    private let blankTitle = " "
    
    func show(barButton: RightBarButton) {
        switch barButton {
        case .menu:
            if let menuTextWrapper = self.presenter as? MenuTextGetProtocol {
                menuTextWrapper.get(completion: { [weak self] configuration in
                    guard let self = self else { return }
                    if let text = configuration[.menu] {
                        self.addMenu(text: text, selector: #selector(self.showMenu))
                    } else {
                        self.add(barButton, selector: #selector(self.showMenu))
                    }
                })
            } else {
                self.add(barButton, selector: #selector(self.showMenu))
            }
        case .close:
            add(barButton, selector: #selector(closeButtonTouched))
        case .share:
            add(barButton, selector: #selector(shareButtonTouched))
        case .title:
            addWithoutImage(barButton, selector: #selector(closeButtonTouched))
        case .none:
            noButton()
        }
    }
    
    func hideBackButton(_ flag: Bool, animated: Bool) {
        navigationItem.setHidesBackButton(flag, animated: animated)
        setPopGestureEnabled(!flag)
    }
    
    internal func add(_ button: RightBarButton, selector: Selector?) {
        if let image = button.image?.withRenderingMode(.alwaysTemplate), let selector = selector {
            let customButton = UIButton()
            customButton.setImage(image, for: .normal)
            customButton.addTarget(self, action: selector, for: .touchUpInside)
            customButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            if let identifier = button.accessibilityIdentifier {
                customButton.accessibilityIdentifier = identifier
            } else {
                customButton.accessibilityIdentifier = "rightBarButton"
            }
            let rightBarButton = UIBarButtonItem(customView: customButton)
            rightBarButton.accessibilityLabel = button.accessibilityLabel
            navigationItem.rightBarButtonItems = [rightBarButton]
        }
    }
    
    private func addMenu(text: String, selector: Selector?) {
        let button = ImageAndTextButton()
        button.set(title: text, image: "icnMenu", target: self, action: selector, tintColor: .santanderRed, template: true)
        button.sizeToFit()
        let rightBarButton = UIBarButtonItem(customView: button)
        rightBarButton.accessibilityIdentifier = AccessibilityOthers.btnMenu.rawValue
        navigationItem.rightBarButtonItems = [rightBarButton]
    }
    
    internal func addWithoutImage(_ button: RightBarButton, selector: Selector?) {
        let button = UIBarButtonItem(title: localized(key: "onboarding_link_notNow").text, style: .plain, target: self, action: selector)
        button.tintColor = .darkTorquoise
        button.setTitleTextAttributes([.font: UIFont.santanderTextRegular(size: 15)], for: .normal)
        button.setTitleTextAttributes([.font: UIFont.santanderTextRegular(size: 15)], for: .highlighted)
        button.accessibilityIdentifier = "SideMenuButton"
        navigationItem.rightBarButtonItems = [button]
    }
    
    func addLeftBarSteps(_ stepNumber: Int) {
        let stepsText = UILabel()
        let textStep: LocalizedStylableText = (stringLoader?.getString("onboarding_label_steps", [StringPlaceholder(.number, "\(stepNumber)"), StringPlaceholder(.number, "4")]))!
        stepsText.font = .santander(family: .text, type: .regular, size: 16.0)
        stepsText.textColor = .lisboaGrayNew
        stepsText.set(localizedStylableText: textStep)
        stepsText.accessibilityIdentifier = "onboarding_step_" + String(stepNumber)
        stepsText.sizeToFit()
        let leftNavigationBarItem = UIBarButtonItem(customView: stepsText)
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 18
        self.navigationItem.setLeftBarButtonItems([spacer, leftNavigationBarItem], animated: false)
    }
    
    func noButton() {
        navigationItem.rightBarButtonItems = nil
    }
    
    @objc
    func showMenu() {
        
    }
    
    @objc func shareButtonTouched() {
        
    }
    
    @objc
    func closeButtonTouched() {
        if let presenter = presenter as? CloseButtonAwarePresenterProtocol {
            presenter.closeButtonTouched()
        }
    }
    
    @objc func actionButtonPressed() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        if let presenter = presenter as? Presenter {
            presenter.loadViewData()
        }
        navigationBarTitleLabel.adjustsFontSizeToFitWidth = true
        let style = LabelStylist(textColor: .santanderRed, font: .santanderHeadlineBold(size: 16), textAlignment: .right)
        navigationBarTitleLabel.applyStyle(style)
        navigationBarTitleLabel.text = title
        navigationBarTitleLabel.accessibilityIdentifier = titleIdentifier
        navigationBarTitleLabel.isAccessibilityElement = titleIdentifier != nil
        navigationBarTitleLabel.sizeToFit()
    }
    
    var navigationBarStyle: NavigationBarBuilder.Style {
        return .white
    }
    
    func prepareView() {}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = customTitle
        if let presenter = presenter as? Presenter {
            presenter.viewShown()
        }
    }
    
    func localized(key: String) -> LocalizedStylableText {
        return stringLoader.getString(key)
    }
    
    func localized(key: String, stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
        return stringLoader.getString(key, stringPlaceHolder)
    }
    
    func localized(key: String, count: Int, stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
        return stringLoader.getQuantityString(key, count, stringPlaceHolder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardDismisser?.start()
        
        hideBackButton(false, animated: false)
        
        if let forcedRotatable = self as? ForcedRotatable {
            forcedRotatable.forceOrientationForPresentation()
        }
        if let presenter = presenter as? Presenter {
            presenter.viewWillAppear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        keyboardDismisser?.stop()
        
        if let forcedRotatable = self as? ForcedRotatable {
            forcedRotatable.forceOrientationForDismission()
        }
        title = blankTitle
        if let presenter = presenter as? Presenter {
            presenter.viewWillDisappear()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let presenter = presenter as? Presenter {
            presenter.viewDisappear()
        }
    }
    
    func findCoachmarks(neededIds: [CoachmarkIdentifier], callback: @escaping ([CoachmarkIdentifier: IntermediateRect]) -> Void) {
        let coachmarkViews = view.findView(prot: CoachmarkUIView.self)
        var output = [CoachmarkIdentifier: IntermediateRect]()
        
        for id in neededIds {
            output[id] = IntermediateRect.zero
        }
        
        if !coachmarkViews.isEmpty {
            for view in coachmarkViews {
                if let coachmarkId = view.coachmarkId, output.keys.contains(coachmarkId), let uiview = view as? UIView {
                    let fieldPosition = uiview.getAbsolutePosition()
                    output[coachmarkId] = IntermediateRect(x: fieldPosition.origin.x, y: fieldPosition.origin.y, width: fieldPosition.width, height: fieldPosition.height)
                }
            }
        }
        
        callback(output)
    }
    
    func endEditing(_ force: Bool) {
        self.view.endEditing(force)
    }
    
    // MARK: - Orientation
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return preferredOrientationForPresentation()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientations()
    }
    
    var progressBarBackgroundColor: UIColor? {
        switch self.navigationBarStyle {
        case .white, .clear: return .white
        case .sky: return .skyGray
        case .custom(background: let background, tintColor: _):
            switch background {
            case .clear: return .white
            case .color(let background): return background
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}

extension BaseViewController: ViewControllerProgressBarCapable {
    
    func shouldShowProgressBar(_ shouldDisplay: Bool) {
        guard let progressBarBackgroundColor = progressBarBackgroundColor else { return } //workaround to avoid child view controllers
        (navigationController as? NavigationController)?.setProgressBarVisible((shouldDisplay, progressBarBackgroundColor))
    }
    
    func setProgressBar(progress: Progress) {
        (navigationController as? NavigationController)?.setProgress(progress)
    }
}

extension BaseViewController: GenericErrorDialogPresentationCapable {}
