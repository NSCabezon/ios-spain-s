import CoreFoundationLib

protocol SantanderAppsLauncher: class {
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var dependencies: PresentationComponent { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var santanderAppsNavigator: BaseWebViewNavigatable { get }
    
    func openSantanderApps()
}

extension SantanderAppsLauncher {
    func openSantanderApps() {
        UseCaseWrapper(with: useCaseProvider.getSantanderAppsUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            guard let thisLauncher = self else {
                return
            }
            thisLauncher.santanderAppsNavigator.goToWebView(with: result.configuration, linkHandlerType: .santanderApps, dependencies: thisLauncher.dependencies, errorHandler: thisLauncher.genericErrorHandler, didCloseClosure: nil)
        })
    }
}
