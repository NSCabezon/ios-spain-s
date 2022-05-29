import SwiftyJSON

public class InsuranceDataSourceImpl: InsuranceDataSource {
    
    private var sanRestServices: SanRestServices
    
    public static let INSURANCE_DATA_SERVICE_NAME = "insurance_data"
    public static let INSURANCE_GET_PARTICIPANTS_SERVICE_NAME = "insurance_get_participants"
    public static let INSURANCE_GET_BENEFICIARIES_SERVICE_NAME = "insurance_get_beneficiaries"
    public static let INSURANCE_GET_COVERAGE_SERVICE_NAME = "insurance_get_coverage"
    
    public init(sanRestServices: SanRestServices){
        self.sanRestServices = sanRestServices
    }
    
    private func checkServiceError(response: String) -> String?{
        let restResponse = RestResponse.init(json: JSON.init(parseJSON: response))
        if let _ = restResponse.httpCode, let httpMessage = restResponse.httpMessage{
            return httpMessage
        }
        
        return nil
    }
    
    private func checkExceptionError(error: Error) -> String{
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
    
    public func getInsuranceData(absoluteUrl: String) throws -> BSANResponse<InsuranceDataDTO> {
        let params = ["operative_type" : "CP"]
        let request = RestRequest(
            serviceName: InsuranceDataSourceImpl.INSURANCE_DATA_SERVICE_NAME,
            serviceUrl: absoluteUrl,
            params: params,
            contentType: ContentType.queryString
        )
        do {
            guard let response = try sanRestServices.executeRestCall(request: request) as? String else {
                return BSANErrorResponse(Meta.createKO("NetworkException"))
            }
            if let error = checkServiceError(response: response){
                return BSANErrorResponse(Meta.createKO(error))
            }
            return BSANOkResponse(InsuranceDataDTO(json: JSON.init(parseJSON: response)))
        } catch let error {
            return BSANErrorResponse(Meta.createKO(checkExceptionError(error: error)))
        }
    }
    
    public func getParticipants(absoluteUrl: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceParticipantDTO]> {
        let params = ["family_id" : familyId,
                      "thirdparty_ind" : thirdPartyInd,
                      "factory_policy_number" : factoryPolicyNumber,
                      "contract_id" : contractId]
        let request = RestRequest(
            serviceName: InsuranceDataSourceImpl.INSURANCE_GET_PARTICIPANTS_SERVICE_NAME,
            serviceUrl: absoluteUrl,
            params: params,
            contentType: ContentType.queryString
        )
        do {
            guard let response = try sanRestServices.executeRestCall(request: request) as? String else {
                return BSANErrorResponse(Meta.createKO("NetworkException"))
            }
            if let error = checkServiceError(response: response){
                return BSANErrorResponse(Meta.createKO(error))
            }
            return BSANOkResponse(InsuranceParticipantsListDTO(json: JSON.init(parseJSON: response)).participants)
        } catch let error {
            return BSANErrorResponse(Meta.createKO(checkExceptionError(error: error)))
        }
    }
    
    public func getBeneficiaries(absoluteUrl: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceBeneficiaryDTO]> {
        
        let params = ["family_id" : familyId,
                      "thirdparty_ind" : thirdPartyInd,
                      "factory_policy_number" : factoryPolicyNumber,
                      "contract_id" : contractId]
        let request = RestRequest(serviceName: InsuranceDataSourceImpl.INSURANCE_GET_BENEFICIARIES_SERVICE_NAME,
                                  serviceUrl: absoluteUrl,
                                  params: params,
                                  contentType: ContentType.queryString)
        do {
            guard let response = try sanRestServices.executeRestCall(request: request) as? String else {
                return BSANErrorResponse(Meta.createKO("NetworkException"))
            }
            if let error = checkServiceError(response: response){
                return BSANErrorResponse(Meta.createKO(error))
            }
            return BSANOkResponse(InsuranceBeneficiariesListDTO(json: JSON.init(parseJSON: response)).beneficiaries)
        } catch let error {
            return BSANErrorResponse(Meta.createKO(checkExceptionError(error: error)))
        }
    }
    
    public func getCoverages(absoluteUrl: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceCoverageDTO]> {
        
        let params = ["family_id" : familyId,
                      "thirdparty_ind" : thirdPartyInd,
                      "factory_policy_number" : factoryPolicyNumber,
                      "contract_id" : contractId]
        let request = RestRequest(
            serviceName: InsuranceDataSourceImpl.INSURANCE_GET_COVERAGE_SERVICE_NAME,
            serviceUrl: absoluteUrl,
            params: params,
            contentType: ContentType.queryString
        )
        do {
            guard let response = try sanRestServices.executeRestCall(request: request) as? String else {
                return BSANErrorResponse(Meta.createKO("NetworkException"))
            }
            if let error = checkServiceError(response: response){
                return BSANErrorResponse(Meta.createKO(error))
            }
            return BSANOkResponse(InsuranceCoveragesListDTO(json: JSON.init(parseJSON: response)).coverages)
        } catch let error {
            return BSANErrorResponse(Meta.createKO(checkExceptionError(error: error)))
        }
    }
}
