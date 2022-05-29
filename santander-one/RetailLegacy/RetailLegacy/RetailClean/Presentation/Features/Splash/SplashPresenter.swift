import CoreFoundationLib

enum SplashPresenterState {
    case loading
    case ready
}

class SplashPresenter: BasePresenter<SplashViewController, SplashNavigator, SplashPresenterContract>, SplashPresenterContract {
    weak var appDelegate: RetailLegacyAppDelegate?
    
    override var letPerformIntent: Bool {
        return false
    }
    
    private let localAuthentication: LocalAuthenticationPermissionsManagerProtocol
    private lazy var firstInstallationSuperUseCase: FirstInstallationSuperUseCase = {
       return FirstInstallationSuperUseCase(useCaseProvider: useCaseProvider, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, delegate: self)
    }()
    
    init(localAuthentication: LocalAuthenticationPermissionsManagerProtocol, stringLoader: StringLoader, navigator: SplashNavigator, dependencies: PresentationComponent) {
        self.localAuthentication = localAuthentication
        super.init(navigator: navigator, stringLoader: stringLoader, dependencies: dependencies)
    }
    
    override func initOperations() {
        super.initOperations()
        firstInstallationSuperUseCase.execute()
    }
    
    func finishedSplash() {
        self.checkHasPersistedUser()
    }
    
    private func loadPublicFiles() {
        self.finishedSplash()
        self.appDelegate?.loadPublicFiles()
    }
}

extension SplashPresenter: SuperUseCaseDelegate {
    
    func onSuccess() {
        loadPublicFiles()
    }
    
    func onError(error: String?) {
        loadPublicFiles()
    }
}

extension SplashPresenter: PersistedUserCheckable {
    var useCaseProvider: UseCaseProvider {
        return appDelegate!.dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return appDelegate!.dependencies.mainUseCaseHandler
    }
}

extension SplashPresenter: SiriDonator {}
