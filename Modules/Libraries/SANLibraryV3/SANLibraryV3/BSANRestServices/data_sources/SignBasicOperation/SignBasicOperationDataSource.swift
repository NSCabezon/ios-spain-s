import Foundation

protocol SignBasicOperationDataSourceProtocol: RestDataSource {
    func execute<Output: Decodable>() throws -> BSANResponse<Output>
    func execute() throws -> BSANResponse<String>
}

enum BasicOperationEndpoint {
    case getSignPattern(cmc: String)
    case startSignPattern(patternId: String, instaId: String)
    case validateSignPattern(_ input: SignValidationInputParams)
}

final class SignBasicOperationDataSource: SignBasicOperationDataSourceProtocol {
    var sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let endpoint: BasicOperationEndpoint

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider, endpoint: BasicOperationEndpoint) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
        self.endpoint = endpoint
    }

    func execute() throws -> BSANResponse<String> {
        guard let url = try self.getURL() else { return BSANErrorResponse(nil) }
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: self.getServiceName(),
                serviceUrl: url,
                body: self.getBody(),
                queryParams: nil,
                requestType: .get,
                headers: self.getHeaders()))
        guard let jsonResponse = response as? RestJSONResponse,
              let responseString = jsonResponse.message else { return BSANErrorResponse(Meta.createKO("")) }
        return BSANOkResponse(responseString)
    }

    func execute<Output: Decodable>() throws -> BSANResponse<Output>  {
        guard let url = try self.getURL() else { return BSANErrorResponse(nil) }
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: self.getServiceName(),
                serviceUrl: url,
                body: self.getBody(),
                queryParams: self.getQueryParams(),
                requestType: self.getHTTPSMethod(),
                headers: self.getHeaders()
            )
        )
        if let responseString = (response as? RestJSONResponse)?.message {
            let error = getServiceErrorInfo(response: responseString)
            guard let _ = error.httpCode, let moreInformationError = error.moreInformation else {
                let decoder = JSONDecoder()
                guard let responseData = responseString.data(using: .utf8) else {
                    return BSANOkResponse(Meta.createKO("NETWORK EXCEPTION"))
                }
                let output = try decoder.decode(Output.self, from: responseData)
                return BSANOkResponse(output)
            }
            return BSANErrorResponse(Meta.createKO(moreInformationError))
        }
        return BSANErrorResponse(Meta.createKO("NETWORK EXCEPTION"))
    }
}

private extension SignBasicOperationDataSource {
    func getBasePath() -> String {
        "patronfirma/"
    }

    func getBSANEnvironment() throws -> String? {
        try self.bsanDataProvider.getEnvironment().microURL
    }

    func getURL() throws -> String? {
        let microURL = try self.getBSANEnvironment()
        guard let source = microURL else { return nil }
        let url: String = String(format: "%@/%@", source, self.getBasePath())
        switch self.endpoint {
        case .getSignPattern(let cmc):
            return String(format: "%@%@/%@/%@", url, "patron/SIGN02", cmc, self.getServiceName())
        case .startSignPattern, .validateSignPattern:
            return String(format: "%@%@", url, self.getServiceName())
        }
    }

    func getHTTPSMethod() -> RequesType {
        switch self.endpoint {
        case .getSignPattern:
            return .get
        case .startSignPattern, .validateSignPattern:
            return .post
        }
    }

    func getServiceName() -> String {
        switch self.endpoint {
        case .getSignPattern:
            return "X-PAY"
        case .startSignPattern:
            return "iniciarpatron"
        case .validateSignPattern:
            return "validar"
        }
    }

    func getHeaders() -> [String: String] {
        ["X-Santander-Channel": "RML"]
    }

    func getBody() -> Body? {
        switch self.endpoint {
        case .getSignPattern:
            return nil
        case .startSignPattern(let patternId, let instaId):
            var signatureData = ["posiciones"]
            if patternId == "SIGN02" {
                signatureData.append("otp")
            }
            let body = Body(
                bodyParam: ["operationData": ["insta_id" : instaId],
                            "patternId": patternId,
                            "signatureData": signatureData],
                contentType: .json
            )
            return body
        case .validateSignPattern(let input):
            return Body(bodyParam: input)
        }
    }

    func getQueryParams() -> [String: String]? {
        switch self.endpoint {
        case .getSignPattern:
            return nil
        case .startSignPattern:
            return nil
        case .validateSignPattern:
            return nil
        }
    }
}

extension SignBasicOperationDataSource: DataSourceCheckExceptionErrorProtocol {}
