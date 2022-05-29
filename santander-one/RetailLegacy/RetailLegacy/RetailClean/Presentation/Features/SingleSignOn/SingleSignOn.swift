import CoreFoundationLib
import Foundation

protocol SsoProtocol: class {
    var appStoreNavigator: AppStoreNavigatable { get }
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
}

protocol SingleSignOn: SsoProtocol {
    func openSingleSignOn(type: SingleSignOnToApp, parameters: String?)
    func openAppStore()
}

extension SingleSignOn {
    func openSingleSignOn(type: SingleSignOnToApp, parameters: String?) {
        let singleSignOnUseCase = useCaseProvider.getSingleSignOnUseCase()
        UseCaseWrapper(with: singleSignOnUseCase, useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { [weak self] in
            self?.open(type: type, parameters: parameters)
        })
    }
    
    func openAppStore(){
        let singleSignOnUseCase = useCaseProvider.getSingleSignOnUseCase()
        Scenario(useCase: singleSignOnUseCase).execute(on: useCaseHandler).then { [weak self] Void -> Scenario<Void, AppStoreInformationUseCaseOkOutput, StringErrorOutput>? in
            guard let appStoreInformationUseCase = self?.useCaseProvider.getAppStoreInformationUseCase() else { return nil }
            return Scenario(useCase: appStoreInformationUseCase)
        }.onSuccess { [weak self] result in
            self?.appStoreNavigator.openAppStore(id: result.storeId)
        }
    }
    
    private func open(type: SingleSignOnToApp, parameters: String?) {
        if let sourceUrl = type.getUrl(params: parameters), let url = URL(string: sourceUrl), appStoreNavigator.canOpen(url) {
            appStoreNavigator.open(url)
        } else {
            guard let appStoreInformationUseCase = useCaseProvider.getAppStoreInformationUseCase() else { return }
            Scenario(useCase: appStoreInformationUseCase).execute(on: useCaseHandler).onSuccess { [weak self] result in
                self?.appStoreNavigator.openAppStore(id: result.storeId)
            }
        }
    }
}

enum CustomSingleSignOnError {
    case notInstalledApp
}

protocol CustomSingleSignOn: SsoProtocol {
    func openSingleSignOn(appParameters: CustomSingleSignOnToApp) -> CustomSingleSignOnError?
    func showDialogError(key: String)
}

extension CustomSingleSignOn {
    @discardableResult
    func openSingleSignOn(appParameters: CustomSingleSignOnToApp) -> CustomSingleSignOnError? {
        if let url = URL(string: appParameters.scheme), appStoreNavigator.canOpen(url) {
            open(ssoEnabled: appParameters.ssoEnabled, url: url)
        } else if appParameters.fallbackStore {
            appStoreNavigator.openAppStore(id: appParameters.appStoreId)
        } else {
            return .notInstalledApp
        }
        return nil
    }
    
    private func open(ssoEnabled: Bool, url: URL) {
        if ssoEnabled {
            let usecase = useCaseProvider.getSingleSignOnUseCase()
            UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.appStoreNavigator.open(url)
            })
        } else {
            appStoreNavigator.open(url)
        }
    }
}

struct CustomSingleSignOnToApp {
    let scheme: String
    let appStoreId: Int
    let ssoEnabled: Bool
    let fallbackStore: Bool
}
