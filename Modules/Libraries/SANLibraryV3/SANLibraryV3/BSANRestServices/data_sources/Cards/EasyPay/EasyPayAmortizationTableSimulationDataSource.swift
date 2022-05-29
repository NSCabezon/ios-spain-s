protocol EasyPayAmortizationTableSimulationDataSourceProtocol: RestDataSource {
    func getAmortizationEasyPayRequest(input: EasyPayAmortizationRequestParams) throws -> BSANResponse<EasyPayAmortizationDTO>
}

public class EasyPayAmortizationTableSimulationDataSource: EasyPayAmortizationTableSimulationDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let amortizationSimulationSANServicePath = "/api/v1/requests/"
    private let serviceName = "amortizationTableSimulation"
    private let headers = ["X-Santander-Channel":"RML"]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }

    func getAmortizationEasyPayRequest(input: EasyPayAmortizationRequestParams) throws -> BSANResponse<EasyPayAmortizationDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + amortizationSimulationSANServicePath + serviceName
        var dictionary = [String : Any]()
        let body = EasyPayAmortizationQueryInputDTO(input: input)
        dictionary = parseBodyToDictionary(body: body)
        return try self.executeRestCall(serviceName: serviceName,
                                        serviceUrl: url,
                                        queryParam: nil,
                                        body: Body(bodyParam: dictionary, contentType: .json),
                                        requestType: .post,
                                        headers: headers,
                                        responseEncoding: .utf8)
    }
}

private extension EasyPayAmortizationTableSimulationDataSource {
    func createRequest(_ url: String, dictionary: [String: Any]) -> RestRequest {
        return RestRequest(serviceName: serviceName,
                           serviceUrl: url,
                           params: dictionary,
                           contentType: .json,
                           requestType: .post,
                           headers: headers)
    }
    
    func parseBodyToDictionary(body: EasyPayAmortizationQueryInputDTO) -> [String: Any] {
        let jsonEncoder = JSONEncoder()
        var dictionary = [String : Any]()
        if let json = try? jsonEncoder.encode(body) {
            let jsonResponse = try? JSONSerialization.jsonObject(with: json, options: [])
            if let dict = jsonResponse as? [String : Any] {
                dictionary = dict
            }
        }
        return dictionary
    }
}
