import SANLibraryV3
import Alamofire

public class TargetProviderImpl: TargetProvider {

    public let alamofireManager: SessionManager
    public let webServicesUrlProvider: WebServicesUrlProvider
    public let bsanDataProvider: BSANDataProvider
    let soapDemoExecutor: SoapServiceExecutor
    let demoInterpreter: DemoInterpreter

    public init(webServicesUrlProvider: WebServicesUrlProvider, bsanDataProvider: BSANDataProvider) {
        self.alamofireManager = Alamofire.SessionManager(
                configuration: URLSessionConfiguration.default,
                serverTrustPolicyManager: .development
        )

        self.webServicesUrlProvider = webServicesUrlProvider
        self.bsanDataProvider = bsanDataProvider
        let demoInterpreter = DemoInterpreterImpl(bsanDataProvider: bsanDataProvider, defaultDemoUser: "12345678Z")
        self.demoInterpreter = demoInterpreter
        self.soapDemoExecutor = SoapDemoExecutor(demoInterpreter: demoInterpreter)
    }

    func getDemoInterpreter() -> DemoInterpreter {
        return demoInterpreter
    }

    public func getSoapCallExecutorProvider() -> SoapServiceExecutor {
        return AlamoExecutor(alamofireManager)
    }

    public func getRestCallExecutorProvider() -> RestServiceExecutor {
        return RestJSONAlamoExecutor(alamofireManager, webServicesUrlProvider: webServicesUrlProvider, bsanDataProvider: bsanDataProvider)
    }

    public func getSoapDemoExecutorProvider() -> SoapServiceExecutor? {
        return soapDemoExecutor
    }
    
    public func getRestCallJsonExecutorProvider() -> RestServiceExecutor {
        return RestJSONAlamoExecutor(alamofireManager, webServicesUrlProvider: webServicesUrlProvider, bsanDataProvider: bsanDataProvider)
    }

    public func getRestDemoExecutorProvider() -> RestServiceExecutor? {
        return RestDemoExecutor(demoInterpreter: demoInterpreter)
    }
}

