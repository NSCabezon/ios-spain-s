import CoreFoundationLib

protocol VirtualAssistantLauncher: class {
    
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var virtualAssistantNavigator: BaseWebViewNavigatable { get }
}

extension VirtualAssistantLauncher {
    
    func openVirtualAssistant() {
        dependencies.inbentaManager.errorHandler = errorHandler
        dependencies.inbentaManager.getVirtualAssistantConfigurationWebView(completion: { [weak self] (configuration, _) in
            guard let launcher = self, let configuration = configuration else {
                return
            }
            let errorHandler = launcher.errorHandler
            launcher.virtualAssistantNavigator.goToWebView(with: configuration, linkHandler: nil, dependencies: launcher.dependencies, errorHandler: errorHandler, didCloseClosure: nil)
        })
    }
}
