//
//  PGClassicViewController.swift
//  GlobalPosition
//
//  Created by alvola on 28/10/2019.
//

import UIKit
import CoreFoundationLib
import UI
import CoreDomain

protocol CarouselClassicItemViewModelType {
    var view: UIView { get }
    var requiredHeight: CGFloat { get }
    var action: ((PGActionType) -> Void)? { get }
}

public protocol PGViewProtocol {
    func showThirdLevelRecoveryPopupIfNeeded(presented: @escaping (Bool) -> Void, completion: @escaping () -> Void)
    func showPendingSolicitudesIfNeeded()
    func updatePendingSolicitudes()
}

protocol PGClassicViewProtocol: NavigationBarWithSearchProtocol, PGViewProtocol, LoadingViewPresentationCapable, OldDialogViewPresentationCapable, ModuleLauncherDelegate {
    var presenter: PGClassicPresenterProtocol? { get set }
    init(presenter: PGClassicPresenterProtocol, dependenciesResolver: DependenciesResolver)
    func setAvailableActions(_ actions: [GpOperativesViewModel]?)
    func setCarouselData(_ data: [CarouselClassicItemViewModelType]?, isHiddenCarousel: Bool, animated: Bool, isBigWhatsNewVisible: Bool)
    func setUserName(_ name: String, birthDay: Bool)
    func setSantanderLogo(_ image: String)
    func setVisibilityBalanceCarousel(_ visible: Bool)
    func shouldAddInsetToSafeArea(_ isVisible: Bool)
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType)
    func isWhatsNewBigBubbleVisible(_ isBig: Bool, whatsNewEnabled: Bool, completion: @escaping (() -> Void))
    func addWhatsNewBubbleToTableScroll()
    func setFavouriteCarousel(_ dataList: [OnePayCollectionInfo])
    func showNotAvailableOperation()
    func updateSantanderLogoAccessibility(discretMode: Bool)
}

public final class PGClassicViewController: UIViewController, PGClassicViewProtocol {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    lazy var header: ClassicPGHeaderView = {
        return ClassicPGHeaderView(frame: CGRect(x: 0, y: 0, width: tableView?.frame.width ?? 0.0, height: 382.0))
    }()
    @IBOutlet private weak var fakeNavView: UIView!
    @IBOutlet private weak var bubbleWhatsNew: BubbleWhatsNew!
    @IBOutlet private weak var bubbleWhatsNewWidth: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewHeight: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewTrailing: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewTop: NSLayoutConstraint!
    
    private var timer: Timer?
    private weak var carousel: ClassicCarouselHeaderView?
    private weak var actionsBar: ClassicPGOptionBar?
    private weak var finantialStatus: FinantialStatusView?
    private weak var pgClassicTableViewController: PGClassicTableViewController?
    private lazy var carouselDatasource =  ClassicCarouselDatasource()
    private var sanImage: UIImageView?
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    
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
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    var presenter: PGClassicPresenterProtocol?
    
    private lazy var otherOperativesAnimator = OtherOperativesAnimator()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    private weak var originalNavigationControllerDelegate: UINavigationControllerDelegate?
    
    required init(presenter: PGClassicPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "PGClassicViewController", bundle: Bundle(for: PGClassicViewController.self))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func loadView() {
        super.loadView()
        commonInit()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        originalNavigationControllerDelegate = navigationController?.delegate
        self.tableView?.delaysContentTouches = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedLanguageReceived),
                                               name: Notification.Name("ChangedLanguageApp"),
                                               object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        refreshHeaderHeight()
        carouselWillAppear()
        hideSanImage(false)
        navigationController?.delegate = originalNavigationControllerDelegate
        self.pendingSolicitudesView.delegate = self
        pendingSolicitudesView.setNeedsDisplay()
        presenter?.viewWillAppear()
        pgClassicTableViewController?.viewWillAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        configureForAnimation(actionBarIsHidden: false)
        presenter?.viewDidDisappear()
        self.removeFloatingBanner()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.carousel?.setPage(0) // workaround to make poagecontrol draw properly
        header.isOnScreen = true
        header.setDelegate(self)
        header.setContextSelectorModifier(self.dependenciesResolver.resolve(forOptionalType: ContextSelectorModifierProtocol.self))
        self.presenter?.viewDidAppear()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if carouselDatasource.maxWidth != view.bounds.width {
            carouselDatasource.maxWidth = view.bounds.width
            carousel?.reloadData()
        } 
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        header.wasAlreadySeen = true
        hideSanImage(true)
        removeToolTipBubbleIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name("ChangedLanguageApp"),
                                                  object: nil)
    }
    
    func setUserName(_ name: String, birthDay: Bool) {
        self.header.setUsername(name, birthDay: birthDay)
        updateHeaderViewHeight()
    }
    
    func setSantanderLogo(_ imageNamed: String) {
        guard let image = Assets.image(named: imageNamed) else { return }
        let aspectRatio = Double(image.size.width / image.size.height)
        var correction = Screen.isScreenSizeBiggerThanIphone5() ? 0.0 : 6.0
        if isiPhone6ScreenWithZoomMode { correction = 5 }
        let isUserRetail = imageNamed == SegmentTypeEntity.retail.segmentImage()
        let size = getLogoSize(isUserRetail, correction: correction, aspectRatio: aspectRatio)
        let origin = getLogoOrigin(isUserRetail, correction: correction)
        sanImage?.frame = CGRect(origin: origin, size: size)
        sanImage?.image = image
        setSantanderLogoAccessibility()
    }
    
    func setVisibilityBalanceCarousel(_ visible: Bool) { carousel?.isHidden = !visible }
    
    func shouldAddInsetToSafeArea(_ isVisible: Bool) {
        if #available(iOS 11.0, *), !isVisible {
            tableView?.insetsContentViewsToSafeArea = true
            tableView?.contentInsetAdjustmentBehavior = .always
        }
    }
    
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType) {
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: messageType, duration: 5.0)
        UIAccessibility.post(notification: .announcement, argument: message.text)
    }
    
    func setAvailableActions(_ actions: [GpOperativesViewModel]?) {
        actionsBar?.isHidden = actions == nil
        actionsBar?.setOptions(actions)
    }
    
    func setCarouselData(_ data: [CarouselClassicItemViewModelType]?, isHiddenCarousel: Bool, animated: Bool, isBigWhatsNewVisible: Bool) {
        defer {
            header.layoutIfNeeded()
            updateHeaderViewHeight()
        }
        carousel?.isHidden = isHiddenCarousel
        guard let data = data else { return }
        carouselDatasource.dataSource = data
        carousel?.reloadData()
        let column = data.first(where: { $0 is ExpensesCarouselItem}) as? ExpensesCarouselItem
        column?.show(animated, isBigWhatsNewBubble: isBigWhatsNewVisible)
    }
    
    func carouselWillAppear() {
        carouselDatasource.dataSource.forEach {
            if let item = $0 as? ExpensesCarouselItem { item.viewWillAppear() }
        }
    }
    
    public func showPendingSolicitudesIfNeeded() {
        self.pendingSolicitudesView.showWhenLoaded(in: self.view)
    }
    
    public func showThirdLevelRecoveryPopupIfNeeded(presented: @escaping (Bool) -> Void, completion: @escaping () -> Void) {
        recoveryPopup?.showIn(self, presentedAction: presented, completion: completion)
    }
    
    public func updatePendingSolicitudes() {
        self.pendingSolicitudesView.update()
    }
    
    @objc public func searchButtonPressed() { presenter?.searchDidPress() }
    
    func setFavouriteCarousel(_ dataList: [OnePayCollectionInfo]) {
        self.pgClassicTableViewController?.setOnePayCollectionInfo(dataList)
    }
    
    func showNotAvailableOperation() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func updateSantanderLogoAccessibility(discretMode: Bool) {
        if discretMode {
            self.sanImage?.accessibilityLabel = localized("voiceover_disableDiscreetMode")
        } else {
            self.sanImage?.accessibilityLabel = localized("voiceover_enableDiscreetMode")
        }
    }

}

extension PGClassicViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        guard let currentViewController = presentedViewController as? RootMenuController else {
            return true
        }
        return currentViewController.isSideMenuAvailable
    }
}

extension PGClassicViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let actionsBar = actionsBar else { return nil }
        otherOperativesAnimator.image = captureOperativesFrame()
        switch operation {
        case .push:
            guard toVC is ClassicShortcutsViewController else { return nil }
            otherOperativesAnimator.isPresenting = true
            otherOperativesAnimator.originFrame = actionsBar.convert(actionsBar.bounds, to: nil)
        default:
            guard fromVC is ClassicShortcutsViewController else { return nil }
            otherOperativesAnimator.isPresenting = false
        }
        return otherOperativesAnimator
    }
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.originalNavigationControllerDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
}

extension PGClassicViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int { 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
}

extension PGClassicViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .globalPosition
    }
}

// - MARK: - Private Methods
private extension PGClassicViewController {
    
    private var isiPhone6ScreenWithZoomMode: Bool { return Screen.isIphone6 && Screen.isZoomModeEnabled() }
    
    func removeFloatingBanner() {
        self.view.subviews
            .first(where: { $0 is FloatingBannerView})?
            .removeFromSuperview()
    }
    
    func getLogoSize(_ isUserRetail: Bool, correction: Double, aspectRatio: Double) -> CGSize {
        if isUserRetail {
            return correction == 0 ? CGSize(width: 151, height: 32) : CGSize(width: 132, height: 28)
        } else {
            return CGSize(width: (40.0 - correction) * aspectRatio, height: (40.0 - correction))
        }
    }
    
    func getLogoOrigin(_ isUserRetail: Bool, correction: Double) -> CGPoint {
        guard isUserRetail && isiPhone6ScreenWithZoomMode else { return CGPoint(x: 16.0 - correction, y: correction) }
        return CGPoint(x: 11.0, y: 5)
    }
    
    func hideSanImage(_ hide: Bool) {
        if #available(iOS 11.0, *) {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { _ in
                    self.sanImage?.alpha = hide ? 0.0 : 1.0
                })
            } else {
                self.sanImage?.alpha = hide ? 0.0 : 1.0
            }
        } else {
            self.sanImage?.isHidden = hide
        }
    }
    
    func setupHeader() {
        header.setContextSelectorModifier(self.dependenciesResolver.resolve(forOptionalType: ContextSelectorModifierProtocol.self))
        header.onResize = { [weak self] in
            self?.updateHeaderViewHeight()
        }
        header.onMoreOptionsPressed = { [weak self] in
            self?.presenter?.moreOptionPress()
            self?.configureForAnimation(actionBarIsHidden: true)
        }
        setupCarousel()
        setupActionBar()
        updateHeaderViewHeight()
        presenter?.setController(initializeController())
        fakeNavView?.layer.shadowOffset = CGSize.zero
        fakeNavView?.layer.shadowColor = UIColor.black.cgColor
        fakeNavView?.layer.shadowOpacity = 0.3
        fakeNavView?.layer.shadowRadius = 0.0
    }
    
    func setupCarousel() {
        let carousel = ClassicCarouselHeaderView()
        self.carousel = carousel
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.setCarouselDelegate(carouselDatasource)
        carouselDatasource.maxWidth = view.bounds.width
        header.addView(carousel)
        carouselDatasource.onChangeIndex = { [weak self] newIndex in
            self?.carousel?.setPage(newIndex)
        }
    }
    
    func setupActionBar() {
        let actionsBar = ClassicPGOptionBar()
        self.actionsBar = actionsBar
        actionsBar.tag = 199
        actionsBar.backgroundColor = UIColor.white
        actionsBar.translatesAutoresizingMaskIntoConstraints = false
        header.addView(actionsBar)
    }
    
    func commonInit() {
        configureTableView()
        setupHeader()
        configureNavigationImage()
        setAccessibilityIdentifiers()
    }
    
    @objc func changedLanguageReceived() {
        presenter?.reload()
    }
    
    func configureNavigationBar() {
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

    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .white, title: .none)
        builder.setRightActions(
            .menu(action: #selector(drawerDidPress)),
            .mail(action: #selector(mailDidPress))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    private func configureNavigationImage() {
        let imageView = UIImageView()
        self.navigationController?.navigationBar.addSubview(imageView)
        self.sanImage = imageView
        self.setDoubleTapGesture()
        self.hideSanImage(true)
    }
    
    func setDoubleTapGesture() {
        sanImage?.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        sanImage?.addGestureRecognizer(doubleTap)
    }
    
    @objc func doubleTapAction() { presenter?.logoDidPress() }
    
    func configureTableView() {
        view.backgroundColor = UIColor.skyGray
        tableView?.backgroundColor = UIColor.clear
        tableView?.separatorStyle = .none
        tableView?.tableHeaderView = header
        tableView?.clipsToBounds = true
    }
    
    func initializeController() -> PGClassicTableViewController {
        let controller = PGClassicTableViewController(
            tableView: tableView,
            shadowTopView: fakeNavView,
            dependenciesResolver: self.dependenciesResolver
        )
        self.pgClassicTableViewController = controller
        return controller
    }
    
    func refreshHeaderHeight() {
        header.seenState()
        updateHeaderViewHeight()
    }
    
    func updateHeaderViewHeight() {
        let height = self.header.estimatedHeightRequired()
        header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: header.frame.width, height: height)
        tableView?.tableHeaderView = header
    }
    
    func removeToolTipBubbleIfNeeded() {
        if let bubbles = view.window?.subviews.compactMap({ $0 as? BubbleMultipleLabelView}) {
            bubbles.forEach({ $0.dismiss() })
        }
        if let bubbles = view.window?.subviews.compactMap({ $0 as? EmptyBubbleView}) {
            bubbles.forEach({ $0.dismiss() })
        }
        self.pgClassicTableViewController?.checkBubbleIsLastPosition()
    }
    
    func captureOperativesFrame() -> UIImage? {
        guard let actionsBar = actionsBar else { return nil }
        actionsBar.backgroundColor = UIColor.clear
        let renderer = UIGraphicsImageRenderer(bounds: actionsBar.bounds)
        return renderer.image { rendererContext in
            actionsBar.layer.render(in: rendererContext.cgContext)
            actionsBar.backgroundColor = UIColor.white
        }
    }
    
    func configureForAnimation(actionBarIsHidden: Bool) {
        actionsBar?.alpha = actionBarIsHidden ? 0.0 : 1.0
    }
    
    func setAccessibilityIdentifiers() {
        self.sanImage?.accessibilityIdentifier = AccessibilityGlobalPosition.logoSantander
        self.bubbleWhatsNew.accessibilityIdentifier = AccessibilityWhatsNewBubble.bubbleView.rawValue
    }
    
    func setSantanderLogoAccessibility() {
        self.sanImage?.isAccessibilityElement = true
        self.sanImage?.accessibilityTraits = .button
    }
    
    func setBubleWhatsNewAccessibility() {
        self.bubbleWhatsNew.isAccessibilityElement = true
        guard let safeBubbleWhatsNew = self.bubbleWhatsNew,
              let safeTableView = self.tableView else { return }
        self.accessibilityElements = [safeBubbleWhatsNew, safeTableView]
        let frame = self.tableView.bounds
        let editedFrame = CGRect(x: frame.width - 60, y: 0, width: 60, height: 60)
        let newFrame = UIAccessibility.convertToScreenCoordinates(editedFrame, in: self.tableView)
        self.bubbleWhatsNew.accessibilityFrame = newFrame
    }
    
    @objc func mailDidPress() { presenter?.mailDidPress() }
    @objc func drawerDidPress() { presenter?.drawerDidPress() }
}

extension PGClassicViewController: ClassicPGHeaderViewDelegate {
    func usernameDidPress() {
        self.presenter?.usernameDidPress()
    }
    
    func isEnabledMoreOptions() -> Bool {
        return self.localAppConfig.isEnabledPlusButtonPG
    }
}

// MARK: - What's New Bubble
extension PGClassicViewController {
    struct WhatsNewBubbleConstants {
        static let smallBubbleWidth: CGFloat = 90.0
        static let updatedBubbleTrailing: CGFloat = 7.0
        static let updatedBubbleTop: CGFloat = 40.0
    }
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
    
    public func configWhatsNewBubble() {
        let bubbleImage = Assets.image(named: "icnSpeaker")
        self.bubbleWhatsNew.config(bubbleImage, localized("whatsNew_title_lastVisit"), localized("whatsNew_text_whatsNew"), localized("generic_button_discover"))
        self.bubbleWhatsNew.delegate = self
        self.addWhatsNewBubbleToTableScroll()
    }
    
    func addWhatsNewBubbleToTableScroll() {
        self.tableView?.addSubview(self.bubbleWhatsNew)
    }
    
    @objc func reduceBubble() {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.setSmallBubble()
        })
    }
    
    private func setSmallBubble() {
        self.bubbleWhatsNewWidth.constant = WhatsNewBubbleConstants.smallBubbleWidth
        self.bubbleWhatsNewHeight.constant = WhatsNewBubbleConstants.smallBubbleWidth
        self.bubbleWhatsNewTrailing.constant = WhatsNewBubbleConstants.updatedBubbleTrailing
        self.bubbleWhatsNewTop.constant = WhatsNewBubbleConstants.updatedBubbleTop
        self.bubbleWhatsNew.setNeedsLayout()
        self.bubbleWhatsNew.layoutIfNeeded()
        self.bubbleWhatsNew.updateImagePosition()
        setBubleWhatsNewAccessibility()
    }
}
// MARK: What's New Bubble Action
extension PGClassicViewController: BubbleWhatsNewDelegate {
    func didTapInWhatsNew() {
        self.presenter?.didSelectWhatsNew()
    }
}

extension PGClassicViewController: WhatsNewBubbleTransitionable {
    public var bubbleTransitionCoordinator: WhatsNewTransitionCoordinator {
        let transitionCoordinator = WhatsNewTransitionCoordinator()
        return transitionCoordinator
    }
    
    public var bubble: BubbleWhatsNew {
        bubbleWhatsNew
    }
}

extension PGClassicViewController: RecoveryPopupPresenterDelegate {
    public func didSelectOffer(offer: OfferEntity) {
        presenter?.didSelectOffer(offer: offer)
    }
}

extension PGClassicViewController: PendingSolicitudesViewDelegate {
    func pendingSolicitudesViewIsShown(_ height: CGFloat) {
        self.tableViewBottomConstraint.constant = -height
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

extension PGClassicViewController: AccessibilityCapable { }
