import Alamofire_Synchronous
import SANLegacyLibrary
import Foundation
import Alamofire

public class RestAlamoExecutor: RestServiceExecutor {
    
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
    
    public init(_ alamofireManager: Alamofire.SessionManager, webServicesUrlProvider: WebServicesUrlProvider, bsanDataProvider: BSANDataProvider) {
        self.alamofireManager = alamofireManager
        self.webServicesUrlProvider = webServicesUrlProvider
        self.bsanDataProvider = bsanDataProvider
        self.alamofireManager.delegate.dataTaskWillCacheResponse = self.dataTaskWillCacheResponse
    }
    
    private func dataTaskWillCacheResponse(_ session: URLSession, dataTask: URLSessionDataTask, response: CachedURLResponse) -> CachedURLResponse? {
        return nil
    }
    
    public func executeCall(restRequest: RestRequest) throws -> Any?{
        let finalUrlString: String
        if restRequest.contentType == .queryString, let queryString = restRequest.queryParams {
            finalUrlString = "\(restRequest.serviceUrl)?\(queryString)"
        } else {
            finalUrlString = restRequest.serviceUrl
        }
        
        guard let finalUrl = URL(string: finalUrlString) else { return nil }
        var request = URLRequest(url: finalUrl)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        addAuthorizationIfNeeded(request: &request, bsanDataProvider: bsanDataProvider)
        
        if let httpBody = restRequest.body {
            request.addValue("application/\(restRequest.contentType.rawValue)", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        }
        if self.webServicesUrlProvider.isMulMovActivate(finalUrlString) {
            request.addValue("MULMOV", forHTTPHeaderField: "X-ClientId")
        }
        
        request.httpMethod = (finalUrl.absoluteString.contains(webServicesUrlProvider.getLoginUrl())) ? "POST" : "GET"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let dataRequest = self.alamofireManager.request(request)
        
        let response = dataRequest.responseString()
        
        if response.result.isSuccess && response.response?.statusCode == 200 {
            BSANLogger.i(logTag, "makeCall OK")
            return response.result.value
        } else if let responseAux = response.response {
            switch responseAux.statusCode {
            case httpUnathorized:
                // Respuesta WS Error autenticacion
                BSANLogger.e(logTag, "makeCall Authentication error")
                
                if needsRefreshToken(request: restRequest, bsanDataProvider: bsanDataProvider){
                    self.isRetrying = true
                    if refreshToken(bsanDataProvider: bsanDataProvider){
                        return try self.executeCall(restRequest: restRequest)
                    }
                }

                throw BSANUnauthorizedException("No autorizado")
            case httpError:
                
                BSANLogger.e(logTag, "makeCall error 400")
                return response.result.value
                
            case URLError.notConnectedToInternet.rawValue:
                BSANLogger.e(logTag, "makeCall generic error : No internet connection")
                throw BSANNetworkException("")
            default:
                // Respuesta WS Codigo de Error generico
                // Se incluyen aquí los SoapFault!
                BSANLogger.e(logTag, "makeCall generic error : Status -> \(responseAux.statusCode)")
                //                    return response.result.value
                throw BSANServiceException("")
            }
        }
        return nil
    }
    
    private func needsRefreshToken(request: RestRequest, bsanDataProvider: BSANDataProvider) -> Bool{
        guard let credentials = try? bsanDataProvider.getAuthCredentials() else { return false }
        return (credentials.apiTokenCredential != nil && credentials.apiTokenType != nil) && !isRetrying && !request.serviceUrl.contains(webServicesUrlProvider.getLoginUrl())
    }
    
    private func refreshToken(bsanDataProvider: BSANDataProvider) -> Bool {
        guard
            let environmentDTO = try? bsanDataProvider.getEnvironment(),
            let authCredentials = try? bsanDataProvider.getAuthCredentials()
            else { return false }
        let dataSource = AuthDataSourceImpl(sanRestServices: SanRestServicesImpl(callExecutor: self, demoExecutor: nil, bsanDataProvider: bsanDataProvider))
        guard
            let clientId = try? webServicesUrlProvider.getLoginUrl(),
            let clientSecret = try? webServicesUrlProvider.getClientSecret(),
            let tokenOAuthResponse = try? dataSource.getApiTokenCredential(
                absoluteUrl: webServicesUrlProvider.getLoginUrl(),
                clientId: clientId,
                clientSecret: clientSecret,
                scope: Constants.SCOPE,
                grantType: Constants.GRANT_TYPE,
                token: authCredentials.soapTokenCredential
            ),
            let accessToken = tokenOAuthResponse.accessToken,
            let tokenType = tokenOAuthResponse.tokenType
            else { return false }
        bsanDataProvider.storeAuthCredentials(AuthCredentials(soapTokenCredential: authCredentials.soapTokenCredential, apiTokenCredential: accessToken, apiTokenType: tokenType))
        return true
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
    
    private func addAuthorizationIfNeeded(request: inout URLRequest, bsanDataProvider: BSANDataProvider) {
        do {
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            let bsanEnvironment = try bsanDataProvider.getEnvironment()
            if (needsToAddAuthorizationHeader(request: request, bsanDataProvider: bsanDataProvider)) {
                if let tokenType = authCredentials.apiTokenType,
                    let tokenCredentials = authCredentials.apiTokenCredential{
                    request.addValue("\(tokenType.capitalized)\(tokenCredentials)", forHTTPHeaderField: "Authorization")
                    request.addValue(try webServicesUrlProvider.getClientId(), forHTTPHeaderField: "x-ibm-client-id")
                }
            }
        } catch let error {
            BSANLogger.e(logTag, "addAuthorizationIfNeeded : \(error.localizedDescription)")
        }
    }
    
    private func needsToAddAuthorizationHeader(request: URLRequest, bsanDataProvider: BSANDataProvider) -> Bool{
        do {
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            guard
                authCredentials.apiTokenCredential != nil,
                authCredentials.apiTokenType != nil,
                let url = request.url
                else { return false }
            return !url.absoluteString.contains(webServicesUrlProvider.getLoginUrl())
        } catch let error {
            BSANLogger.e(logTag, "needsToAddAuthorizationHeader : \(error.localizedDescription)")
            return false
        }
    }
}
