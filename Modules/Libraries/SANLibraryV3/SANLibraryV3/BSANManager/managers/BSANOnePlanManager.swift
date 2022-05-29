import SANLegacyLibrary

public class BSANOnePlanManagerImplementation: BSANBaseManager, BSANOnePlanManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func checkOnePlan(ranges: [ProductOneRangeDTO]) throws -> BSANResponse<CustomerContractListDTO> {
        let identifier = ranges.reduce("") { $0 + $1.identifier }
        let contracts = try bsanDataProvider.get(\.customerContractDictionary)
        let httpCodes = try bsanDataProvider.get(\.checkOnePlanStatusCodeDictionary)
        if let dto = contracts[identifier], let httpCode = httpCodes[identifier], lastCallWasSuccess(httpCode: httpCode) {
            return BSANOkResponse(dto)
        }
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getOnePlanAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getAlternativeBsanHeaderData()
        let userDataDTO = try bsanDataProvider.getUserData()
        let request = CheckOnePlanRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            CheckOnePlanRequestParams(token: authCredentials.soapTokenCredential,
                                      languageISO: bsanHeaderData.languageISO,
                                      dialectISO: bsanHeaderData.dialectISO,
                                      linkedCompany: bsanHeaderData.linkedCompany,
                                      userDataDTO: userDataDTO,
                                      productRanges: ranges))
        let response: CheckOnePlanResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        if let dto = response.dto, let status = response.statusCode {
            bsanDataProvider.store(identifier: identifier, customerContractListDTO: dto, httpCode: status)
        }
        return BSANOkResponse(meta, response.dto)
    }
    
    private func lastCallWasSuccess(httpCode: Int) -> Bool {
        return (httpCode == 200 || httpCode == 204)
    }
}
