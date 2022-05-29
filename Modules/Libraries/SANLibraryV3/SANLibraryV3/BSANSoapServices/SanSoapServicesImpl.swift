import Foundation

public class SanSoapServicesImpl: SanSoapServices {

    var LOG_TAG: String {
        return String(describing: type(of: self))
    }

    private var callExecutor: SoapServiceExecutor
    private var demoExecutor: SoapServiceExecutor?
    private var bsanDataProvider: BSANDataProvider?

    public init(callExecutor: SoapServiceExecutor, demoExecutor: SoapServiceExecutor?, bsanDataProvider : BSANDataProvider) {
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

    private func getExecutor() -> SoapServiceExecutor {
        if let demoExecutor = demoExecutor, isDemo() {
            return demoExecutor
        }
        return callExecutor
    }

    public func executeCall<Params, Handler, Response, Parser>(_ request: BSANSoapRequest<Params, Handler, Response, Parser>) throws -> Response {
        do {
            let responseString: String = try getExecutor().executeCall(request: request)
            return try request.parse(response: responseString)
        } catch let e as ParserException {
            BSANLogger.e(LOG_TAG, "executeCall \(e.localizedDescription)")
            throw e
        } catch let e as IOException {
            BSANLogger.e(LOG_TAG, "executeCall \(e.localizedDescription)")
            throw BSANServiceException(e.localizedDescription)
        } catch let e as BSANException{
            BSANLogger.e(LOG_TAG, "executeCall \(e.localizedDescription)")
            throw e
        } catch let e{
            BSANLogger.e(LOG_TAG, "executeCall \(e.localizedDescription)")
            throw e
        }
    }
}
