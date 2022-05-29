import SwiftyJSON

public class PreGrantedLoanSimulatorDataSourceImpl: PreGrantedLoanSimulatorDataSource {
    private let basePath = "/api/v1/envioPagos/preconcedidos/"
    private let activeCampaignsServiceName = "checkActive"
    private let loadLimitsServiceName = "limitManager"
    private let simulationServiceName = "consumo/simulacion"
    private let headers = ["X-Santander-Channel" : "RML"]
    private let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func checkActive(channel: String, companyId: String) throws -> BSANResponse<CampaignsCheckLoanSimulatorDTO> {
        var dictionary = [String : String]()
        dictionary["companyId"] = companyId
        dictionary["channel"] = channel
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.activeCampaignsServiceName
        do{
            if let response = try sanRestServices.executeRestCall(request: RestRequest(serviceName: self.activeCampaignsServiceName,
                                                                                       serviceUrl: url,
                                                                                       params: dictionary,
                                                                                       contentType: ContentType.queryString,
                                                                                       requestType: .get,
                                                                                       headers: headers)) {
                if let responseString = (response as? RestJSONResponse)?.message {
                    if let error = checkServiceError(response: responseString){
                        return BSANErrorResponse(Meta.createKO(error))
                    }
                    return BSANOkResponse(CampaignsCheckLoanSimulatorDTO(json: JSON.init(parseJSON: responseString)))
                }
            }
        }catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
    
    func limitManager(body: CampaignQueryDTO) throws -> BSANResponse<LoanSimulatorLimitDTO> {
        var dictionary = [String : Any]()
        let jsonEncoder = JSONEncoder()
        if let json = try? jsonEncoder.encode(body) {
            let jsonResponse = try? JSONSerialization.jsonObject(with: json, options: [])
            if let dict = jsonResponse as? [String : Any] {
                dictionary = dict
            }
        }
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.loadLimitsServiceName
        do{
            if let response = try sanRestServices.executeRestCall(request: RestRequest(serviceName: self.loadLimitsServiceName,
                                                                                            serviceUrl: url,
                                                                                            params: dictionary,
                                                                                            contentType: ContentType.json,
                                                                                            requestType: .post,
                                                                                            headers: headers)) {
                if let responseString = (response as? RestJSONResponse)?.message {
                    if let error = checkServiceError(response: responseString){
                        return BSANErrorResponse(Meta.createKO(error))
                    }
                    return BSANOkResponse(LoanSimulatorLimitDTO(json: JSON.init(parseJSON: responseString)))
                }
            }
        }catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
        
    }
    
    func simulation(body: LoanSimulationDTO) throws -> BSANResponse<LoanSimulatorConditionsDTO> {
        var dictionary = [String : Any]()
        let jsonEncoder = JSONEncoder()
        if let json = try? jsonEncoder.encode(body) {
            let jsonResponse = try? JSONSerialization.jsonObject(with: json, options: [])
            if let dict = jsonResponse as? [String : Any] {
                dictionary = dict
            }
        }
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.simulationServiceName
        do{
            if let response = try sanRestServices.executeRestCall(request: RestRequest(serviceName: self.simulationServiceName,
                                                                                            serviceUrl: url,
                                                                                            params: dictionary,
                                                                                            contentType: ContentType.json,
                                                                                            requestType: .post,
                                                                                            headers: headers)) {
                if let responseString = (response as? RestJSONResponse)?.message {
                    if let error = checkServiceError(response: responseString){
                        return BSANErrorResponse(Meta.createKO(error))
                    }
                    return BSANOkResponse(LoanSimulatorConditionsDTO(json: JSON.init(parseJSON: responseString)))
                }
            }
        } catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
}

// MARK: - Private Methods
private extension PreGrantedLoanSimulatorDataSourceImpl {
    
    func checkExceptionError(error: Error) -> String{
        var errorDesc = "ERROR DESCONOCIDO"
        if let error = error as? BSANException{
            errorDesc = error.localizedDescription
        }
        else if let error = error as? ParserException{
            errorDesc = error.localizedDescription
        }
        else{
            errorDesc = error.localizedDescription
        }
        
        return errorDesc
    }
    
    func checkServiceError(response: String) -> String?{
        let restResponse = RestResponse.init(json: JSON.init(parseJSON: response))
        if let _ = restResponse.httpCode, let httpMessage = restResponse.httpMessage{
            return httpMessage
        }
        
        return nil
    }
}
