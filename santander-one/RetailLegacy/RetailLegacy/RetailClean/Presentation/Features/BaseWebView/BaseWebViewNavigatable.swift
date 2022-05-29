import UI
import UIKit
import CoreFoundationLib
import WebViews
import WebKit

protocol BaseWebViewNavigatable {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
}

extension BaseWebViewNavigatable {
    func goToWebView(with configuration: WebViewConfiguration,
                     linkHandlerType: WebViewLinkHandlerType?,
                     dependencies: PresentationComponent,
                     errorHandler: GenericPresenterErrorHandler?,
                     backAction: WebViewBackAction = .automatic,
                     didCloseClosure: ((Bool) -> Void)?) {
        
        let webViewLinkHandler = self.getWebViewLinkHandler(
            configuration: configuration,
            dependencies: dependencies,
            linkHandlerType: linkHandlerType,
            errorHandler: errorHandler)
        
        self.goToWebView(with: configuration, linkHandler: webViewLinkHandler, dependencies: dependencies, errorHandler: errorHandler, backAction: backAction, didCloseClosure: didCloseClosure)
    }
    
    func goToWebView(with configuration: WebViewConfiguration,
                     linkHandler: WebViewLinkHandler?,
                     dependencies: PresentationComponent,
                     errorHandler: GenericPresenterErrorHandler?,
                     backAction: WebViewBackAction = .automatic,
                     didCloseClosure: ((Bool) -> Void)?) {

        guard let delegate = WKWebViewDelegate(dependenciesResolver: presenterProvider.dependenciesEngine) else { return }
        var webView: UIViewController = presenterProvider.webViewPresenter(
            for: WKWebView(frame: .zero),
            webViewDelegate: delegate,
            config: configuration,
            javascriptHandler: WebViewJavascriptHandler(),
            linkHanlder: linkHandler,
            backAction: backAction,
            didCloseClosure: didCloseClosure)
            .view
        if case .custom(let engine) = configuration.engine,
           let provider = presenterProvider.dependenciesEngine.resolve(forOptionalType: WebViewProviderProtocol.self),
           let providedConfig = provider.provideWebViewForEngineWithKey(engine) {
            webView = presenterProvider.webViewPresenter(
                for: providedConfig.webView,
                webViewDelegate: providedConfig.delegate,
                config: configuration,
                javascriptHandler: WebViewJavascriptHandler(),
                linkHanlder: linkHandler,
                backAction: backAction,
                didCloseClosure: didCloseClosure).view
        }
        
        if configuration.isFullScreen {
            webView.modalPresentationStyle = .fullScreen
            navigationController?.present(webView, animated: true, completion: nil)
        } else {
            navigationController?.blockingPushViewController(webView, animated: true)
        }
    }

    var navigationController: UINavigationController? {
        let currentRootViewController = drawer.currentRootViewController as? UINavigationController
        return currentRootViewController?.topViewController?.presentedViewController as? UINavigationController ?? currentRootViewController
    }
}

private extension BaseWebViewNavigatable {
    func getWebViewLinkHandler(configuration: WebViewConfiguration,
                               dependencies: PresentationComponent,
                               linkHandlerType type: WebViewLinkHandlerType?,
                               errorHandler: GenericPresenterErrorHandler?) -> WebViewLinkHandler?{
        guard let type = type else { return nil }
        guard let errorHandler = errorHandler else { return nil }
        return WebViewLinkHandlerFactory(
            configuration: configuration,
            dependencies: dependencies,
            errorHandler: errorHandler
        ).getLinkHandler(of: type)
    }
}
