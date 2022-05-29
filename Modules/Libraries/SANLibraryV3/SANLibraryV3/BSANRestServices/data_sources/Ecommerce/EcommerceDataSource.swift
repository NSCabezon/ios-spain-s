import Foundation
import SANLegacyLibrary

protocol EcommerceDataSourceProtocol: RestDataSource {
    func getOperationData(shortUrl: String) throws -> BSANResponse<EcommerceOperationDataDTO>
    func getLastOperationShortUrl(documentType: String, documentNumber: String, tokenPush: String) throws -> BSANResponse<EcommerceLastOperationShortUrlDTO>
    func confirmWithAccessKey(shortUrl: String, key: String) throws -> BSANResponse<Void>
    func confirmWithFingerPrint(input: EcommerceConfirmWithFingerPrintInputParams) throws -> BSANResponse<Void>
}

public class EcommerceDataSource {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let apiBasePath =  "/api/v1/sca/"
    private let slash = "/"
    private let operationDataServiceName = "datosOperacion"
    private let shortUrlServiceName = "sca-shorturl"
    private let autenticationServiceName = "autenticacion"
    private let fingerPrintServiceName = "fingerprint-authentication"
    private var headers = [
        "X-Santander-Channel": "RML",
        "X-ClientId": "MULMOV"
    ]

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
}

extension EcommerceDataSource: EcommerceDataSourceProtocol {
    func getOperationData(shortUrl: String) throws -> BSANResponse<EcommerceOperationDataDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.ecommerceUrl else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.operationDataServiceName + self.slash + shortUrl
        return try self.executeRestCall(
            serviceName: operationDataServiceName,
            serviceUrl: url,
            queryParam: nil,
            body: nil,
            requestType: .get,
            headers: headers,
            responseEncoding: .utf8)
    }
    
    func checkServiceError(response: String) -> String? {
        return response
    }

    func getLastOperationShortUrl(documentType: String, documentNumber: String, tokenPush: String) throws -> BSANResponse<EcommerceLastOperationShortUrlDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.ecommerceUrl else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.shortUrlServiceName
        let inputParams = EcommerceLastOperationUrlParams(documentType: documentType, documentNumber: documentNumber)
        self.headers["Token-Push"] = tokenPush
        return try self.executeRestCall(
            serviceName: shortUrlServiceName,
            serviceUrl: url,
            queryParam: inputParams,
            body: nil,
            requestType: .get,
            headers: headers,
            responseEncoding: .utf8)
    }

    func confirmWithAccessKey(shortUrl: String, key: String) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.ecommerceUrl else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.autenticationServiceName + self.slash + shortUrl + self.slash + key
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: autenticationServiceName,
                serviceUrl: url,
                body: nil,
                queryParams: nil,
                requestType: .get,
                headers: headers,
                responseEncoding: .utf8
            )
        )
        return handleConfirmationResponse(response as? RestJSONResponse)
    }

    func confirmWithFingerPrint(input: EcommerceConfirmWithFingerPrintInputParams) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.ecommerceUrl else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.fingerPrintServiceName
        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: fingerPrintServiceName,
                serviceUrl: url,
                params: self.paramsDictionary(for: input),
                removesEscapeCharacters: false,
                contentType: .json,
                requestType: .post,
                headers: headers,
                responseEncoding: .utf8
            )
        )
        return handleConfirmationResponse(response as? RestJSONResponse)
    }
}

extension EcommerceDataSource: DataSourceCheckExceptionErrorProtocol {}

private extension EcommerceDataSource {
    func handleConfirmationResponse(_ response: RestJSONResponse?) -> BSANResponse<Void> {
        guard let response = response else {
            return BSANErrorResponse(Meta.createKO())
        }
        let httpCode = response.httpCode
        guard httpCode != 200 else {
            return BSANOkEmptyResponse()
        }
        guard let responseString = response.message,
              let responseError = self.checkServiceError(response: responseString)
        else {
            return BSANErrorResponse(Meta.createKO())
        }
        return BSANErrorResponse(Meta.createKO(responseError))
    }
}
