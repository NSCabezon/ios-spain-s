import CoreFoundationLib

protocol OperativeStepPresenterProtocol: AnyObject, CloseButtonAwarePresenterProtocol, OperativeStepProgressProtocol {
    var container: OperativeContainerProtocol? { get set }
    var showsBackButton: Bool { get set }
    var showsCancelButton: Bool { get set }
    var isBackable: Bool { get }
    var number: Int { get set }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var stepView: ViewControllerProxy { get }
    var dependencies: PresentationComponent { get }
    
    func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void)
    func showOperativeLoading(titleToUse: String?, subtitleToUse: String?, source: ViewControllerProxy?, completion: (() -> Void)?)
}

extension OperativeStepPresenterProtocol {
    func closeButtonTouched(completion: (() -> Void)? = nil) {
        container?.cancelTouched(completion: completion)
    }
}

protocol PresenterProgressBarCapable {
    var shouldShowProgress: Bool { get }
}

protocol ViewControllerProgressBarCapable {
    func shouldShowProgressBar(_ shouldDisplay: Bool)
    func setProgressBar(progress: Progress) 
}

protocol OperativeStepProgressProtocol: PresenterProgressBarCapable {
    var number: Int { get }
}

protocol OperativeStepViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol { get }
}

class OperativeStepPresenter<View, Navigator, Contract>: PrivatePresenter<View, Navigator, Contract>, OperativeStepPresenterProtocol where View: BaseViewController<Contract> {
    var isBackable: Bool {
        return true
    }
    
    var showsBackButton: Bool {
        get {
            return view.hidesBackButton
        }
        set {
            view.hideBackButton(!newValue, animated: false)
        }
    }
    var showsCancelButton: Bool {
        get {
            return barButtons.contains { $0 == .close }
        }
        set {
            if newValue {
                barButtons += [.close]
            } else {
                barButtons = [.none]
            }
        }
    }
    var shouldShowProgress: Bool {
        return container?.operative.shouldShowProgress ?? true
    }
    var container: OperativeContainerProtocol?
    
    var number: Int = -1
    
    var stepView: ViewControllerProxy {
        return view
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        container?.currentPresenter = self
        dependencies.navigatorProvider.operativesNavigator.setRightEdgePanGesture(enabled: false)
        handleProgress()
    }
    
    override func viewShown() {
        super.viewShown()
        self.container?.enablePopGestureRecognizer(isBackable)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        dependencies.navigatorProvider.operativesNavigator.setRightEdgePanGesture(enabled: true)
        self.container?.enablePopGestureRecognizer(true)
    }

    func closeButtonTouched() {
        container?.cancelTouched(completion: nil)
    }
    
    func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        onSuccess(true)
    }
    
    func showOperativeLoading(titleToUse: String?, subtitleToUse: String?, source: ViewControllerProxy?, completion: (() -> Void)? = nil) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: subtitleToUse ?? "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func showFatalError(keyTitle: String? = nil, keyDesc: String?, phone: String? = nil, completion: (() -> Void)? = nil) {
        HapticTrigger.operativeError()
        super.showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: phone, completion: completion)
    }
    
    override func showError(keyTitle: String? = nil, keyDesc: String?, phone: String? = nil, completion: (() -> Void)? = nil) {
        HapticTrigger.alert()
        super.showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: phone, completion: completion)
    }
    
    override func showError(keyTitle: String? = nil, keyDesc: String?, placeholders: [StringPlaceholder], completion: (() -> Void)? = nil) {
        HapticTrigger.alert()
        super.showError(keyTitle: keyTitle, keyDesc: keyDesc, placeholders: placeholders, completion: completion)
    }
    
    func showNonHapticError(keyTitle: String? = nil, keyDesc: String?, phone: String? = nil, completion: (() -> Void)? = nil) {
        super.showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: phone, completion: completion)
    }
    
    private func handleProgress() {
        if shouldShowProgress {
            container?.operative.updateProgress(of: self)
        }
    }
}

extension OperativeStepPresenter: ContainerCollector {}
