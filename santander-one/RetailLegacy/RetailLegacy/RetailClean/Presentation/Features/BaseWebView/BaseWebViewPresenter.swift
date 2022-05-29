import Foundation
import CoreFoundationLib
import UI
import WebViews

protocol BaseWebViewNavigatorProtocol: SystemSettingsNavigatable, AppStoreNavigatable, OfferViewNavigatable, BaseWebViewNavigatable {
    func back()
    func goToPdfViewer(with data: Data, andTitle title: LocalizedStylableText?, andPdfSource pdfSource: PdfSource)
    func goToPdfViewer(with data: Data, andTitle title: LocalizedStylableText?, andPdfSource pdfSource: PdfSource, isFullscreen: Bool)
    func goToFiles(with url: URL, title: String)
    func showContacts(completion: (() -> Void)?, selected: (([UserContact]) -> Void)?, setup: ContactsPickerSetup)
    func goToOpenUrl(with url: URL)
}

extension BaseWebViewNavigatorProtocol {
    func goToPdfViewer(with data: Data, andTitle title: LocalizedStylableText?, andPdfSource pdfSource: PdfSource, isFullscreen: Bool) {
        goToPdfViewer(with: data, andTitle: title, andPdfSource: pdfSource)
    }
}

enum WebViewBackAction {
    case automatic
    case nothing
    case custom((() -> Void)?)
}

struct WebViewConfigurationRedirection: WebViewConfiguration {
    init(configuration: WebViewConfiguration, request: URLRequest) {
        self.initialURL = request.url?.absoluteString ?? ""
        self.webToolbarTitleKey = configuration.webToolbarTitleKey
        self.pdfToolbarTitleKey = configuration.pdfToolbarTitleKey
        self.engine = configuration.engine
        self.pdfSource = configuration.pdfSource
        self.request = request
        self.isCachePdfEnabled = configuration.isCachePdfEnabled
    }
    let initialURL: String
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let engine: WebViewConfigurationEngine
    let pdfSource: PdfSource?
    let isCachePdfEnabled: Bool
    let request: URLRequest?
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}

class BaseWebViewPresenter: PrivatePresenter<BaseWebViewViewController, BaseWebViewNavigatorProtocol, BaseWebViewPresenterProtocol>, Presenter {
    private var webView: WebView
    private var webViewDelegate: BaseWebViewDelegate?
    private let isForceCloseLoadingTips: Bool
    private var isShowingLoadingTips: Bool = false
    var title: LocalizedStylableText? {
        guard let titleKey = webViewConfiguration.webToolbarTitleKey else {
            return nil
        }
        return stringLoader.getString(titleKey)
    }
    var backAction: WebViewBackAction = .automatic
    var didCloseClosure: ((Bool) -> Void)?
    
    var closingURLs: [String] {
        return webViewConfiguration.closingURLs
    }
    var globalPositionClosingURLs: [String] {
        return webViewConfiguration.globalPositionClosingURLs
    }
    
    lazy var photoHelper = PhotoHelper(delegate: self)
    
    private var linkHandler: WebViewLinkHandler?
    private var javascriptHandler: WebViewJavascriptHandler?
    private var webViewConfiguration: WebViewConfiguration
    private var imageSelected: ((Data) -> Void)?
    
    private var loadingTipPresenter: LoadingTipPresenter
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.dependenciesEngine)
        manager.setDataManagerProcessDelegate(sessionProcessHelperDelegate)
        return manager
    }()
    private lazy var sessionProcessHelperDelegate: ReloadSessionDelegate = {
        let delegate = ReloadSessionDelegate(stringLoader: dependencies.stringLoader, globalPositionReloadEngine: dependencies.globalPositionReloadEngine)
        let completion: () -> Void = { [weak self] in
            self?.sessionManager.sessionStarted(completion: {
                self?.close(isFromURL: false)
            })
        }
        let completionError: (String?) -> Void = { [weak self] error in
            self?.sessionManager.finishWithReason(.failedGPReload(reason: error))
        }
        delegate.onSuccess = completion
        delegate.onError = completionError
        return delegate
    }()
    
    private var isWebViewFinished = false
    private var isTimerFinished = false
    private var shareableText = ""
    
    override func loadViewData() {
        super.loadViewData()
        view.show(barButton: .close)
        view.styledTitle = title
        view.setWebView(webView)
        webView.webViewDelegate = webViewDelegate
        webView.setup()
        self.setupLoadingTips()
        if let request = webViewConfiguration.request {
            view.loadRequest(in: webView, request: request)
        }
        if !sessionManager.isSessionActive {
            view.setupPublicNavigationBar()
        }
    }
    
    private func close(isFromURL: Bool, completion: (() -> Void)? = nil) {
        didCloseClosure?(isFromURL)
        navigator.closeAllPullOfferActions(completion)
    }
    
    init(webView: WebView,
         webViewDelegate: BaseWebViewDelegate?,
        webViewConfiguration: WebViewConfiguration,
         javascriptHandler: WebViewJavascriptHandler? = nil,
         linkHandler: WebViewLinkHandler?,
         dependencies: PresentationComponent,
         sessionManager: CoreSessionManager,
         navigator: BaseWebViewNavigatorProtocol,
         backAction: WebViewBackAction = .automatic,
         didCloseClosure: ((Bool) -> Void)? = nil, loadingTipPresenter: LoadingTipPresenter) {
        self.webView = webView
        self.webViewDelegate = webViewDelegate
        self.webViewConfiguration = webViewConfiguration
        self.linkHandler = linkHandler
        self.javascriptHandler = javascriptHandler
        self.backAction = backAction
        self.didCloseClosure = didCloseClosure
        self.loadingTipPresenter = loadingTipPresenter
        self.isForceCloseLoadingTips = webViewConfiguration.isForceCloseLoadingTips
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        self.linkHandler?.delegate = self
        self.javascriptHandler?.delegate = self
        
        self.webViewDelegate?.loadingHandler = self
        self.webViewDelegate?.loadingAreaProvider = view
        self.webViewDelegate?.webViewNavigationDelegate = self
        self.webViewDelegate?.linkHandler = linkHandler
        self.webViewDelegate?.javascriptHandler = javascriptHandler
        self.webViewDelegate?.webViewLoader = self
    }
    
    private func getLoadingTipDuration(completion: @escaping (_: String?) -> Void) {
        UseCaseWrapper(with: useCaseProvider.getLoadingTipsTimerUseCase(),
                       useCaseHandler: useCaseHandler,
                       errorHandler: nil,
                       onSuccess: { result in
                        completion(result.timer)
            },
                       onError: { _ in
                        completion(nil)
        })
    }

    private func setupLoadingTips() {
        if let loadingDuration = webViewConfiguration.timer {
            showLoadingTipWith(duration: Double(loadingDuration))
            return
        }
        
        getLoadingTipDuration { duration in
            let loadingTipDuration = Double(duration ?? "0.0")
            self.showLoadingTipWith(duration: loadingTipDuration ?? 0.0 )
        }
    }
    
    private func showLoadingTipWith(duration: Double) {
        self.isShowingLoadingTips = true
        view.showTipLoading()
        Async.after(seconds: duration) {
            self.isTimerFinished = true
            self.checkHidingConditions()
        }
    }
    
    func checkHidingConditions() {
        guard self.isShowingLoadingTips else { return }
        let isClosingLoadingTips = self.isForceCloseLoadingTips || ( self.isWebViewFinished && self.isTimerFinished )
        guard isClosingLoadingTips else { return }
        self.isShowingLoadingTips = false
        self.view.hideTipLoading()
    }
    
    private func loadSessionData() {
        self.sessionDataManager.load()
    }
}

extension BaseWebViewPresenter: BaseWebViewPresenterProtocol {
    var showBackNavigationItem: Bool {
        webViewConfiguration.showBackNavigationItem
    }
    
    var showRightCloseNavigationItem: Bool {
        webViewConfiguration.showRightCloseNavigationItem
    }
    
    func getTipsViewController() -> LoadingTipViewController? {
        return loadingTipPresenter.view as? LoadingTipViewController ?? nil
    }
    
    func getTipsPresenter() -> LoadingTipPresenter {
        return loadingTipPresenter
    }
    
    func navigateWebBack() {
        if webViewDelegate?.willHandleBack() == true {
            webViewDelegate?.handleBack()
        } else {
            view.webViewGoBack(webView: webView)
        }
    }
    
    func closePressed() {
        if let webViewDelegate = webViewDelegate, webViewDelegate.willHandleClose() {
            webViewDelegate.handleClose()
        } else {
            self.handleClose()
        }
    }
    
    func backPressed() {
        performBack()
        didCloseClosure?(false)
    }
    
    private func performBack() {
        switch backAction {
        case .automatic:
            self.handleClose()
        case .nothing:
            break
        case .custom(let backClosure):
            backClosure?()
        }
    }
    
    private func handleClose() {
        if self.webViewConfiguration.reloadSessionOnClose == true {
            exitWebView(reloadGlobalPosition: true)
        } else {
            close(isFromURL: false)
        }
    }
}

extension BaseWebViewPresenter: LoadingHandlerDelegate {
    
    func hideLoading() {
        isWebViewFinished = true
        checkHidingConditions()
    }
}

extension BaseWebViewPresenter: WebViewNavigationDelegate {
    
    func didHitClosingURL(url: String, goToDeepLink: DeepLink?) {
        if self.webViewConfiguration.reloadSessionOnClose == true {
            exitWebView(reloadGlobalPosition: true, goToDeepLink: goToDeepLink)
        } else {
            close(isFromURL: true) { [weak self] in
                guard let goToDeepLink = goToDeepLink else { return }
                self?.dependencies.deepLinkManager.registerDeepLink(goToDeepLink)
            }
        }
    }
}

extension BaseWebViewPresenter: WebViewLoader {
    
    func loadRequest(_ request: URLRequest) {
        view.loadRequest(in: webView, request: request)
    }
}

extension BaseWebViewPresenter: WebViewLinkHandlerDelegate {
    
    func open(deepLink: DeepLink) {
        close(isFromURL: false) { [deeplinkManager = dependencies.deepLinkManager] in
            deeplinkManager.registerDeepLink(deepLink)
        }
    }
    
    func open(request: URLRequest) {
        let configiration: WebViewConfiguration = WebViewConfigurationRedirection(configuration: self.webViewConfiguration, request: request)
        self.navigator.goToWebView(with: configiration, linkHandler: nil, dependencies: self.dependencies, errorHandler: nil, didCloseClosure: nil)
    }
    
    func displayPDF(with data: Data) {
        let title: LocalizedStylableText?
        if let titleKey = webViewConfiguration.pdfToolbarTitleKey {
            title = stringLoader.getString(titleKey)
        } else {
            title = nil
        }
        navigator.goToPdfViewer(with: data, andTitle: title, andPdfSource: webViewConfiguration.pdfSource ?? .unknown, isFullscreen: webViewConfiguration.isFullScreen)
    }
    
    func displayError(title: LocalizedStylableText?, message: LocalizedStylableText?, action: WebViewLinkHandlerDelegateErrorAction?, showCancel: Bool) {
        
        func does(forErrorAction action: WebViewLinkHandlerDelegateErrorAction?) -> (() -> Void)? {
            guard let action = action else {
                return nil
            }
            
            if case .goToSettings = action {
                return { [weak self] in
                    self?.navigator.navigateToSettings()
                }
            }
            return nil
        }
        
        func actionTitle(_ action: WebViewLinkHandlerDelegateErrorAction?) -> LocalizedStylableText {
            guard let action = action else {
                return stringLoader.getString("generic_button_accept")
            }
            switch action {
            case .goToSettings:
                return stringLoader.getString("genericAlert_buttom_settings_android")
            }
        }
        
        let accept = DialogButtonComponents(titled: actionTitle(action), does: does(forErrorAction: action))
        let cancel: DialogButtonComponents?
        if showCancel {
            cancel = DialogButtonComponents(titled: stringLoader.getString("generic_button_cancel"), does: nil)
        } else {
            cancel = nil
        }
        
        if let message = message {
            Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view)
        }
    }
    
    func showContacts(selected: @escaping ([UserContactRepresentable]) -> Void) {
        let setup = ContactsPickerSetup(displayedProperties: [.contactIdentifier, .name, .surname, .imageDataAvailable, .phones, .thumbnailImage])
        navigator.showContacts(completion: nil, selected: selected, setup: setup)
    }
    
    func inject(javascript: String) {
        view.inject(in: webView, javascript: javascript)
    }
    
    func openImageSelection(selected: @escaping (Data) -> Void) {
        imageSelected = selected
        openPhotoSelection(title: localized(key: "customizeAvatar_popup_title_select"),
                           body: localized(key: "customizeAvatar_popup_text_select"),
                           cameraOptionTitle: localized(key: "customizeAvatar_button_camera"),
                           photoLibraryOptionTitle: localized(key: "customizeAvatar_button_photos"))
    }
    
    func openCamera(selected: @escaping (Data) -> Void) {
        imageSelected = selected
        self.photoHelper.askImage(type: .camera)
    }
    
    func openGallery(selected: @escaping (Data) -> Void) {
        imageSelected = selected
        self.photoHelper.askImage(type: .photoLibrary)
    }
    
    func openApp(scheme: String?, identifier: Int) {
        if let scheme = scheme, let url = URL(string: scheme), navigator.canOpen(url) {
            navigator.open(url)
        } else {
            navigator.openAppStore(id: identifier)
        }
    }
    
    func exitWebView(reloadGlobalPosition: Bool, goToDeepLink: DeepLink?) {
        if reloadGlobalPosition {
            let loadingText = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
            LoadingCreator.showGlobalLoading(loadingText: loadingText, controller: view) { [weak self] in
                self?.sessionProcessHelperDelegate.view = self?.view
                self?.sessionProcessHelperDelegate.onSuccess = { [weak self] in
                    self?.close(isFromURL: false) {
                        guard let goToDeepLink = goToDeepLink else { return }
                        self?.dependencies.deepLinkManager.registerDeepLink(goToDeepLink)
                    }
                }
                self?.loadSessionData()
            }
        } else {
            close(isFromURL: false) { [weak self] in
                guard let goToDeepLink = goToDeepLink else { return }
                self?.dependencies.deepLinkManager.registerDeepLink(goToDeepLink)
            }
        }
    }
    
    func exitWebViewWhenBack() -> Bool {
        if webViewDelegate?.willHandleBack() == true {
            close(isFromURL: false)
            return false
        }
        return true
    }
    
    func showLoading() {
        webViewDelegate?.secondTime = false
        webViewDelegate?.displayLoading()
    }
}

extension BaseWebViewPresenter: OldPhotoPickerPresenter {    
    var presentationView: ViewControllerProxy {
        return view
    }
    var photoPickerNavigator: SystemSettingsNavigatable {
        return navigator
    }
    
    func selected(image: Data) {
        imageSelected?(image)
    }
    
    func displayInSafari(with url: URL) {
        navigator.goToOpenUrl(with: url)
    }
}

extension BaseWebViewPresenter: WebViewJavascriptHandlerDelegate {
    func handlePDF(with data: Data) {
        let title: LocalizedStylableText?
        if let titleKey = webViewConfiguration.pdfToolbarTitleKey {
            title = stringLoader.getString(titleKey)
        } else {
            title = nil
        }
        navigator.goToPdfViewer(with: data, andTitle: title, andPdfSource: webViewConfiguration.pdfSource ?? .unknown, isFullscreen: webViewConfiguration.isFullScreen)
    }
    
    func handleFileWithData(_ data: Data, title: String) {
        UseCaseWrapper(
            with: useCaseProvider.getSaveFileUseCase(input: SaveFileUseCaseInput(data: data, fileName: title)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.navigator.goToFiles(with: response.url, title: title)
            },
            onError: { [weak self] error in
                self?.showError(keyTitle: nil, keyDesc: error?.getErrorDesc(), phone: nil, completion: nil)
            }
        )
    }
    func shareText(_ text: String) {
        shareableText = text
        let shareHandler = SharedHandler()
        shareHandler.doShare(for: self, in: view, type: .text)
        shareableText = ""
    }
    func handleContacts() {
        self.handleNewContactsVersion()
    }
}

extension BaseWebViewPresenter: OpenWebviewNewContactsCapable {
    var storeManager: ContactsStoreManager {
        return ContactsStoreManager()
    }
    var delegate: WebViewLinkHandlerDelegate? {
        return self
    }
}

extension BaseWebViewPresenter: Shareable {
    func getShareableInfo() -> String {
        return shareableText
    }
}
