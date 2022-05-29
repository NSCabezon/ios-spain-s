import WebViews

extension PrivateHomeNavigatorImpl: BaseWebViewNavigatableLauncher {
    func goToWebView(
        configuration: WebViewConfiguration,
        type: BaseWebViewNavigatableType?,
        didCloseClosure: ((Bool) -> Void)?) {
        var linkHandlerType: WebViewLinkHandlerType
        guard let type = type else {
            self.goToWebView(with: configuration, linkHandlerType: nil, dependencies: presenterProvider.dependencies, errorHandler: errorHandler, didCloseClosure: didCloseClosure)
            return
        }
        switch type {
        case .bizum:
            linkHandlerType = .bizum
        case .adobeTarget:
            linkHandlerType = .adobeTarget
        }
        self.goToWebView(with: configuration, linkHandlerType: linkHandlerType, dependencies: presenterProvider.dependencies, errorHandler: errorHandler, didCloseClosure: didCloseClosure)
    }
    
    func goToWebView(configuration: WebViewConfiguration, linkHandler: WebViewLinkHandler, didCloseClosure: ((Bool) -> Void)?) {
        self.goToWebView(with: configuration, linkHandler: linkHandler, dependencies: presenterProvider.dependencies, errorHandler: errorHandler, didCloseClosure: didCloseClosure)
    }
}

extension PrivateHomeNavigatorImpl: BaseWebViewNavigatable {}
