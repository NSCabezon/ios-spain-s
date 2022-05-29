//
//  PGSmartViewController.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 19/12/2019.
//

import UI
import CoreDomain
import CoreFoundationLib

protocol PGSmartViewProtocol: NavigationBarWithSearchProtocol, PGViewProtocol, LoadingViewPresentationCapable, OldDialogViewPresentationCapable, ModuleLauncherDelegate {
    var presenter: PGSmartPresenterProtocol? { get set }
    var hasPresentedViewController: Bool? { get }
    var shouldHaveBigTitle: Bool { get }
    
    init(presenter: PGSmartPresenterProtocol, dependenciesResolver: DependenciesResolver)
    func setUserName()
    func setSantanderLogo(_ image: String)
    func configureBackgroundView(mode: PGColorMode)
    func setSmartProducts(products: [PGCellInfo])
    func reloadCollectionData()
    func reloadCollectionRow(_ row: Int)
    func configureExpensesGraph(withData data: ExpensesGraphViewModel)
    func configureCurrentBalance(data: CurrentBalanceGraphData)
    func enableInterventionFilters(_ enabled: Bool)
    func setCurrentInterventionFilter(_ filter: PGInterventionFilter)
    func scrollToTop()
    func setVisibilityBalanceCarousel(_ visible: Bool)
    func setAvailableActions(_ actions: [GpOperativesViewModel]?)
    func setBookmarks(_ viewModel: PGBookmarkTableViewModel?)
    func hidePlusButton()
    func configureForAnimation(actionBarIsHidden: Bool)
    func setVisibilityOnePayCarousel(visible: Bool)
    func showEditBudgetView(originView: UIView, editBudget: EditBudgetEntity, delegate: BudgetBubbleViewProtocol?)
    func setSantanderExperiences(_ viewModels: [ExperiencesViewModel])
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType)
    func isWhatsNewBigBubbleVisible(_ isBig: Bool, whatsNewEnabled: Bool, completion: @escaping (() -> Void))
    func setFavouriteCarousel(_ dataList: [OnePayCollectionInfo])
    func setEnabledAviosBanner(_ isEnabled: Bool)
    func showNotAvailableOperation()
    func setTopOfferCarousel(offers: [PGCellInfo])
    func reloadCarousel()
    func updateSantanderLogoAccessibility(discretMode: Bool)
}

public final class PGSmartViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var expensesContainerView: ExpensesContainerView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImage: UIImageView!
    @IBOutlet private weak var onePayView: OnePayView!
    @IBOutlet private weak var experiencesView: ExperiencesView!
    @IBOutlet private weak var interventionFilterView: InterventionFilterView!
    @IBOutlet private weak var interventionFilterList: InterventionFilterListView!
    @IBOutlet private weak var aviosBanner: AviosBannerContainer!
    @IBOutlet private weak var gpCustomizationView: ConfigureYourGPView!
    @IBOutlet private weak var regardLabel: UILabel!
    @IBOutlet private weak var contextSelectorImage: UIImageView!
    @IBOutlet private weak var contextSelectorButton: UIButton!
    @IBOutlet private weak var contextSelectorContainerView: UIView!
    @IBOutlet private weak var principalScrollView: UIScrollView!
    @IBOutlet private weak var smartProductView: SmartProductCollectionView!
    @IBOutlet private weak var topOfferCarouselView: TopOfferCarouselView!
    @IBOutlet private weak var optionsBar: SmartGPOptionsBar!
    @IBOutlet private weak var timeLineView: BookmarksView!
    @IBOutlet private weak var topScrollMargin: NSLayoutConstraint!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var bottomScrollConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNew: BubbleWhatsNew!
    @IBOutlet private weak var bubbleWhatsNewWidth: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewHeight: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewTrailing: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWhatsNewTop: NSLayoutConstraint!
    
    private var timer: Timer?
    private var sanImageView: UIImageView?
    private var activeColorMode: PGColorMode?
    private weak var originalNavigationControllerDelegate: UINavigationControllerDelegate?
    private lazy var animator = SmartOperativesSelectorAnimator()
    var presenter: PGSmartPresenterProtocol?
    public override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
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

    private lazy var contextSelectorModifier: ContextSelectorModifierProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: ContextSelectorModifierProtocol.self)
    }()

    private var regards: LocalizedStylableText?
    
    private var bottomSafeArea: CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.bottom
        } else {
            return bottomLayoutGuide.length
        }
    }
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    public weak var optionsBarView: UIView?
    internal var hasPresentedViewController: Bool?
    internal var shouldHaveBigTitle: Bool = true
    
    private var stackView: UIStackView? {
        principalScrollView.subviews.compactMap({ $0 as? UIStackView }).first
    }
    
    private var defaultBottomViewHeightConstraint: CGFloat { 98.0 }
    private var defaultBottomButtonsContainerConstraint: CGFloat { 8.0 }
    
    init(presenter: PGSmartPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "PGSmartViewController", bundle: Bundle(for: PGSmartViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        originalNavigationControllerDelegate = navigationController?.delegate
        presenter?.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedLanguageReceived),
                                               name: Notification.Name("ChangedLanguageApp"),
                                               object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        hideSanImage(false)
        navigationController?.delegate = originalNavigationControllerDelegate
        optionsBar?.setPlusButtonHidden(false, animated: false)
        self.pendingSolicitudesView.delegate = self
        pendingSolicitudesView.setNeedsDisplay()
        presenter?.viewWillAppear()
        self.setAccessibility()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideSanImage(true)
        removeToolTipBubbleIfNeeded()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        changeRegardLabelFont()
        configureForAnimation(actionBarIsHidden: false)
        presenter?.viewDidDisappear()
        principalScrollView.delaysContentTouches = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name("ChangedLanguageApp"),
                                                  object: nil)
    }
    
    func setBookmarks(_ viewModel: PGBookmarkTableViewModel?) {
        if let timeLineView = timeLineView, let viewModel = viewModel, !viewModel.sizeOfferViewModel.isEmpty {
            self.timeLineView?.isHidden = false
            view.setNeedsLayout()
            timeLineView.setCellInfo(viewModel)
        } else {
            self.timeLineView?.isHidden = true
        }
    }
    
    @objc public func searchButtonPressed() {
        self.presenter?.searchPressed()
    }

    @IBAction func didPressContextSelector(_ sender: UIButton) {
        self.contextSelectorModifier?.pressedContextSelector()
    }
}

extension PGSmartViewController: PGSmartViewProtocol {
    func setEnabledAviosBanner(_ isEnabled: Bool) {
        self.aviosBanner.isHidden = !isEnabled
    }
    
    func showNotAvailableOperation() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func setVisibilityBalanceCarousel(_ visible: Bool) {
        self.expensesContainerView?.isHidden = !visible
    }
    
    func setVisibilityOnePayCarousel(visible: Bool) {
        self.onePayView?.isHidden = !visible
    }
    
    func setSantanderExperiences(_ viewModels: [ExperiencesViewModel]) {
        experiencesView?.isHidden = viewModels.count <= 0
        experiencesView?.configureExperiences(with: viewModels)
        experiencesView.selectedExperience = { [weak self] experience in
            self?.presenter?.didSelect(experience: experience)
        }
        guard let view = stackView?.arrangedSubviews.last else { return }
        view.backgroundColor = .blueAnthracita
        bottomViewHeightConstraint.constant = defaultBottomViewHeightConstraint + bottomSafeArea
    }
    
    func setUserName() {
        configureRegardLabel()
    }
    
    func setSantanderLogo(_ imageNamed: String) {
        guard let image = Assets.image(named: imageNamed) else { return }
        let aspectRatio = Double(image.size.width / image.size.height)
        var correction = Screen.isScreenSizeBiggerThanIphone5() ? 0.0 : 6.0
        if isiPhone6ScreenWithZoomMode { correction = 5 }
        let isUserRetail = imageNamed == SegmentTypeEntity.retail.segmentImage() + "White"
        let size = getLogoSize(isUserRetail, correction: correction, aspectRatio: aspectRatio)
        let origin = getLogoOrigin(isUserRetail, correction: correction)
        sanImageView?.frame = CGRect(origin: origin, size: size)
        sanImageView?.image = image
        self.setSantanderLogoAccessibility()
    }
    
    func configureBackgroundView(mode: PGColorMode) {
        backgroundImage?.isHidden = false
        self.activeColorMode = mode
        switch mode {
        case .red:
            backgroundImage?.image = Assets.image(named: "icnRedBackground")
        case .black:
            backgroundImage?.image = Assets.image(named: "bgSmartBlack")
        }
    }
    
    func setSmartProducts(products: [PGCellInfo]) {
        smartProductView.setSmartProducts(products: products)
    }
    
    func reloadCollectionData() {
        smartProductView.reloadData()
    }
    
    func reloadCollectionRow(_ row: Int) {
        smartProductView.reloadCollectionRow(row)
    }
    
    func configureExpensesGraph(withData data: ExpensesGraphViewModel) {
        data.colorTheme = self.activeColorMode ?? .red
        expensesContainerView.updateExpensesGraph(withData: data)
    }
    
    func configureCurrentBalance(data: CurrentBalanceGraphData) {
        expensesContainerView.updateCurrentBalanceGraph(data: data)
    }
    
    func configureForAnimation(actionBarIsHidden: Bool) {
        optionsBar?.isHidden = actionBarIsHidden
    }
    
    func enableInterventionFilters(_ enabled: Bool) {
        interventionFilterView?.isHidden = !enabled
        interventionFilterList?.isHidden = true
    }
    
    func setCurrentInterventionFilter(_ filter: PGInterventionFilter) {
        interventionFilterView?.setInterventionFilter(filter)
        interventionFilterList?.setInterventionFilter(filter)
    }
    
    func scrollToTop() {
        principalScrollView.setContentOffset(CGPoint.zero, animated: true)
        smartProductView.scrollToOrigin()
    }
    
    func setAvailableActions(_ actions: [GpOperativesViewModel]?) {
        optionsBar?.isHidden = actions == nil
        optionsBar?.setOptions(actions)
        optionsBar?.delegate = presenter
        optionsBar?.tag = 199
        optionsBarView = optionsBar
    }
    
    func hidePlusButton() {
        optionsBar?.setPlusButtonHidden(true, animated: true)
    }
    
    func setIsSearchEnabled(_ enabled: Bool) {
        isSearchEnabled = enabled
    }
    
    public func showPendingSolicitudesIfNeeded() {
        self.pendingSolicitudesView.showWhenLoaded(in: self.view)
    }
    
    public func updatePendingSolicitudes() {
        self.pendingSolicitudesView.update()
    }
    
    public func showThirdLevelRecoveryPopupIfNeeded(presented: @escaping (Bool) -> Void, completion: @escaping () -> Void) {
        recoveryPopup?.showIn(self, presentedAction: presented, completion: completion)
    }
    
    func showEditBudgetView(originView: UIView, editBudget: EditBudgetEntity, delegate: BudgetBubbleViewProtocol?) {
        guard !(view.window?.subviews.contains { $0 is EmptyBubbleView } ?? false) else { return }
        
        let budgetView = BudgetBubbleView(frame: CGRect(x: 0, y: 0, width: 256, height: 248))
        budgetView.setBudget(editBudget)
        budgetView.delegate = delegate
        let emptyBubbleView = EmptyBubbleView(associated: originView, addedView: budgetView)
        budgetView.closeAction = emptyBubbleView.getCloseAction()
        
        emptyBubbleView.setBottomViewWithKeyboard(budgetView.saveButton)
        emptyBubbleView.addCloseCourtain(view: view.window)
        view.window?.addSubview(emptyBubbleView)
        UIAccessibility.post(notification: .screenChanged, argument: emptyBubbleView)
        let announcement: String = localized("voiceover_popupWindow")
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType) {
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: messageType, duration: 5.0)
        UIAccessibility.post(notification: .announcement, argument: message.text)
    }
    
    func setFavouriteCarousel(_ dataList: [OnePayCollectionInfo]) {
        self.onePayView?.setFavouriteCarousel(dataList)
    }
    
    func setTopOfferCarousel(offers: [PGCellInfo]) {
        self.topOfferCarouselView.isHidden = (offers.count == 0)
        self.topOfferCarouselView?.setOffers(offers)
        self.topOfferCarouselView?.setDependeciesResolver(self.dependenciesResolver)
    }
    
    func reloadCarousel() {
        self.topOfferCarouselView?.reloadAllTable()
    }
    
    func updateSantanderLogoAccessibility(discretMode: Bool) {
        if discretMode {
            self.sanImageView?.accessibilityLabel = localized("voiceover_disableDiscreetMode")
        } else {
            self.sanImageView?.accessibilityLabel = localized("voiceover_enableDiscreetMode")
        }
    }
   
}

// MARK: - Private Methods
private extension PGSmartViewController {
    
    private var isiPhone6ScreenWithZoomMode: Bool { return Screen.isIphone6 && Screen.isZoomModeEnabled() }
    
    private func removeToolTipBubbleIfNeeded() {
        if let bubbles = view.window?.subviews.compactMap({ $0 as? BubbleMultipleLabelView}) {
            bubbles.forEach({ $0.dismiss() })
        }
        if let bubbles = view.window?.subviews.compactMap({ $0 as? EmptyBubbleView}) {
            bubbles.forEach({ $0.dismiss() })
        }
    }
    
    func getLogoSize(_ isUserRetail: Bool, correction: Double, aspectRatio: Double) -> CGSize {
        if isUserRetail {
            return correction == 0 ? CGSize(width: 151, height: 32) : CGSize(width: 132, height: 28)
        } else {
            return CGSize(width: (40.0 - correction) * aspectRatio, height: (40.0 - correction))
        }
    }
    
    func getLogoOrigin(_ isUserRetail: Bool, correction: Double) -> CGPoint {
        guard isUserRetail && isiPhone6ScreenWithZoomMode else {
            return CGPoint(x: 16.0 - correction, y: correction+1)
        }
        return CGPoint(x: 16.0, y: 5)
    }
    
    func commonInit() {
        configureNavigationImage()
        configureView()
        configureDelegates()
        setAccessiblityIdentifiers()
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
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .white),
            title: .none
        )
        builder.setRightActions(
            .menu(action: #selector(drawerPressed)),
            .mail(action: #selector(mailPressed))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    private func configureNavigationImage() {
        let imageView = UIImageView()
        self.navigationController?.navigationBar.addSubview(imageView)
        self.sanImageView = imageView
        self.setDoubleTapGesture()
        self.hideSanImage(true)
    }
    
    func configureView() {
        topConstraint?.constant = UIApplication.shared.statusBarFrame.height
       sanImageView?.contentMode = .scaleAspectFit
        let topScrollMargin: CGFloat
        if #available(iOS 11.0, *) {
            topScrollMargin = 0
        } else {
            topScrollMargin = self.topbarHeight
        }
        self.topScrollMargin.constant = topScrollMargin
        self.principalScrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -bottomSafeArea, right: 0.0)
        interventionFilterView?.isHidden = true
        interventionFilterList?.isHidden = true
        experiencesView?.isHidden = true
        
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
        stackView?.arrangedSubviews.last?.backgroundColor = .lightGray40
    }
    
    func configureRegardLabel() {
        regardLabel.font = UIFont.santander(family: .headline, size: shouldHaveBigTitle ? 28.0: 20.0)
        regardLabel.textColor = UIColor.white
        setRegardLabel()
    }

    func hideSanImage(_ hide: Bool) {
        if #available(iOS 11.0, *) {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { _ in
                    self.sanImageView?.alpha = hide ? 0.0 : 1.0
                })
            } else {
                self.sanImageView?.alpha = hide ? 0.0 : 1.0
            }
        } else {
            self.sanImageView?.isHidden = hide
        }
    }
    
    func setRegardLabel() {
        guard let birthday = self.presenter?.isBirthday(), let userName = self.presenter?.getUserName() else { return }
        let regardText = birthday ? "pg_title_happyBirthday" : "pg_title_welcome"
        let isContextSelectorEnabled = self.contextSelectorModifier?.isContextSelectorEnabled ?? false
        self.regards = localized(regardText, [StringPlaceholder(StringPlaceholder.Placeholder.name, userName)])
        if isContextSelectorEnabled {
            self.configureContextSelector(withName: userName)
        }
        guard let regards = self.regards else { return }
        self.regardLabel.configureText(withLocalizedString: regards)
        guard !isContextSelectorEnabled else { return }
        if birthday { self.birthDayEnabled() }
    }

    func configureContextSelector(withName name: String) {
        self.contextSelectorImage.image = Assets.image(named: "icnArrowContextSelectorSmart")
        let contextName = self.contextSelectorModifier?.contextName?.camelCasedString ?? ""
        let name = (contextName.isBlank ? name : contextName).withMaxSize(20, truncateTail: !contextName.isBlank)
        self.regards = localized("pg_title_welcome", [StringPlaceholder(StringPlaceholder.Placeholder.name, name)])
        let showContextSelector = self.contextSelectorModifier?.showContextSelector ?? false
        self.contextSelectorContainerView.isHidden = !showContextSelector
    }
    
    func configureDelegates() {
        principalScrollView.delegate = self
        onePayView?.setDelegate(self)
        smartProductView.setDelegate(self)
        timeLineView?.setDelegate(self)
        interventionFilterView?.delegate = self
        interventionFilterList?.delegate = self
        expensesContainerView.delegate = self
        aviosBanner.delegate = self
        gpCustomizationView?.delegate = self
        self.topOfferCarouselView.delegate = self.presenter
    }
    
    func changeRegardLabelFont() {
        if regardLabel.font.pointSize == 28 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.regardLabel.font = UIFont.santander(family: .headline, size: 20.0)
                self.setRegardLabel()
                self.view.layoutIfNeeded()
            })
            shouldHaveBigTitle = false
        }
    }
    
    func birthDayEnabled() {
        guard regardLabel.gestureRecognizers?.isEmpty == nil else { return }
        self.regardLabel.isUserInteractionEnabled = true
        self.regardLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action: #selector(usernamePressed)))
    }

    func setDoubleTapGesture() {
        sanImageView?.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        sanImageView?.addGestureRecognizer(doubleTap)
    }
    
    func setSantanderLogoAccessibility() {
        self.sanImageView?.isAccessibilityElement = true
        self.sanImageView?.accessibilityIdentifier = AccessibilityGlobalPosition.logoSantander
        self.sanImageView?.accessibilityTraits = .button
    }
    
    func setBubbleAccessibility() {
        self.bubbleWhatsNew.isAccessibilityElement = true
        guard let safeBubbleWhatsNew = self.bubbleWhatsNew else { return }
        self.accessibilityElements = [safeBubbleWhatsNew]
        let frame = self.principalScrollView.bounds
        let editedFrame = CGRect(x: frame.width - 60, y: 0, width: 60, height: 60)
        let newFrame = UIAccessibility.convertToScreenCoordinates(editedFrame, in: self.principalScrollView)
        self.bubbleWhatsNew.accessibilityFrame = newFrame
    }

    func setAccessibility() {
        self.contextSelectorButton.accessibilityIdentifier = AccessibilityGlobalPosition.pgBtnContext
    }
    
    @objc func doubleTapAction() { presenter?.logoPressed() }
    @objc func mailPressed() { presenter?.mailPressed() }
    @objc func drawerPressed() { presenter?.drawerPressed() }
    @objc func usernamePressed() { self.presenter?.usernamePressed() }
    @objc func changedLanguageReceived() {
        presenter?.reload()
        gpCustomizationView?.titleLabel?.text = localized("pg_link_setPg")
        interventionFilterView?.titleLabel?.text = localized("pg_label_filter_pb")
        interventionFilterList?.refreshLabels()
        onePayView?.refresh()
        expensesContainerView.collectionView.reloadData()
    }
    
    func setAccessiblityIdentifiers() {
        self.regardLabel.accessibilityIdentifier = "pgSmart_label_wellcome"
        self.bubbleWhatsNew.accessibilityIdentifier = "pgSmart_view_bubleWhatsNew"
        self.timeLineView.accessibilityIdentifier = "pgSmart_view_timeLineView"
        self.experiencesView.accessibilityIdentifier = "pgSmart_view_experienceView"
    }
}

extension PGSmartViewController: OnePayCollectionViewControllerDelegate {
    func newShippmentPressed() {
        presenter?.newShippmentPressed()
    }
    
    func newFavContactPressed() {
        presenter?.newFavContactPressed()
    }
    
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel) {
        presenter?.didTapInFavContact(viewModel)
    }
    
    func didTapInHistoricSendMoney() {
        presenter?.didTapInHistoricSendMoney()
    }
    
    func detectTopOfferCarouselScrolled(_ scrollView: UIScrollView) {
        let topOfferCarouselPosition = self.topOfferCarouselView.frame
        let container = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)
        if topOfferCarouselPosition.intersects(container) {
            self.topOfferCarouselView.readyToAutoscroll = true
        } else if self.topOfferCarouselView.readyToAutoscroll {
            self.topOfferCarouselView.reloadAllTable()
        }
    }
}

extension PGSmartViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.detectTopOfferCarouselScrolled(scrollView)
        if scrollView.contentOffset.y > regardLabel.frame.height { changeRegardLabelFont() }
        shadowView.layer.shadowOpacity = scrollView.contentOffset.y > 0 ? 0.7 : 0
    }
}

extension PGSmartViewController: SmartProductCollectionViewDelegate {
    func didTapOnProduct(product: PGCellInfo) { presenter?.didTapOnProduct(product: product) }
    func activateCard(_ card: Any) { presenter?.activateCard(card) }
    func turnOnCard(_ card: Any) { presenter?.turnOnCard(card) }
    func didClosePullOffer(_ pullOffer: Any) {
        guard let pullOffer = pullOffer as? PullOfferCompleteInfo else { return }
        self.presenter?.didClosePullOffer(pullOffer)
    }
}

extension PGSmartViewController: InterventionFilterViewDelegate {
    func filterHeaderPressed() {
        if let frame = onePayView?.frame, (interventionFilterList?.isHidden ?? false) {
            principalScrollView.scrollRectToVisible(frame, animated: true)
        }
        UIView.animate(withDuration: 0.2) {
            self.interventionFilterList?.isHidden = !(self.interventionFilterList?.isHidden ?? false)
        }
    }
}

extension PGSmartViewController: InterventionFilterListViewDelegate {
    func filterPressed(_ filter: PGInterventionFilter) {
        filterHeaderPressed()
        interventionFilterView?.invertOpen()
        presenter?.interventionFilterDidSelect(filter)
    }
}

extension PGSmartViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        guard let currentViewController = presentedViewController as? RootMenuController else {
            return true
        }
        return currentViewController.isSideMenuAvailable
    }
}

extension PGSmartViewController: AviosBannerContainerDelegate {
    func didTapAvios() {
        presenter?.didSelectAvios()
    }
}

extension PGSmartViewController: ConfigureYourGPViewDelegate {
    func didPressConfigureGP() {
        presenter?.didPressConfigureGP()
    }
}

extension PGSmartViewController: ExpensesGraphViewPortActionsDelegate {
    func didTapOnEditBudget(originView: UIView) {
        self.presenter?.didTapOnEditBudget(originView: originView)
    }
    
    func didTapOnAnalysis() {
        self.presenter?.didTapOnAnalysis()
    }
}

extension PGSmartViewController: UINavigationControllerDelegate {
    private func captureOperativesFrame() -> UIImage? {
        guard let optionsBar = optionsBar else { return nil }
        let renderer = UIGraphicsImageRenderer(bounds: optionsBar.bounds)
        return renderer.image { rendererContext in
            optionsBar.layer.render(in: rendererContext.cgContext)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let optionsBar = optionsBar else { return nil }
        animator.image = captureOperativesFrame()
        switch operation {
        case .push:
            guard toVC is SmartShortcutsViewController else { return nil }
            animator.isPresenting = true
            animator.originFrame = optionsBar.convert(optionsBar.bounds, to: nil)
            return animator
        default:
            guard fromVC is SmartShortcutsViewController else { return nil }
            animator.isPresenting = false
            return animator
        }
    }
}

extension PGSmartViewController: PGBookmarkTableViewCellDelegate {
    func didSelectTimeLineOffer() {
        self.presenter?.didSelectTimeLineOffer()
    }
    
    func didSelectedSizeOffer(_ offer: OfferEntity) {
        self.presenter?.didSelectedSizeOffer(offer)
    }
    
    func circularSliderDidStart() {
        principalScrollView.isScrollEnabled = false
    }
    
    func circularSliderDidStop() {
        principalScrollView.isScrollEnabled = true
    }
    
    func didSelectTimeLine() {
        self.presenter?.didSelectTimeLine()
    }
    
    func didEndedScroll() {
        self.presenter?.didEndedPGBookmarkScroll()
    }
}

extension PGSmartViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
}

extension PGSmartViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .globalPosition
    }
}

// MARK: - What's New Bubble
extension PGSmartViewController {
    // MARK: Constants
    struct WhatsNewBubbleConstants {
        static let smallBubbleWidth: CGFloat = 80.0
        static let updatedBubbleTrailing: CGFloat = 5.0
        static let updatedBubbleTop: CGFloat = 35.0
    }
    
    // MARK: PGSmartViewProtocol
    func isWhatsNewBigBubbleVisible(_ isBig: Bool, whatsNewEnabled: Bool, completion: @escaping (() -> Void)) {
        self.configWhatsNewBubble()
        if isBig {
            self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.reduceBubble()
                completion()
            }
        } else {
            self.setSmallBubble()
        }
        self.bubbleWhatsNew.isHidden = !whatsNewEnabled
    }
    
    // MARK: PGSmart VC
    func configWhatsNewBubble() {
        let bubbleImage = Assets.image(named: "icnSpeaker")
        self.bubbleWhatsNew.config(bubbleImage, localized("whatsNew_title_lastVisit"), localized("whatsNew_text_whatsNew"), localized("generic_button_discover"))
        self.bubbleWhatsNew.delegate = self
    }
    
    @objc func reduceBubble() {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.setSmallBubble()
        })
    }
    
    private func setSmallBubble() {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.bubbleWhatsNewWidth.constant = WhatsNewBubbleConstants.smallBubbleWidth
        self.bubbleWhatsNewHeight.constant = WhatsNewBubbleConstants.smallBubbleWidth
        self.bubbleWhatsNewTrailing.constant = WhatsNewBubbleConstants.updatedBubbleTrailing
        self.bubbleWhatsNewTop.constant = WhatsNewBubbleConstants.updatedBubbleTop
        self.bubbleWhatsNew.setNeedsLayout()
        self.bubbleWhatsNew.layoutIfNeeded()
        self.bubbleWhatsNew.updateImagePosition()
        self.setBubbleAccessibility()
    }
}

// MARK: What's New Action
extension PGSmartViewController: BubbleWhatsNewDelegate {
    func didTapInWhatsNew() {
        self.presenter?.didSelectWhatsNew()
    }
}

// MARK: What's New Transitionable Coordinator
extension PGSmartViewController: WhatsNewBubbleTransitionable {
    public var bubbleTransitionCoordinator: WhatsNewTransitionCoordinator {
        let transitionCoordinator = WhatsNewTransitionCoordinator()
        return transitionCoordinator
    }
    
    public var bubble: BubbleWhatsNew {
        bubbleWhatsNew
    }
}

extension PGSmartViewController: RecoveryPopupPresenterDelegate {
    public func didSelectOffer(offer: OfferEntity) {
        presenter?.didSelectedSizeOffer(offer)
    }
}

extension PGSmartViewController: PendingSolicitudesViewDelegate {
    func pendingSolicitudesViewIsShown(_ height: CGFloat) {
        self.bottomScrollConstraint.constant = -height + 6
        self.buttonsContainerBottomConstraint.constant = -height + self.defaultBottomButtonsContainerConstraint
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func pendingSolicitudesIsClosed() {
        self.bottomScrollConstraint.constant = 0
        self.buttonsContainerBottomConstraint.constant = self.defaultBottomButtonsContainerConstraint
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
}
