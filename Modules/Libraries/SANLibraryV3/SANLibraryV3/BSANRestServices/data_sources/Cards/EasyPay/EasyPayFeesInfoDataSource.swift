//

import SwiftyJSON

protocol EasyPayFeesInfoDataSourceProtocol: RestDataSource {
    func getFeesInfo(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<FeesInfoDTO>
}

public class EasyPayFeesInfoDataSource: EasyPayFeesInfoDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let feesSANServicePath = "/api/v1/requests/"
    private let serviceName = "simulationPurchaseInstallments"
    private let headers = ["X-Santander-Channel":"RML"]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getFeesInfo(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<FeesInfoDTO> {
        
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + feesSANServicePath + serviceName
        var dictionary = [String : Any]()
        let body = EasyPayFeesQueryDTO(card: card, input: input)
        dictionary = parseBodyToDictionary(body: body)
        
        do{
            let request = createRequest(url, dictionary: dictionary)
            if let response: Any = try sanRestServices.executeRestCall(request: request),
               let responseString = (response as? RestJSONResponse)?.message {
                if let error = checkServiceMoreInfoError(response: responseString) {
                    return BSANErrorResponse(Meta.createKO(error))
                }
                return BSANOkResponse(FeesInfoDTO(json: JSON.init(parseJSON: responseString)))
            }
        }catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
}

private extension EasyPayFeesInfoDataSource {
    
    func createRequest(_ url: String, dictionary: [String: Any]) -> RestRequest {
        return RestRequest(serviceName: serviceName,
                           serviceUrl: url,
                           params: dictionary,
                           contentType: .json,
                           requestType: .post,
                           headers: headers)
    }
    
    func parseBodyToDictionary(body: EasyPayFeesQueryDTO) -> [String: Any] {
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
