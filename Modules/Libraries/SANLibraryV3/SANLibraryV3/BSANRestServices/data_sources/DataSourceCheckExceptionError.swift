import Foundation
import SwiftyJSON

protocol DataSourceCheckExceptionErrorProtocol {
    func checkExceptionError(error: Error) -> String
    func checkServiceError(response: String) -> String?
    func checkServiceMoreInfoError(response: String) -> String?
    func getServiceErrorInfo(response: String) -> RestResponse
}

extension DataSourceCheckExceptionErrorProtocol {	
    func checkExceptionError(error: Error) -> String {
        var errorDesc = "ERROR DESCONOCIDO"
        if let error = error as? BSANException {
            errorDesc = error.localizedDescription
        }
        else if let error = error as? ParserException {
            errorDesc = error.localizedDescription
        }
        else {
            errorDesc = error.localizedDescription
        }
        
        return errorDesc
    }
    
    func checkServiceError(response: String) -> String? {
        return checkField(key: "httpMessage", from: response)
    }
    
    func checkServiceMoreInfoError(response: String) -> String? {
        return checkField(key: "moreInformation", from: response)
    }
    
    func getServiceErrorInfo(response: String) -> RestResponse {
        let restResponse = RestResponse.init(json: JSON.init(parseJSON: response))
        return restResponse
    }
    
    private func checkField(key: String, from response: String) -> String? {
        guard let data = response.data(using: .utf8) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDictionary = json as? [String: Any] else {
            return nil
        }
        if jsonDictionary["httpCode"] is Int, let httpMessage = jsonDictionary[key] as? String {
            return httpMessage
        }
        return nil
    }
}
