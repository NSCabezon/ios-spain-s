import Alamofire
import SANLibraryV3

protocol TargetProvider {
    
    var alamofireManager: SessionManager {get}
    var webServicesUrlProvider: WebServicesUrlProvider {get}
    
    func getSoapCallExecutorProvider() -> SoapServiceExecutor
    func getRestCallExecutorProvider() -> RestServiceExecutor
    func getRestCallJsonExecutorProvider() -> RestServiceExecutor
    func getDemoInterpreter() -> DemoInterpreter
    func getSoapDemoExecutorProvider() -> SoapServiceExecutor?
    func getRestDemoExecutorProvider() -> RestServiceExecutor?
}
