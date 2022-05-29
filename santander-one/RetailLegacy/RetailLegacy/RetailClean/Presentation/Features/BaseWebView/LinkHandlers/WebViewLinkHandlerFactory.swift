import CoreFoundationLib
import WebViews

enum WebViewLinkHandlerType {
    case chatInbenta
    case managerWall
    case bizum
    case marketplace
    case pullOffersWebView(action: OpenWebviewAction)
    case santanderApps
    case onlineMessages
    case pdfViewer
    case adobeTarget
}

struct WebViewLinkHandlerFactory {
    let configuration: WebViewConfiguration
    let useCaseHandler: UseCaseHandler
    let useCaseProvider: UseCaseProvider
    let errorHandler: UseCaseErrorHandler
    let stringLoader: StringLoader
    let dependencies: PresentationComponent
    
    init(configuration: WebViewConfiguration, dependencies: PresentationComponent, errorHandler: UseCaseErrorHandler) {
        self.configuration = configuration
        self.useCaseHandler = dependencies.useCaseHandler
        self.useCaseProvider = dependencies.useCaseProvider
        self.errorHandler = errorHandler
        self.stringLoader = dependencies.stringLoader
        self.dependencies = dependencies
    }
}

extension WebViewLinkHandlerFactory {
    func getLinkHandler(of type: WebViewLinkHandlerType) -> WebViewLinkHandler {
        switch type {
        case .chatInbenta:
            return createLinkHandler() as ChatInbentaLinkHandler
        case .managerWall:
            return createLinkHandler() as ManagerWallLinkHandler
        case .bizum:
            let linkHandler: BizumLinkHandler = createLinkHandler()
            linkHandler.registerForOtp()
            return linkHandler
        case .marketplace:
            return createLinkHandler() as ManagerMarketplaceLinkHandler
        case .pullOffersWebView(let action):
            let linkHandler: ManagerPullOfferWebViewLinkHandler = createLinkHandler()
            linkHandler.pullOfferAction = action
            linkHandler.registerForOtp()
            return linkHandler
        case .santanderApps:
            return createLinkHandler() as SantanderAppsLinkHandler
        case .onlineMessages:
            return createLinkHandler() as OnlineMessagesLinkHandler
        case .pdfViewer:
            return createLinkHandler() as PDFWebViewHandler
        case .adobeTarget:
            return createLinkHandler() as AdobeTargetOfferLinkHandler
        }
    }
    
    private func createLinkHandler<T: BaseWebViewLinkHandler>() -> T {
        return T(configuration: configuration,
                 useCaseHandler: useCaseHandler,
                 useCaseProvider: useCaseProvider,
                 useCaseErrorHandler: errorHandler,
                 stringLoader: stringLoader,
                 dependencies: dependencies)
    }
}
