import CoreFoundationLib
import RetailLegacy

final class UniversalLinkManagerMock: UniversalLinkManagerProtocol {
    var isNecessaryToLaunch: Bool = false
    
    func registerUniversalLink(_ url: URL) -> Bool {
        return false
    }
    
    func registerPresenting(_ presenting: UniversalLauncherPresentationHandler) {
        
    }
    
    func launchWithPresentingIfNeeded() {
        
    }
   
}

final class SharedDependenciesDelegateMock: SharedDependenciesDelegate {
    func publicFilesFinished(_ appConfigRepository: AppConfigRepositoryProtocol) {

    }
}
