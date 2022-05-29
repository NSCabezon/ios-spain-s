import Foundation
import Alamofire
import Alamofire_Synchronous

public class AlamoExecutor: SoapServiceExecutor {

    var logTag: String {
        return String(describing: type(of: self))
    }

    public let httpOk = 200
    public let httpUnathorized = 401

    private let xmlMediatype: String = "text/xml charset=utf-8"
    private var alamofireManager: Alamofire.SessionManager

    public init(_ alamofireManager: Alamofire.SessionManager) {
        self.alamofireManager = alamofireManager
        self.alamofireManager.delegate.dataTaskWillCacheResponse = self.dataTaskWillCacheResponse
        self.alamofireManager.delegate.dataTaskWillCacheResponseWithCompletion = self.dataTaskWillCacheResponseWithCompletion
    }
    
    private func  dataTaskWillCacheResponseWithCompletion(_ session: URLSession, dataTask: URLSessionDataTask, response: CachedURLResponse, completion: @escaping (CachedURLResponse?) -> Void) {
        completion(nil)
    }
    
    private func  dataTaskWillCacheResponse(_ session: URLSession, dataTask: URLSessionDataTask, response: CachedURLResponse) -> CachedURLResponse? {
        return nil
    }

    public func executeCall<Response, Params, Handler, Parser, Request>(request: Request) throws -> String where Request: BSANSoapRequest<Params, Handler, Response, Parser> {
        BSANLogger.i(logTag, "executeCall")
        
        let body: String = request.body
        guard let url = URL(string: request.serviceUrl) else {
            throw BSANServiceException("")
        }
        var request = URLRequest(url: url)
        request.addValue(xmlMediatype, forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: true)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        print("Request: " + body)
        
         BSANLogger.i(logTag, "url " + url.absoluteString)
                
        let response = alamofireManager.request(request).responseString()
        
        let responseString: String
        if response.result.isSuccess, let value = response.result.value {
                responseString = value
            print("\n\n\n\(value)\n\n")
        } else {
            responseString = ""
        }
        
        let status = getStatusCode(response)
        
        switch status {
        case httpOk:
            // Respuesta WS OK
            BSANLogger.i(logTag, "makeCall OK")
            return responseString
            
        case httpUnathorized:
            // Respuesta WS Error autenticacion
            BSANLogger.e(logTag, "makeCall Authentication error")
            throw BSANUnauthorizedException("No autorizado")
        case URLError.notConnectedToInternet.rawValue, Int(CFNetworkErrors.cfurlErrorDataNotAllowed.rawValue):
            BSANLogger.e(logTag, "makeCall generic error : No internet connection")
            throw BSANNetworkException("")
        default:
            // Respuesta WS Codigo de Error generico
            // Se incluyen aquí los SoapFault!
            BSANLogger.e(logTag, "makeCall generic error o SoapFault: Status -> \(status)")
            if responseString != "" {
                return responseString
            }
            throw BSANServiceException("")
        }
    }

    private func getStatusCode(_ response: DataResponse<String>) -> Int {
        var statusCode = -1
        if response.result.isSuccess, let response = response.response {
            statusCode = response.statusCode
        } else if response.result.isFailure, let error = response.error {
            statusCode = error._code
        }
        return statusCode
    }

}
