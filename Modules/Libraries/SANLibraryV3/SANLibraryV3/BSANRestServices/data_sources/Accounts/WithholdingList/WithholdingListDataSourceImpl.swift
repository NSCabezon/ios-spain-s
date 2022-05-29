import Foundation

public class WithholdingListDataSourceImpl: WithholdingListDataSource {
    private let serviceName = "retenciones"
    private let headers = ["X-Santander-Channel" : "RML"]
    private let basePath = "/api/v1/envioPagos/"
    private let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getWithholdingList(body: WithholdingListQueryDTO) throws -> BSANResponse<WithholdingListDTO> {
        var dictionary = [String : Any]()
        let jsonEncoder = JSONEncoder()
        
        guard let json = try? jsonEncoder.encode(body) else {
            return BSANErrorResponse(Meta.createKO("Json not encoded properly"))
        }
        let jsonResponse = try? JSONSerialization.jsonObject(with: json, options: [])
        guard let dict = jsonResponse as? [String : Any] else {
            return BSANErrorResponse(Meta.createKO("Json not serializated properly"))
        }
        dictionary = dict
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.serviceName
        do {
            if let response: Any = try sanRestServices.executeRestCall(
                request: RestRequest(serviceName: self.serviceName,
                                     serviceUrl: url,
                                     params: dictionary,
                                     contentType: ContentType.json,
                                     requestType: .post,
                                     headers: headers)
                ) {
                
                if let responseString = (response as? RestJSONResponse)?.message {
                    if let error = checkServiceError(response: responseString) {
                        return BSANErrorResponse(Meta.createKO(error))
                    }
                    // Serialize
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormats.santanderDDMMYYYYFormat)
                    
                    if let data = responseString.data(using: .utf8, allowLossyConversion: false),
                        let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []),
                        let serialized = try? JSONSerialization.data(withJSONObject: responseDictionary),
                        let responseFinal = try? decoder.decode(WithholdingListDTO.self, from: serialized) {
                        
                        return BSANOkResponse(responseFinal)
                    }
                }
            }
        } catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
}

extension WithholdingListDataSourceImpl: DataSourceCheckExceptionErrorProtocol {}
