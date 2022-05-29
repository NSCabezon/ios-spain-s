import UIKit
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

enum ActionPresentationError {
    case badUrl
    case badPhone
    case applicationCanNotOpenUrl
    case domainError
    case notInstalledApp
}

typealias ActionPresentationCompletion = (ActionPresentationError?) -> Void

protocol PullOfferActionsPresenter: ActionDataProvider, CustomSingleSignOn {
    var dependencies: PresentationComponent { get }
    var sessionManager: CoreSessionManager { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var presentationView: ViewControllerProxy { get }
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol { get }
    func showDialog(title: LocalizedStylableText?, body: LocalizedStylableText, acceptComponent: DialogButtonComponents)
}

protocol ActionDataProvider {
    func actionData() -> ProductWebviewParameters?
}

extension ActionDataProvider {
    func actionData() -> ProductWebviewParameters? {
        return nil
    }
}

extension PullOfferActionsPresenter {
    var appStoreNavigator: AppStoreNavigatable {
        return pullOffersActionsNavigator
    }
    
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    func showDialogError(key: String) {
        let stringLoader = dependencies.stringLoader
        let acceptComponents = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        Dialog.alert(title: nil, body: stringLoader.getString(key), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: presentationView)
    }
}

extension PullOfferActionsPresenter {
    var pullOfferActionsManager: PullOfferActionsManager {
        return dependencies.pullOfferActionsManager
    }
    
    func executeOffer(action: OfferActionRepresentable?, offerId: String?, location: PullOfferLocationRepresentable?) {
        if let screenId: String = location?.pageForMetrics, let stringTag = location?.stringTag {
            dependencies.trackerManager.trackEvent(screenId: screenId, eventId: TrackerPagePrivate.Generic.Action.inOffer.rawValue, extraParameters: [TrackerDimensions.location: stringTag, TrackerDimensions.offerId: offerId ?? ""])
        }
        guard let action = action else {
            return
        }
        pullOfferActionsManager.errorHandler = genericErrorHandler
        
        pullOfferActionsManager.getPresentationAction(forPullOfferAction: action, withPrincipalOfferId: offerId, dataProvider: self) { [weak self] presentationAction, error in
            guard let presentationAction = presentationAction else {
                guard let error = error else {
                    return
                }
                self?.handle(error)
                return
            }
            self?.present(action: presentationAction, offerId: offerId)
        }
    }
    
    func removeOffer(location: PullOfferLocation) {
        UseCaseWrapper(
            with: useCaseProvider.getRemovePullOfferLocationUseCase(input: RemovePullOfferLocationUseCaseInput(location: location.stringTag)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler
        )
    }
    
    private func present(action: PullOffersPresentationAction, offerId: String?) {
        switch action {
        case .openApp(let appParameters):
            let error = openSingleSignOn(appParameters: appParameters)
            handle(error == .notInstalledApp ? .notInstalledApp: nil, offerId: offerId)
        case .externalWeb(let url):
            let error = pullOffersActionsNavigator.openInSafari(url: url)
            handle(error, offerId: offerId)
        case .phoneCall(let phone):
            let error = pullOffersActionsNavigator.call(phone: phone)
            handle(error, offerId: offerId)
        case .video(let id):
            pullOffersActionsNavigator.openYoutubeViewer(videoId: id)
            expireOffer(offerId: offerId)
        case .openWebView(let config, let action):
            pullOffersActionsNavigator.goToWebView(with: config,
                                                   linkHandlerType: .pullOffersWebView(action: action),
                                                   dependencies: dependencies,
                                                   errorHandler: genericErrorHandler) { [weak self] _ in
                                                    guard let offerId = offerId else { return }
                                                    self?.expireOffer(offerId: offerId)
            }
            
        case .tutorial(let config):
            pullOffersActionsNavigator.goToTutorial(with: config)
        case .detail(let config):
            pullOffersActionsNavigator.goToPullOfferDetail(with: config)
        case .creativity(let config):
            pullOffersActionsNavigator.goToCreativity(with: config)
        case .imageListFullScreen(let action):
            pullOffersActionsNavigator.goToImageListFullScreen(with: action)
        case .navigateScreen(let type, let identifier):
            var userInfo: [DeepLinkUserInfoKeys: String] = [:]
            userInfo[.identifier] = identifier
            guard let deeplink = DeepLink(type, userInfo: userInfo) else {
                return
            }
            if sessionManager.isSessionActive {
                dependencies.deepLinkManager.registerDeepLink(deeplink)
            } else {
                pullOffersActionsNavigator.closeAllPullOfferActions { [deeplinkManager = dependencies.deepLinkManager] in
                    deeplinkManager.registerDeepLink(deeplink)
                }
            }
        case .fullScreenBanner(let config):
            pullOffersActionsNavigator.goToFullScreenBanner(with: config)
        }
    }
    
    func expireOffer(offerId: String?) {
        let useCase = dependencies.useCaseProvider.getExpirePullOfferUseCase(input: ExpirePullOfferUseCaseInput(offerId: offerId))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, queuePriority: .normal, onSuccess: nil, onError: nil)
    }
    
    func showDialog(title: LocalizedStylableText?, body: LocalizedStylableText, acceptComponent: DialogButtonComponents) {
        Dialog.alert(title: title, body: body, withAcceptComponent: acceptComponent, withCancelComponent: nil, source: presentationView)
    }
    
    private func handle(_ error: PullOfferActionsManagerError) {
        let key: String
        switch error {
        case .notSupported:
            key = "generic_alert_notSupportOperative"
        case .notDefined, .wrongTyped, .unknown:
            return
        case .noOfferAction:
            key = "alert_label_notFindOffer"
        }
        
        let stringLoader = dependencies.stringLoader
        let acceptComponents = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        Dialog.alert(title: nil, body: stringLoader.getString(key), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: presentationView)
    }
}

extension PullOfferActionsPresenter {
    private func handle(_ error: ActionPresentationError?, offerId: String?) {
        let key: String
        guard let error = error else {
            expireOffer(offerId: offerId)
            return
        }
        switch error {
        case .badUrl,
             .applicationCanNotOpenUrl,
             .badPhone:
            return
        case .domainError:
            key = "generic_alert_notSupportOperative"
        case .notInstalledApp:
            expireOffer(offerId: offerId)
            key = "generic_alert_notInstalledApp"
        }
        let stringLoader = dependencies.stringLoader
        let acceptComponents = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        Dialog.alert(title: nil, body: stringLoader.getString(key), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: presentationView)
    }
}
