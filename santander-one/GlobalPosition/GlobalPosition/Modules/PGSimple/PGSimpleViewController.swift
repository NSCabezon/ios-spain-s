import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import CoreDomain

protocol PGSimpleViewProtocol: NavigationBarWithSearchProtocol, PGViewProtocol, OldDialogViewPresentationCapable {
    var presenter: PGSimplePresenterProtocol? { get set }
    var hasPresentedViewController: Bool? { get }
    
    init(presenter: PGSimplePresenterProtocol, dependenciesResolver: DependenciesResolver)
    func configView(_ isMoneyVisible: Bool, isConfigureWhatYouSeeVisible: Bool)
    func setUserName(_ name: String, amount: NSAttributedString?, birthDay: Bool, isMoneyVisible: Bool)
    func setSantanderLogo(_ image: String)
    func isWhatsNewBigBubbleVisible(_ isBig: Bool, whatsNewEnabled: Bool, completion: @escaping (() -> Void))
    func showAndHideWhatsNewBubble(isEnabled: Bool)
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType)
    func showBottomSheet(titleKey: String, bodyKey: String)
    func setDiscreteModeHeader(_ enabled: Bool)
    func showNotAvailableOperation()
    func setAvailableActions(_ actions: [GpOperativesViewModel]?, areActionsHidden: Bool)
    func updateSantanderLogoAccessibility(discretMode: Bool)
}

public final class PGSimpleViewController: UIViewController, PGSimpleViewProtocol, SimplePGHeaderViewDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var header: SimplePGHeaderView!
    @IBOutlet private weak var headerHeight: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNew: BubbleWhatsNew!
    @IBOutlet private weak var bubbleWhatsNewTop: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewTrailing: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewWidth: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewHeight: NSLayoutConstraint!
    private var timer: Timer?
    private let yourMoneyViewHeight: CGFloat = 67

    lazy var sanImage: UIImageView = {
        if let navigationBar = self.navigationController?.navigationBar {
            self.sanImage = UIImageView()
            self.sanImage.image = nil
            self.navigationController?.navigationBar.addSubview(self.sanImage)
            self.sanImage.contentMode = .scaleAspectFit
            self.sanImage.translatesAutoresizingMaskIntoConstraints = false
            self.sanImage.widthAnchor.constraint(lessThanOrEqualTo: navigationBar.widthAnchor, multiplier: 0.45).isActive = true
            self.sanImage.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 11).isActive = true
            self.sanImage.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 0).isActive = true
            self.sanImage.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
        }
        return self.sanImage
    }()
    private let dependenciesResolver: DependenciesResolver
    private lazy var pendingSolicitudesView: PendingSolicitudesView = {
        return self.dependenciesResolver.resolve()
    }()
    
    private lazy var recoveryPopup: RecoveryPopup? = {
        let view = dependenciesResolver.resolve(for: RecoveryPopup.self)
        view.presenter?.delegate = self
        view.closeAction = { [weak self] in
            self?.recoveryPopup = nil
        }
        return view
    }()
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    var presenter: PGSimplePresenterProtocol?
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(presenter: PGSimplePresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "PGSimpleViewController", bundle: Bundle(for: PGSimpleViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.sanImage.isHidden = false
        configureTableView()
        presenter?.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedLanguageReceived),
                                               name: Notification.Name("ChangedLanguageApp"),
                                               object: nil)
        setAccessibilityIdentifiers()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewDidAppear()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        sanImage.isHidden = false
        self.pendingSolicitudesView.delegate = self
        pendingSolicitudesView.setNeedsDisplay()
        presenter?.viewWillAppear()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sanImage.isHidden = true
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.viewDidDisappear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name("ChangedLanguageApp"),
                                                  object: nil)
    }
    
    // MARK: - PGSimpleViewProtocolMethods
    
    var hasPresentedViewController: Bool?
    
    func setUserName(_ name: String, amount: NSAttributedString?, birthDay: Bool, isMoneyVisible: Bool) {
        self.header?.setUsername(name, money: amount, birthDay: birthDay, isMoneyVisible: isMoneyVisible)
    }
    
    func setSantanderLogo(_ imageNamed: String) {
        guard let image = Assets.image(named: imageNamed) else { return }
        let aspectRatio = Double(image.size.width / image.size.height)
        let correction = Screen.isScreenSizeBiggerThanIphone5() ? 0.0 : 6.0
        let isUserRetail = imageNamed == "icnSantander"
        let width = isUserRetail ? 151.0 : (40.0 - correction) * aspectRatio
        let height = isUserRetail ? 32.0 : (40.0 - correction)
        sanImage.frame = CGRect(x: 16.0 - correction, y: correction, width: width, height: height)
        sanImage.image = image
        setSantanderLogoAccessibility()
    }
    
    public func showThirdLevelRecoveryPopupIfNeeded(presented: @escaping (Bool) -> Void, completion: @escaping () -> Void) {
        recoveryPopup?.showIn(self, presentedAction: presented, completion: completion)
    }
    
    public func showPendingSolicitudesIfNeeded() {
        self.pendingSolicitudesView.showWhenLoaded(in: self.view)
    }
    
    public func updatePendingSolicitudes() {
        self.pendingSolicitudesView.update()
    }
    
    func configView(_ isMoneyVisible: Bool, isConfigureWhatYouSeeVisible: Bool) {
        configureHeaderView(isMoneyVisible)
        presenter?.setController(initializeController(isMoneyVisible, isConfigureWhatYouSeeVisible: isConfigureWhatYouSeeVisible))
    }
    
    // MARK: - privateMethods
    private func initializeController(_ isMoneyVisible: Bool, isConfigureWhatYouSeeVisible: Bool) -> PGSimpleTableViewController {
        let controller = PGSimpleTableViewController(
            tableView: tableView,
            header: header,
            headerHeight: headerHeight,
            dependenciesResolver: self.dependenciesResolver,
            isMoneyVisible: isMoneyVisible,
            isConfigureWhatYouSeeVisible: isConfigureWhatYouSeeVisible
        )
        controller.maxHeight = headerHeight?.constant ?? 0.0
        return controller
    }
    
    private func configureNavigationBar() {
        if let transitionCoordinator = self.transitionCoordinator,
           transitionCoordinator.initiallyInteractive {
            transitionCoordinator.notifyWhenInteractionChanges { [weak self] context in
                if !context.isCancelled {
                    self?.setupNavigationBar()
                }
            }
        } else {
            self.setupNavigationBar()
        }
    }

    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .white, title: .none)
        builder.setRightActions(
            .menu(action: #selector(drawerDidPressed)),
            .mail(action: #selector(mailDidPressed))
        )
        builder.build(on: self, with: self.presenter)
        setDoubleTapGesture()
    }
    
    private func configureTableView() {
        view.backgroundColor = UIColor.white
        tableView?.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView?.backgroundColor = UIColor.white
        tableView?.separatorStyle = .none
        tableView?.separatorColor = UIColor.clear
        tableView?.rowHeight = UITableView.automaticDimension
    }
    
    private func configureHeaderView(_ isMoneyVisible: Bool) {
        let oneLineHeight = header?.estimatedHeightForUsername() ?? 0.0
        header?.setUsername("", money: NSAttributedString(string: ""), birthDay: false, isMoneyVisible: isMoneyVisible)
        let heightCorrection: CGFloat = isMoneyVisible ? 0 : yourMoneyViewHeight
        headerHeight?.constant = (headerHeight?.constant ?? 0.0) + min((header?.estimatedHeightForUsername() ?? 0.0), 2.0 * oneLineHeight) - heightCorrection
        header?.setDelegate(self)
        header?.setContextSelectorModifier(self.dependenciesResolver.resolve(forOptionalType: ContextSelectorModifierProtocol.self))
    }
    
    private func configureShadowHeaderView() {
        header?.layer.shadowColor = UIColor.botonRedLight.cgColor
        header?.layer.shadowOpacity = 0.7
        header?.layer.shadowOffset = .zero
        header?.layer.shadowRadius = 3
    }
    
    func setDoubleTapGesture() {
        sanImage.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        sanImage.addGestureRecognizer(doubleTap)
    }
    
    private func setBubleWhatsNewAccessibility() {
        self.bubbleWhatsNew.isAccessibilityElement = true
        guard let safeBubbleWhatsNew = self.bubbleWhatsNew,
              let safeTableView = self.tableView else { return }
        self.accessibilityElements = [safeBubbleWhatsNew, safeTableView]
        let frame = self.header.bounds
        let editedFrame = CGRect(x: frame.width - 60, y: 0, width: 60, height: 60)
        let newFrame = UIAccessibility.convertToScreenCoordinates(editedFrame, in: self.header)
        self.bubbleWhatsNew.accessibilityFrame = newFrame
    }
    
    @objc func doubleTapAction() { presenter?.didPressLogo() }
    @objc private func mailDidPressed() { presenter?.mailDidPressed() }
    @objc public func searchButtonPressed() { presenter?.searchDidPressed() }
    @objc private func drawerDidPressed() { presenter?.drawerDidPressed() }
    
    @objc private func changedLanguageReceived() {
        presenter?.reload()
    }
    
    // MARK: - SimplePGHeaderViewDelegate methods
    
    func usernameDidPressed() { presenter?.usernameDidPressed() }
    
    func balanceDidPressed() { presenter?.balanceDidPressed() }
    
    func updateSantanderLogoAccessibility(discretMode: Bool) {
        if discretMode {
            self.sanImage.accessibilityLabel = localized("voiceover_disableDiscreetMode")
        } else {
            self.sanImage.accessibilityLabel = localized("voiceover_enableDiscreetMode")
        }
    }
}

extension PGSimpleViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        guard let currentViewController = presentedViewController as? RootMenuController else {
            return true
        }
        return currentViewController.isSideMenuAvailable
    }
}

extension PGSimpleViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
}

extension PGSimpleViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .globalPosition
    }
}

// MARK: What's New Bubble
extension PGSimpleViewController {
    struct WhatsNewBubbleConstants {
        static let smallBubbleWidth: CGFloat = 90.0
        static let updatedBubbleTrailing: CGFloat = 7.0
        static let updatedBubbleTop: CGFloat = 40.0
    }
    
    // MARK: PGSimpleViewProtocol
    func isWhatsNewBigBubbleVisible(_ isBig: Bool, whatsNewEnabled: Bool, completion: @escaping (() -> Void)) {
        if isBig {
            self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.reduceBubble()
                completion()
            }
        } else {
            self.setSmallBubble()
        }
        self.configWhatsNewBubble()
        self.bubbleWhatsNew.isHidden = !whatsNewEnabled
    }
    
    func showAndHideWhatsNewBubble(isEnabled: Bool) {
        if self.timer?.isValid ?? false {
            self.setSmallBubble()
            self.timer?.invalidate()
        }
        let fiftyPartOfScreenHeight: CGFloat = self.view.frame.size.height / 5
        self.bubbleWhatsNew.isHidden = !isEnabled || (self.headerHeight?.constant ?? 0 <= fiftyPartOfScreenHeight)
    }
    
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType) {
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: messageType, duration: 5.0)
        UIAccessibility.post(notification: .announcement, argument: message.text)
    }
    
    func showBottomSheet(titleKey: String, bodyKey: String) {
        let configuration = BottomSheetBasicConfiguration(titleKey: titleKey, bodyKey: bodyKey)
        BottomSheetBasicView().show(in: self,
                                    type: .custom(isPan: true, bottomVisible: true),
                                    component: .all,
                                    config: configuration)
    }
    
    func setDiscreteModeHeader(_ enabled: Bool) {
        header?.setDiscreteMode(enabled)
    }
    
    func showNotAvailableOperation() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func setAvailableActions(_ actions: [GpOperativesViewModel]?, areActionsHidden: Bool) {
        header.setAvailableActions(actions, areActionsHidden: areActionsHidden)
    }
    
    func setSantanderLogoAccessibility() {
        self.sanImage.isAccessibilityElement = true
        self.sanImage.accessibilityTraits = .button
    }
    
    // MARK: View
    func configWhatsNewBubble() {
        let bubbleImage = Assets.image(named: "icnSpeaker")
        self.bubbleWhatsNew.config(bubbleImage, localized("whatsNew_title_lastVisit"), localized("whatsNew_text_whatsNew"), localized("generic_button_discover"))
        self.bubbleWhatsNew.delegate = self
    }
    
    // MARK: Timer action
    @objc func reduceBubble() {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.setReduceBubbleConstraints()
        })
        self.bubbleWhatsNew.setNeedsLayout()
    }
    
    private func setSmallBubble() {
        self.setReduceBubbleConstraints()
        self.bubbleWhatsNew.setNeedsLayout()
        self.setBubleWhatsNewAccessibility()
    }
    
    private func setReduceBubbleConstraints() {
        self.bubbleWhatsNewWidth.constant = WhatsNewBubbleConstants.smallBubbleWidth
        self.bubbleWhatsNewHeight.constant = WhatsNewBubbleConstants.smallBubbleWidth
        self.bubbleWhatsNewTrailing.constant += WhatsNewBubbleConstants.updatedBubbleTrailing
        self.bubbleWhatsNewTop.constant = WhatsNewBubbleConstants.updatedBubbleTop
        self.view.layoutIfNeeded()
        self.bubbleWhatsNew.updateImagePosition()
    }
    
    private func setAccessibilityIdentifiers() {
        self.bubbleWhatsNew.accessibilityIdentifier = AccessibilityWhatsNewBubble.bubbleView.rawValue
        self.sanImage.accessibilityIdentifier = AccessibilityGlobalPosition.logoSantander
    }
}

extension PGSimpleViewController: BubbleWhatsNewDelegate {
    func didTapInWhatsNew() {
        presenter?.didSelectWhatsNew()
    }
}

extension PGSimpleViewController: WhatsNewBubbleTransitionable {
    public var bubbleTransitionCoordinator: WhatsNewTransitionCoordinator {
        let transitionCoordinator = WhatsNewTransitionCoordinator()
        return transitionCoordinator
    }
    
    public var bubble: BubbleWhatsNew {
        bubbleWhatsNew
    }
}

extension PGSimpleViewController: RecoveryPopupPresenterDelegate {
    public func didSelectOffer(offer: OfferEntity) {
        presenter?.didSelectOffer(offer: offer)
    }
}

extension PGSimpleViewController: PendingSolicitudesViewDelegate {
    func pendingSolicitudesViewIsShown(_ height: CGFloat) {
        self.tableViewBottomConstraint.constant = height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func pendingSolicitudesIsClosed() {
        self.tableViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
}

extension PGSimpleViewController: AccessibilityCapable { }
