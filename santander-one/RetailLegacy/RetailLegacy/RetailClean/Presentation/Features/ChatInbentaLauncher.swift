import CoreFoundationLib

protocol ChatInbentaLauncher: class {
    
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var chatInbentaNavigator: BaseWebViewNavigatable { get }
}

extension ChatInbentaLauncher {
    
    func openChatInbenta() {
        dependencies.inbentaManager.errorHandler = errorHandler
        dependencies.inbentaManager.getChatInbentaWebViewConfiguration(completion: { [weak self] (configuration, _) in
            guard let launcher = self, let configuration = configuration else {
                return
            }
            let errorHandler = launcher.errorHandler
            launcher.chatInbentaNavigator.goToWebView(with: configuration, linkHandler: nil, dependencies: launcher.dependencies, errorHandler: errorHandler, didCloseClosure: nil)
        })
    }
}
