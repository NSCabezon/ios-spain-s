import Foundation
import Alamofire
import SANLegacyLibrary
import Alamofire_Synchronous

public struct RestJSONResponse {
    public let httpCode: Int
    public let message: String?
    public init(httpCode: Int, message: String?) {
        self.httpCode = httpCode
        self.message = message
    }
}

public class RestJSONAlamoExecutor: RestServiceExecutor {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    public let httpOk = 200
    public let httpError = 400
    public let httpUnathorized = 401
    
    private var alamofireManager: Alamofire.SessionManager
    private var webServicesUrlProvider: WebServicesUrlProvider
    private var bsanDataProvider: BSANDataProvider
    private var isRetrying = false
    private let httpNotContent = 204
    
    public init(_ alamofireManager: Alamofire.SessionManager, webServicesUrlProvider: WebServicesUrlProvider, bsanDataProvider: BSANDataProvider) {
        self.alamofireManager = alamofireManager
        self.webServicesUrlProvider = webServicesUrlProvider
        self.bsanDataProvider = bsanDataProvider
        self.alamofireManager.delegate.dataTaskWillCacheResponse = self.dataTaskWillCacheResponse
        self.alamofireManager.delegate.dataTaskWillCacheResponseWithCompletion = self.dataTaskWillCacheResponseWithCompletion
    }
    
    private func  dataTaskWillCacheResponseWithCompletion(_ session: URLSession, dataTask: URLSessionDataTask, response: CachedURLResponse, completion: @escaping (CachedURLResponse?) -> Void) {
        completion(nil)
    }
    
    private func dataTaskWillCacheResponse(_ session: URLSession, dataTask: URLSessionDataTask, response: CachedURLResponse) -> CachedURLResponse? {
        return nil
    }
    
    public func executeCall(restRequest: RestRequest) throws -> Any?{
        let finalUrlString: String
        if let queryString = restRequest.queryParams {
            finalUrlString = "\(restRequest.serviceUrl)?\(queryString)"
        } else {
            finalUrlString = restRequest.serviceUrl
        }
        guard let finalUrl = URL(string: finalUrlString) else { return nil }
        var request = URLRequest(url: finalUrl)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request = addAuthorizationIfNeeded(request: &request, bsanDataProvider: bsanDataProvider)
        if let httpBody = restRequest.body {
            request.addValue("application/\(restRequest.contentType.rawValue)", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        }
        restRequest.headers.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        if self.webServicesUrlProvider.isMulMovActivate(finalUrlString), request.value(forHTTPHeaderField: "X-ClientId") == nil {
            request.addValue("MULMOV", forHTTPHeaderField: "X-ClientId")
        }
        switch restRequest.requestType {
        case .post:
            request.httpMethod = "POST"
        case .get:
            request.httpMethod = "GET"
        }
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let dataRequest = self.alamofireManager.request(request)
        BSANLogger.i(logTag, dataRequest.debugDescription)
        let response = dataRequest.responseString(encoding: restRequest.responseEncoding)
        BSANLogger.i(logTag, response.debugDescription)
        guard response.result.isSuccess, response.response?.statusCode == 200 else {
            return try evaluateNotSuccess(request: restRequest, response: response)
        }
        BSANLogger.i(logTag, "makeCall OK")
        return RestJSONResponse(httpCode: 200, message: response.result.value)
    }
    
    private func evaluateNotSuccess(request: RestRequest, response: DataResponse<String>) throws -> RestJSONResponse? {
        return response.response != nil ? try checkErrorInResponse(request: request, response): try checkErrorInError(response.error)
    }
    
    private func checkErrorInResponse(request: RestRequest,_ response: DataResponse<String>) throws -> RestJSONResponse? {
        guard let httpResponse = response.response else { return nil }
        switch httpResponse.statusCode {
        case httpUnathorized:
            // Respuesta WS Error autenticacion
            BSANLogger.e(logTag, "makeCall Authentication error")
            if needsRefreshToken(request: request, bsanDataProvider: bsanDataProvider) {
                self.isRetrying = true
                if refreshToken(bsanDataProvider: bsanDataProvider) {
                    return try self.executeCall(restRequest: request) as? RestJSONResponse
                }
            }
            throw BSANUnauthorizedException("No autorizado", responseValue: response.result.value)
        case httpError:
            BSANLogger.e(logTag, "makeCall error 400")
            return RestJSONResponse(httpCode: httpError, message: response.result.value)
        case URLError.notConnectedToInternet.rawValue:
            BSANLogger.e(logTag, "makeCall generic error : No internet connection")
            throw BSANNetworkException("")
        case httpNotContent:
            BSANLogger.e(logTag, "makeCall No content data")
            return RestJSONResponse(httpCode: httpNotContent, message: String(httpResponse.statusCode))
        case 500...504:
            BSANLogger.e(logTag, "makeCall error 500")
            return RestJSONResponse(httpCode: httpResponse.statusCode, message: response.result.value)
        case 403:
            BSANLogger.e(logTag, "makeCall error 403")
            return RestJSONResponse(httpCode: httpResponse.statusCode, message: response.result.value)
        default:
            // Respuesta WS Codigo de Error generico
            // Se incluyen aquí los SoapFault!
            BSANLogger.e(logTag, "makeCall generic error : Status -> \(httpResponse.statusCode)")
            throw BSANServiceException("")
        }
    }
    
    private func checkErrorInError(_ error: Error?) throws -> RestJSONResponse? {
        guard let error = error as? URLError else { return nil }
        switch error.code {
        case .notConnectedToInternet, .cannotFindHost:
            BSANLogger.e(logTag, "makeCall generic error : No internet connection")
            throw BSANNetworkException("")
        default:
            return nil
        }
    }
    
    private func needsRefreshToken(request: RestRequest, bsanDataProvider: BSANDataProvider) -> Bool{
        do {
            let credentials = try bsanDataProvider.getAuthCredentials()
            return (credentials.apiTokenCredential != nil && credentials.apiTokenType != nil) && !isRetrying && !request.serviceUrl.contains(webServicesUrlProvider.getLoginUrl())
        } catch _ as NSError {
            return false
        }
    }
    
    private func refreshToken(bsanDataProvider: BSANDataProvider) -> Bool {
        do {
            let environmentDTO = try bsanDataProvider.getEnvironment()
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            let dataSource = AuthDataSourceImpl(
                sanRestServices: SanRestServicesImpl(
                    callExecutor: self,
                    demoExecutor: nil,
                    bsanDataProvider: bsanDataProvider
                )
            )
            let tokenOAuthResponse = try dataSource.getApiTokenCredential(
                absoluteUrl: webServicesUrlProvider.getLoginUrl(),
                clientId: webServicesUrlProvider.getClientId(),
                clientSecret: webServicesUrlProvider.getClientSecret(),
                scope: Constants.SCOPE,
                grantType: Constants.GRANT_TYPE,
                token: authCredentials.soapTokenCredential
            )
            if let tokenOAuthResponse = tokenOAuthResponse,
               let accessToken = tokenOAuthResponse.accessToken,
               let tokenType = tokenOAuthResponse.tokenType{
                bsanDataProvider.storeAuthCredentials(
                    AuthCredentials(
                        soapTokenCredential: authCredentials.soapTokenCredential,
                        apiTokenCredential: accessToken,
                        apiTokenType: tokenType
                    )
                )
                return true
            }
        } catch _ {
            return false
        }
        return false
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
    
    private func addAuthorizationIfNeeded(request: inout URLRequest, bsanDataProvider: BSANDataProvider) -> URLRequest{
        do {
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            let token = authCredentials.soapTokenCredential
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        } catch let e as BSANIllegalStateException{
            BSANLogger.e(logTag, "addAuthorizationIfNeeded : \(e.localizedDescription)")
            return request
        } catch let error as NSError{
            BSANLogger.e(logTag, "addAuthorizationIfNeeded : \(error.localizedDescription)")
            return request
        }
    }
    
    private func needsToAddAuthorizationHeader(request: URLRequest, bsanDataProvider: BSANDataProvider) -> Bool{
        do {
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            guard let _ = authCredentials.apiTokenCredential,
                  let _ = authCredentials.apiTokenType else{
                return false
            }
            if let url = request.url{
                return !url.absoluteString.contains(webServicesUrlProvider.getLoginUrl())
            }
            return false
        } catch let e as BSANIllegalStateException{
            BSANLogger.e(logTag, "needsToAddAuthorizationHeader : \(e.localizedDescription)")
            return false
        } catch let error as NSError{
            BSANLogger.e(logTag, "needsToAddAuthorizationHeader : \(error.localizedDescription)")
            return false
        }
    }
}
