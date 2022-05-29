//

import Foundation

protocol RestDataSource: DataSourceCheckExceptionErrorProtocol {
    var sanRestServices: SanRestServices { get }
}

enum DataSourceError: Error {
    case unknown
    case serviceError(String?)
}

extension RestDataSource {
    
    func executeRestCall<RequestParams: Encodable, Output: Decodable>(
        serviceName: String,
        serviceUrl: String,
        params: RequestParams,
        removesEscapeCharacters: Bool = false,
        contentType: ContentType,
        requestType: RequesType,
        headers: [String: String] = [:],
        responseEncoding: String.Encoding? = nil
    ) throws -> BSANResponse<Output> {
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: serviceName,
                serviceUrl: serviceUrl,
                params: self.paramsDictionary(for: params),
                removesEscapeCharacters: removesEscapeCharacters,
                contentType: contentType,
                requestType: requestType,
                headers: headers,
                responseEncoding: responseEncoding
            )
        )
        return try self.handleResponse(response).bsanResponse()
    }
    
    func executeRestCall<Output: Decodable>(
        serviceName: String,
        serviceUrl: String,
        queryParam: [String: Any]?,
        body: Body?,
        requestType: RequesType,
        headers: [String: String] = [:],
        responseEncoding: String.Encoding? = nil
    ) throws -> BSANResponse<Output> {
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: serviceName,
                serviceUrl: serviceUrl,
                body: body,
                queryParams: queryParam,
                requestType: requestType,
                headers: headers,
                responseEncoding: responseEncoding
            )
        )
        return try self.handleResponse(response).bsanResponse()
    }

    func executeRestCall<Output: Decodable, QueryParam: Encodable>(
        serviceName: String,
        serviceUrl: String,
        queryParam: QueryParam,
        body: Body?,
        requestType: RequesType,
        headers: [String: String] = [:],
        responseEncoding: String.Encoding? = nil
    ) throws -> BSANResponse<Output> {
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: serviceName,
                serviceUrl: serviceUrl,
                body: body,
                queryParams: self.paramsDictionary(for: queryParam),
                requestType: requestType,
                headers: headers,
                responseEncoding: responseEncoding
            )
        )
        return try self.handleResponse(response).bsanResponse()
    }

    func executeRestCallWithoutParams<Output: Decodable>(serviceName: String, serviceUrl: String, contentType: ContentType, requestType: RequesType, headers: [String: String] = [:], responseEncoding: String.Encoding? = nil) throws -> BSANResponse<Output> {
        let request = RestRequest(serviceName: serviceName, serviceUrl: serviceUrl, params: [:], contentType: contentType, requestType: requestType, headers: headers, responseEncoding: responseEncoding)
        let response = try self.sanRestServices.executeRestCall(request: request)
        return try self.handleResponse(response).bsanResponse()
    }
    
    func paramsDictionary<Object: Encodable>(for object: Object) -> [String: Any] {
        let encoder = JSONEncoder()
        if let dateParseable = Object.self as? DateParseable.Type {
            encoder.dateEncodingStrategy = .custom(dateParseable.encoding)
        }
        guard
            let data = try? encoder.encode(object),
            let dictionary = try? JSONSerialization.jsonObject(with: data) as? NSDictionary
        else {
            return [:]
        }
        return dictionary as? [String: Any] ?? [:]
    }
    
    func bodyData<Object: Encodable>(for object: Object) -> Data? {
        let encoder = JSONEncoder()
        if let dateParseable = Object.self as? DateParseable.Type {
            encoder.dateEncodingStrategy = .custom(dateParseable.encoding)
        }
        return try? encoder.encode(object)
    }
    
    private func handleResponse<Output: Decodable>(_ response: Any?) throws -> Result<Output, DataSourceError> {
        let responseString: String
        if let response = response as? RestJSONResponse, let message = response.message {
            responseString = message
        } else if let response = response as? String {
            responseString = response
        } else {
            return .failure(DataSourceError.unknown)
        }
        guard let responseData = responseString.data(using: .utf8) else {
            return .failure(DataSourceError.serviceError(checkServiceError(response: responseString)))
        }
        let decoder = JSONDecoder()
        if let dateParseable = Output.self as? DateParseable.Type {
            decoder.dateDecodingStrategy = .custom(dateParseable.decode)
        }
        do {
            let response = try decoder.decode(Output.self, from: responseData)
            return .success(response)
        } catch {
            if let responseError: String = self.checkServiceError(response: responseString) {
                return .failure(DataSourceError.serviceError(responseError))
            } else {
                return .failure(.unknown)
            }
        }
    }

}

private extension Result where Success: Decodable, Failure == DataSourceError {
    
    func bsanResponse() -> BSANResponse<Success> {
        switch self {
        case .success(let response):
            return BSANOkResponse(response)
        case .failure(let error):
            switch error {
            case .unknown:
                return BSANOkResponse(Meta.createKO("NetworkException"))
            case .serviceError(let errorString):
                 return BSANOkResponse(Meta.createKO(errorString ?? "NetworkException"))
            }
        }
    }
}
