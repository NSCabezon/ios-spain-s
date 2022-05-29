import SANLegacyLibrary

public class BSANMifidManagerImplementation: BSANBaseManager, BSANMifidManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getMifidIndicator(contractDTO: ContractDTO) throws -> BSANResponse<MifidIndicatorDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMifidAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetMifidIndicatorRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetMifidIndicatorRequestParams(token: authCredentials.soapTokenCredential,
                                           contractDTO: contractDTO,
                                           userDataDTO: userDataDTO,
                                           languageISO: bsanHeaderData.languageISO,
                                           dialectISO: bsanHeaderData.dialectISO))
        
        let response: GetMifidIndicatorResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.mifidIndicatorDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getMifidClauses(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, tradedSharesCount: String, transferMode: String) throws -> BSANResponse<MifidDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMifidAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contract = stockAccountDTO.contract else {
            throw BSANException("StockAccountDTO contract is nil")
        }
        
        let request = GetMifidClausesRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetMifidClausesRequestParams(token: authCredentials.soapTokenCredential,
                                         contractDTO: contract,
                                         userDataDTO: userDataDTO,
                                         sharesCount: tradedSharesCount,
                                         stockCode: stockQuoteDTO.stockCode ?? "",
                                         identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                         option: transferMode,
                                         languageISO: bsanHeaderData.languageISO,
                                         dialectISO: bsanHeaderData.dialectISO))
        
        let response: GetMifidClausesResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.mifidDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getCounterValueDetail(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO) throws -> BSANResponse<RMVDetailDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMifidAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contract = stockAccountDTO.contract else {
            throw BSANException("StockAccountDTO contract is nil")
        }
        
        let request = GetCounterValueDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetCounterValueDetailRequestParams(token: authCredentials.soapTokenCredential,
                                               contractDTO: contract,
                                               userDataDTO: userDataDTO,
                                               stockCode: stockQuoteDTO.stockCode ?? "",
                                               identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                               languageISO: bsanHeaderData.languageISO,
                                               dialectISO: bsanHeaderData.dialectISO))
        
        let response: GetCounterValueDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.rmvDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
}
