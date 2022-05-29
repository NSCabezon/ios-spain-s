import CoreFoundationLib
import UI
import CoreDomain

enum PullOffersPresentationAction {
    case externalWeb(url: String)
    case phoneCall(phone: String)
    case video(id: String)
    case openWebView(webViewConfig: PullOffersWebViewConfiguration, webViewAction: OpenWebviewAction)
    case tutorial(tutorialConfig: PullOffersTutorialConfiguration)
    case openApp(appParameters: CustomSingleSignOnToApp)
    case detail(detailConfig: PullOffersDetailConfiguration)
    case creativity(config: PullOffersCreativityConfiguration)
    case imageListFullScreen(config: PullOffersImageListConfiguration)
    case navigateScreen(type: String, identifier: String?)
    case fullScreenBanner(config: PullOfferFullScreenBannerConfiguration)
}

final class PullOfferActionsManager {
    let useCaseHandler: UseCaseHandler
    let useCaseProvider: UseCaseProvider
    let stringLoader: StringLoader
    
    var errorHandler: UseCaseErrorHandler?
    
    required init(useCaseHandler: UseCaseHandler, useCaseProvider: UseCaseProvider, stringLoader: StringLoader) {
        self.useCaseHandler = useCaseHandler
        self.useCaseProvider = useCaseProvider
        self.stringLoader = stringLoader
    }
    
    func getPresentationAction(forPullOfferAction offerAction: OfferActionRepresentable,
                               withPrincipalOfferId offerId: String?,
                               dataProvider: ActionDataProvider,
                               completion: @escaping(PullOffersPresentationAction?, PullOfferActionsManagerError?) -> Void) {
        func convert<T>(action: OfferActionRepresentable, completion: @escaping(PullOffersPresentationAction?, PullOfferActionsManagerError?) -> Void) -> T? {
            guard let conversion = action as? T else {
                completion(nil, .wrongTyped)
                return nil
            }
            return conversion
        }
        guard let conversion = ActionTypeConversion(rawValue: offerAction.type) else {
            return
        }
        switch conversion {
        case .offerLink:
            guard let offerLinkAction: OfferLinkAction = convert(action: offerAction, completion: completion) else {
                return
            }
            getOfferAction(offerId: offerLinkAction.actionValue, completion: { [weak self] action in
                guard let strongSelf = self else { return }
                if let action = action {
                    strongSelf.getPresentationAction(forPullOfferAction: action, withPrincipalOfferId: offerId, dataProvider: dataProvider, completion: completion)
                } else {
                    completion(nil, .noOfferAction)
                }
            })
        case .externalUrl:
            guard let externalUrlAction: ExternalUrlAction = convert(action: offerAction, completion: completion) else {
                return
            }
            completion(.externalWeb(url: externalUrlAction.actionValue), nil)
        case .openApp:
            guard let openAppAction: OpenAppAction = convert(action: offerAction, completion: completion) else {
                return
            }
            completion(.openApp(appParameters: CustomSingleSignOnToApp(scheme: openAppAction.appUrlScheme, appStoreId: openAppAction.storeAppId, ssoEnabled: openAppAction.enableSso, fallbackStore: openAppAction.fallbackStore)), nil)
        case .phoneCall:
            guard let phoneCallAction: PhoneCallAction = convert(action: offerAction, completion: completion) else {
                return
            }
            completion(.phoneCall(phone: phoneCallAction.actionValue), nil)
        case .video:
            guard let videoAction: VideoAction = convert(action: offerAction, completion: completion) else {
                return
            }
            completion(.video(id: videoAction.actionValue), nil)
        case .openWebView:
            guard let webViewAction: OpenWebviewAction = convert(action: offerAction, completion: completion) else {
                return
            }
            getParameters(parameters: webViewAction.parameters, headers: webViewAction.headers, dataProvider: dataProvider) { parameters, headers in
                
                guard let parameters = parameters else {
                    completion(nil, .unknown)
                    return
                }
                let areQueryParameters = webViewAction.method == .get || webViewAction.parametersType == .query
                let queryParameters: [String: String] = areQueryParameters ? parameters : [:]
                let bodyParameters: [String: String] =  !areQueryParameters ? parameters : [:]

                let webViewConfig = PullOffersWebViewConfiguration(
                    initialURL: webViewAction.openUrl,
                    httpMethod: webViewAction.method,
                    queryParameters: queryParameters,
                    bodyParameters: bodyParameters,
                    closingURLs: [webViewAction.closeUrl],
                    webToolbarTitleKey: webViewAction.topTitle,
                    pdfToolbarTitleKey: webViewAction.pdfName,
                    offerId: offerId,
                    engine: webViewAction.webviewEngineVersion.engine,
                    timer: Int(webViewAction.timerLoadingTips),
                    isFullScreenEnabled: webViewAction.isFullScreenEnabled,
                    headers: headers,
                    reloadSessionOnClose: webViewAction.reloadSessionOnClose)
                
                completion(.openWebView(webViewConfig: webViewConfig, webViewAction: webViewAction), nil)
            }
        case .tutorial:
            guard let tutorialAction: TutorialAction = convert(action: offerAction, completion: completion) else {
                return
            }
            let tutorialConfig = PullOffersTutorialConfiguration(offerId: offerId, topTitle: tutorialAction.topTitle, tutorialPages: tutorialAction.tutorialPages)
            completion(.tutorial(tutorialConfig: tutorialConfig), nil)
        case .detail:
            guard let detailAction: DetailAction = convert(action: offerAction, completion: completion) else {
                return
            }
            let detailConfig = PullOffersDetailConfiguration(topTitle: detailAction.topTitle, description: detailAction.description, banner: detailAction.detailBanner, button1: detailAction.button1, button2: detailAction.button2, offerId: offerId)
            completion(.detail(detailConfig: detailConfig), nil)
        case .creativity:
            guard let creativityAction: CreativityAction = convert(action: offerAction, completion: completion) else {
                return
            }
            let configuration = PullOffersCreativityConfiguration(creativityAction: creativityAction, offerId: offerId)
            completion(.creativity(config: configuration), nil)
        case .imageListFullscreen:
            guard let imageListAction: ImageListAction = convert(action: offerAction, completion: completion) else {
                return
            }
            let configuration = PullOffersImageListConfiguration(imageListAction: imageListAction, offerId: offerId)
            completion(.imageListFullScreen(config: configuration), nil)
        case .navigateScreen:
            guard let navigateScreenAction: NavigateScreenAction = convert(action: offerAction, completion: completion) else {
                return
            }
            completion(.navigateScreen(type: navigateScreenAction.actionValue, identifier: navigateScreenAction.id), nil)
        case .empty:
            completion(nil, .wrongTyped)
        case .notDefined:
            completion(nil, .notDefined)
        case .notSupported:
            completion(nil, .notSupported)
        case .fullScreenBanner:
            guard let fullScreenBannerAction: FullScreenBannerAction = convert(action: offerAction, completion: completion) else {
                return
            }
            guard let id = offerId else { return }
            let banner = BannerEntity(fullScreenBannerAction.banner)
            let screenConfig = PullOfferFullScreenBannerConfiguration(banner: banner, time: fullScreenBannerAction.time, action: fullScreenBannerAction.action, offerId: id, transparentClosure: fullScreenBannerAction.transparentClosure)
            completion(.fullScreenBanner(config: screenConfig), nil)
            
        }
    }
}

extension PullOfferActionsManager {
    private func getParameters(parameters: [OfferWebViewParameter],
                               headers: [OpenWebViewHeader]?,
                               dataProvider: ActionDataProvider,
                               completion: @escaping ([String: String]?, [String: String]?) -> Void) {
        let input = ConvertWebviewActionParametersUseCaseInput(parameters: parameters,
                                                               headers: headers,
                                                               product: dataProvider.actionData())
        UseCaseWrapper(with: useCaseProvider.getConvertWebviewActionParametersUseCase(input: input),
                       useCaseHandler: useCaseHandler,
                       errorHandler: errorHandler,
                       onSuccess: { response in
                        completion(response.parametersConversion, response.headersConversion)
        }, onError: { _ in
            completion(nil, nil)
        })
    }
    
    private func getOfferAction(offerId: String,
                                completion: @escaping (_ action: OfferActionRepresentable?) -> Void) {
        let input = GetPullOfferActionUseCaseInput(offerId: offerId)
        UseCaseWrapper(with: useCaseProvider.getPullOfferActionUseCase(input: input),
                       useCaseHandler: useCaseHandler,
                       errorHandler: errorHandler,
                       onSuccess: { response in
                        completion(response.offerAction)
        }, onError: { _ in
            completion(nil)
        })
    }
}

enum PullOfferActionsManagerError: Error {
    case wrongTyped
    case notSupported
    case notDefined
    case noOfferAction
    case unknown
}

enum ActionTypeConversion: String {
    case externalUrl = "external_url"
    case phoneCall = "phone_call"
    case video = "video"
    case openWebView = "open_webview"
    case tutorial = "tutorial"
    case openApp = "open_app"
    case detail = "detail"
    case offerLink = "offer_link"
    case creativity = "creativity"
    case imageListFullscreen = "image_list_fullscreen"
    case navigateScreen = "navigate_screen"
    case notDefined = "no_action_defined"
    case notSupported = "no_action_supported"
    case empty = ""
    case fullScreenBanner = "fullscreen-banner"
}
