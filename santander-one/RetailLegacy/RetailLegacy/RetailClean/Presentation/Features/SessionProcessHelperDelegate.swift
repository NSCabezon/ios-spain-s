import UIKit
import CoreFoundationLib

class ReloadSessionDelegate {
    let stringLoader: StringLoader
    let globalPositionReloadEngine: GlobalPositionReloadEngine
    
    var view: ViewControllerProxy?
    var onSuccess: (() -> Void)?
    var onError: ((String?) -> Void)?
    
    init(stringLoader: StringLoader, globalPositionReloadEngine: GlobalPositionReloadEngine) {
        self.stringLoader = stringLoader
        self.globalPositionReloadEngine = globalPositionReloadEngine
    }
}

extension ReloadSessionDelegate: SessionDataManagerProcessDelegate {
    func handleProcessEvent(_ event: SessionProcessEvent) {
        switch event {
        case .fail(let error):
            handleLoadSessionError(error: error)
        case .loadDataSuccess:
            handleLoadSessionDataSuccess()
        case .updateLoadingMessage:
            updateLoadingMessage()
        case .cancelByUser: break
        }
    }
    
    private func updateLoadingMessage() {
        let loadingText = LoadingText(title: stringLoader.getString("login_popup_loadingData"), subtitle: stringLoader.getString("loading_label_moment"))
        LoadingCreator.setLoadingText(loadingText: loadingText)
    }
    
    private func handleLoadSessionDataSuccess() {
        LoadingCreator.hideGlobalLoading(completion: { [weak self] in
            self?.onSuccess?()
            self?.globalPositionReloadEngine.globalPositionDidReload()
            NotificationCenter.default.post(name: PresenterNotifications.globalPositionDidReloadNotification, object: nil)
        })
    }
    
    private func handleLoadSessionError(error: LoadSessionError) {
        LoadingCreator.hideGlobalLoading(completion: { [weak self] in
            var message: String?
            if case .other(let errorMessage) = error {
                message = errorMessage
            }
            
            self?.onErrorLoadingPG(message)
        })
    }
    
    private func onErrorLoadingPG(_ error: String?) {
        guard let view = view as? UIViewController else {
            return
        }
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: { [weak self] in
            self?.onError?(error)
        })
        
        let errorDescription = stringLoader.getString(error ?? "generic_error_internetConnection")
        Dialog.alert(title: nil, body: errorDescription, withAcceptComponent: accept, withCancelComponent: nil, source: view)
    }
}
