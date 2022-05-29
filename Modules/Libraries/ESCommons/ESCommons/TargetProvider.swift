import SANLibraryV3
import Alamofire
import CoreFoundationLib

public protocol TargetProviderProtocol {
    
    var alamofireManager: SessionManager {get}
    var webServicesUrlProvider: WebServicesUrlProvider {get}

    func getSoapCallExecutorProvider() -> SoapServiceExecutor
    func getRestCallExecutorProvider() -> RestServiceExecutor
    func getRestCallJsonExecutorProvider() -> RestServiceExecutor
    func getSoapDemoExecutorProvider() -> SoapServiceExecutor?
    func getRestDemoExecutorProvider() -> RestServiceExecutor?
    func getDemoInterpreter() -> DemoInterpreterProtocol
}
