import Foundation
import SwiftyJSON

public class SanRestServicesImpl: SanRestServices {
    
    var LOG_TAG: String {
        return String(describing: type(of: self))
    }
    
    private var callExecutor: RestServiceExecutor
    private var demoExecutor: RestServiceExecutor?
    private var bsanDataProvider: BSANDataProvider?
    
    public init(callExecutor: RestServiceExecutor, demoExecutor: RestServiceExecutor?, bsanDataProvider: BSANDataProvider) {
        self.callExecutor = callExecutor
        self.demoExecutor = demoExecutor
        self.bsanDataProvider = bsanDataProvider
    }
    
    private func isDemo() -> Bool {
        if let bsanDataProvider = bsanDataProvider {
            return bsanDataProvider.isDemo();
        }
        return false
    }
    
    private func getExecutor() -> RestServiceExecutor {
        if let demoExecutor = demoExecutor, isDemo() {
            return demoExecutor
        }
        return callExecutor
    }
    
    public func executeRestCall(request: RestRequest) throws -> Any? {
        do {
            let responseString: Any? = try getExecutor().executeCall(restRequest: request)
            return responseString
        } catch let e as ParserException {
            BSANLogger.e(LOG_TAG, "executeCall \(e.localizedDescription)")
            throw BSANServiceException(e.localizedDescription)
        } catch let e as IOException {
            BSANLogger.e(LOG_TAG, "executeCall \(e.localizedDescription)")
            throw BSANServiceException(e.localizedDescription)
        }
    }
}
