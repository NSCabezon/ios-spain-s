import Foundation
import CoreFoundationLib

protocol TrackerScreenProtocol {
    var screenId: String? { get }
    var emmaScreenToken: String? { get }
    func getTrackParameters() -> [String: String]?
}

extension TrackerScreenProtocol {
    func getTrackParameters() -> [String: String]? {
        return nil
    }
}

protocol TrackerEventProtocol: TrackerScreenProtocol {
    func trackEvent(eventId: String, parameters: [String: String])
    func track(event: String, screen: String, parameters: [String: String])
    func trackEmma(token: String)
}

/// Protocol to ignore Progress Bar information (color and visibility)
/// This was created to avoid child view controllers to change parent's info
protocol ProgressBarIgnorable {}

/// Protocol defined to add an action to the view will appear life cycle method
protocol WillAppearActionable {
    var willAppearAction: (() -> Void)? { get set }
}

struct PresenterNotifications {
    static let globalPositionDidReloadNotification = Notification.Name(rawValue: "GlobalPositionDidReloadNotification")
    static let updateChangeAliasDidReloadNotification = Notification.Name("UpdateChangeAliasDidReloadNotification")
}

class PrivatePresenter<View, Navigator, Contract>: PublicPresenter<View, Navigator, Contract>  where View: BaseViewController<Contract> {
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return true
    }
    
    override var genericErrorHandler: GenericPresenterErrorHandler {
        let genericErrorHandler = _genericErrorHandler ?? PrivatePresenterErrorHandler(sessionManager: sessionManager, stringLoader: stringLoader, view: view, delegate: self, dependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine)
        if _genericErrorHandler == nil {
            _genericErrorHandler = genericErrorHandler
        }
        return genericErrorHandler
    }
}

extension PrivatePresenter: MenuTextGetProtocol {
    func get(completion: @escaping ([MenuTextModel: String]) -> Void) {
        let usecase = self.useCaseProvider.getMenuTextUseCase()
        MainThreadUseCaseWrapper(with: usecase, onSuccess: { reponse in
            completion(reponse.texts)
        })
    }
}

class PublicPresenter<View, Navigator, Contract>: BasePresenter<View, Navigator, Contract>, TrackerEventProtocol where View: BaseViewController<Contract> {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var shouldRegisterAsDeeplinkHandler: Bool {
        return true
    }
    
    var shouldOpenDeepLinkAutomatically: Bool {
        return true
    }
    
    var sessionManager: CoreSessionManager
    var screenId: String? {
        return nil
    }
    
    var emmaScreenToken: String? {
        return nil
    }
    
    init(dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: Navigator) {
        self.sessionManager = sessionManager
        super.init(navigator: navigator, stringLoader: dependencies.stringLoader, dependencies: dependencies)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        performTracks()
        dependencies.siriIntentsManager.delegate = self
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
    }
    
    internal func performTracks() {
        if let screenId = screenId {
            let parameters = getTrackParameters() ?? [:]
            dependencies.trackerManager.trackScreen(screenId: screenId, extraParameters: parameters)
        }
        
        if let emmaScreenToken = emmaScreenToken {
            dependencies.trackerManager.trackEmma(token: emmaScreenToken)
        }
    }
    
    final func trackEvent(eventId: String, parameters: [String: String]) {
        if let screenId = screenId {
            dependencies.trackerManager.trackEvent(screenId: screenId, eventId: eventId, extraParameters: parameters)
        }
    }
    
    final func track(event: String, screen: String, parameters: [String: String]) {
        dependencies.trackerManager.trackEvent(screenId: screen, eventId: event, extraParameters: parameters)
    }
    
    final func trackEmma(token: String) {
        dependencies.trackerManager.trackEmma(token: token)
    }
    
    func getTrackParameters() -> [String: String]? {
        return nil
    }
    
    func appOpenedFromDeeplink(deeplinkId: String) {
    }
}

extension PublicPresenter: DeepLinkLauncherPresentationProtocol {
    var launcherAccessType: DeepLinkLauncherAccessType {
        .privateAccess
    }
    
    var viewProxy: ViewControllerProxy {
        return view
    }
}

class BasePresenter<View, Navigator, Contract>: SiriIntentsPresentationDelegate where View: BaseViewController<Contract> {
    
    var letPerformIntent: Bool {
        return true
    }
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    let dependencies: PresentationComponent
    var stringLoader: StringLoader
    var genericErrorHandler: GenericPresenterErrorHandler {
        let genericErrorHandler = _genericErrorHandler ?? GenericPresenterErrorHandler(stringLoader: stringLoader, view: view, delegate: self, dependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine)
        if _genericErrorHandler == nil {
            _genericErrorHandler = genericErrorHandler
        }
        return genericErrorHandler
    }
    var navigator: Navigator
    var willAppearAction: (() -> Void)?
    var view: View {
        if let view = _view {
            return view
        }
        let view: View = View.create(stringLoader: stringLoader)
        if let viewPresenter = self as? Contract {
            view.presenter = viewPresenter
        }
        _view = view
        
        return view
    }
    
    private weak var _view: View?
    fileprivate weak var _genericErrorHandler: GenericPresenterErrorHandler?
    
    var barButtons: [RightBarButton] = [.menu]
    
    init(navigator: Navigator, stringLoader: StringLoader, dependencies: PresentationComponent) {
        self.navigator = navigator
        self.stringLoader = stringLoader
        self.dependencies = dependencies
    }
    
    var reloadGPConditioned: Bool {
        return self as? GlobalPositionConditionedPresenter != nil
    }
    
    var reloadUpdateAliasConditioned: Bool {
        return self as? UpdateAliasConditionedPresenter != nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadViewData() {
        setBarButtons()
        initOperations()
        if reloadGPConditioned {
            NotificationCenter.default.addObserver(self, selector: #selector(globalPositionDidReload), name: PresenterNotifications.globalPositionDidReloadNotification, object: nil)
        }
        if reloadUpdateAliasConditioned {
            NotificationCenter.default.addObserver(self, selector: #selector(updateAliasDidReload), name: PresenterNotifications.updateChangeAliasDidReloadNotification, object: nil)
        }
    }
    
    @objc
    func globalPositionDidReload() {}
    
    @objc
    func updateAliasDidReload() {}
    
    func initOperations() {
    }
    
    func viewShown() {
    }
    
    func viewDisappear() {
    }
    
    func viewWillAppear() {
        willAppearAction?()
        if !(self is ProgressBarIgnorable) {
            view.shouldShowProgressBar(isProgressBarVisible)
        }
    }
    
    func viewWillDisappear() {
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
    
    func showError(keyTitle: String? = nil, keyDesc: String?, phone: String? = nil, completion: (() -> Void)? = nil) {
        var error: LocalizedStylableText = .empty
        var titleError: LocalizedStylableText = .empty
        
        if let keyTitle = keyTitle {
            titleError = stringLoader.getString(keyTitle)
        }
        if let keyDesc = keyDesc {
            if let phone = phone, !phone.isEmpty {
                error = stringLoader.getWsErrorWithNumber(keyDesc, phone)
            } else {
                error = stringLoader.getWsErrorString(keyDesc)
            }
        }
        guard !error.text.isEmpty else { return self.showGenericError() }
        
        let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: completion)
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view)
    }
    
    func showError(keyTitle: String? = nil, keyDesc: String?, placeholders: [StringPlaceholder], completion: (() -> Void)? = nil) {
        var error: LocalizedStylableText = .empty
        var titleError: LocalizedStylableText = .empty
        
        if let keyTitle = keyTitle {
            titleError = stringLoader.getString(keyTitle)
        }
        if let keyDesc = keyDesc {
            if placeholders.isEmpty {
                error = stringLoader.getWsErrorString(keyDesc)
            } else {
                error = stringLoader.getString(keyDesc, placeholders)
            }
        }
        guard !error.text.isEmpty else { return self.showGenericError() }
        
        let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: completion)
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view)
    }
    
    private func showGenericError() {
        self.view.showGenericErrorDialog(withDependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine)
    }
    
    internal func setBarButtons() {
        barButtons.forEach { view.show(barButton: $0) }
    }
    
    private var loadings: [Int: LoadingActionProtocol] = [:]
    
    func getLoading(tag: Int = 0) -> LoadingProtocol? {
        return loadings[tag]
    }
    
    func showLoading(info: LoadingInfo, tag: Int = 0) {
        if let loading = loadings[tag] {
            loading.hideLoading(completion: nil)
        }
        loadings[tag] = LoadingCreator.createAndShowLoading(info: info)
    }
    
    func hideLoading(completion: (() -> Void)? = nil, tag: Int = 0) {
        if let loading = loadings[tag] {
            loading.hideLoading(completion: completion)
            loadings[tag] = nil
        } 
    }
    
    func isLoading(tag: Int = 0) -> Bool {
        return loadings[tag] != nil
    }
    
    func intentDidPerform() {}
    
    var isProgressBarVisible: Bool {
        return (self as? PresenterProgressBarCapable)?.shouldShowProgress ?? false
    }
}

extension BasePresenter: WillAppearActionable {}

extension BasePresenter {
    func showFeatureNotAvailableToast() {
        Toast.show(stringLoader.getString("generic_alert_notAvailableOperation").text)
    }
}

extension BasePresenter: GenericPresenterhideLoadings {
    func hideAllLoadings(completion: (() -> Void)?) {
        if let tag = loadings.keys.first {
            hideLoading(completion: {
                self.hideAllLoadings(completion: completion)
            }, tag: tag)
        } else {
            LoadingCreator.hideGlobalLoading { 
                completion?()
            }
        }
    }
}
