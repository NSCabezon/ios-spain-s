import NotificationCenter
import CoreFoundationLib
import UI

protocol PersonalAreaPGReloadableCapable: GenericErrorDialogPresentationCapable {
    associatedtype View
    associatedtype Navigator
    var dependencies: PresentationComponent { get }
    var stringLoader: StringLoader { get }
    var navigator: Navigator { get }
    var view: View { get }
    var sessionDataManager: SessionDataManager { get }
    var sessionManager: CoreSessionManager { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    func didFinishReloadPersonalArea()
}

extension PersonalAreaPGReloadableCapable where Self: AnyObject, View: ViewControllerProxy, Navigator == PersonalAreaNavigatorProtocol {
    
    func startGlobalLoading(completion: (() -> Void)? = nil) {
        let loadingText = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: loadingText,
                                         controller: view.viewController.navigationController,
                                         completion: completion)
    }
    
    func hideGlobalLoading(completion: (() -> Void)? = nil) {
        LoadingCreator.hideGlobalLoading(completion: completion)
    }
    
    func reloadGlobalPosition() {
        sessionDataManager.load()
    }
    
    func handleProcessEvent(_ event: SessionProcessEvent) {
        switch event {
        case .fail(let error):
            self.handleLoadSessionError(error: error)
            self.didFinishReloadPersonalArea()
        case .loadDataSuccess:
            self.handleLoadSessionDataSuccess()
            self.didFinishReloadPersonalArea()
        case .updateLoadingMessage:
            self.updateLoadingMessage()
        case .cancelByUser:
            self.didFinishReloadPersonalArea()
        }
    }
    
    func didFinishReloadPersonalArea() {
        //implement this method to know when finish realoding the data
    }
    
    private func updateLoadingMessage() {
        let loadingText = LoadingText(title: stringLoader.getString("login_popup_loadingData"), subtitle: stringLoader.getString("loading_label_moment"))
        LoadingCreator.setLoadingText(loadingText: loadingText)
    }
    
    private func handleLoadSessionDataSuccess() {
        sessionManager.sessionStarted { [weak self] in
            LoadingCreator.hideGlobalLoading(completion: { [weak self] in
                self?.navigator.returnToGlobalPosition()
                self?.dependencies.globalPositionReloadEngine.globalPositionDidReload()
                NotificationCenter.default.post(name: PresenterNotifications.globalPositionDidReloadNotification, object: nil)
            })
        }
    }
    
    private func handleLoadSessionError(error: LoadSessionError) {
        LoadingCreator.hideGlobalLoading(completion: {
            var message: String?
            if case .other(let errorMessage) = error {
                message = errorMessage
            }
            
            self.onErrorLoadingPG(message)
        })
    }
    
    private func onErrorLoadingPG(_ error: String?) {
        show(dialog: OperativeContainerDialog(titleKey: nil, descriptionKey: nil, acceptAction: { [weak self] in
            guard let self = self else { return }
            UseCaseWrapper(with: self.dependencies.useCaseProvider.getCheckPersistedUserUseCase(), useCaseHandler: self.dependencies.useCaseHandler, errorHandler: self.genericErrorHandler, onSuccess: { [weak self] in
                self?.navigator.goToPublic(shouldGoToRememberedLogin: true)
                }, onError: { [weak self] _ in
                    self?.navigator.goToPublic(shouldGoToRememberedLogin: false)
            })
        }))
    }
    
    private func show(dialog: OperativeContainerDialog) {
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: dialog.acceptAction)
        guard let error = dialog.descriptionKey else { return self.showGenericErrorDialog(withDependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine) }
        let errorMsg: LocalizedStylableText = LocalizedStylableText(text: error, styles: nil)
        Dialog.alert(title: stringLoader.getString(dialog.titleKey ?? ""), body: errorMsg,
                     withAcceptComponent: accept, withCancelComponent: nil, source: view)
    }
    
    var associatedGenericErrorDialogView: UIViewController {
        return self.view.viewController
    }
}
