import SANLegacyLibrary
import CoreDomain

public class BSANPensionsManagerImplementation: BSANBaseManager, BSANPensionsManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getPensionTransactions(forPension pension: PensionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<PensionTransactionsListDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let dateFilterToUse: DateFilter
        if let dateFilter = dateFilter {
            dateFilterToUse = dateFilter
        } else {
            dateFilterToUse = generateDateFilter()
        }
        guard var contractString = pension.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed pension contract")
        }
        contractString += dateFilterToUse.string

        let pensionTransactionList = try bsanDataProvider.get(\.pensionInfo).pensionTransactionsDictionary[contractString]
        
        if let loanTransactionList = pensionTransactionList {
            if pagination != nil {
                if loanTransactionList.pagination.endList {
                    return BSANOkResponse(loanTransactionList)
                }
            } else {
                return BSANOkResponse(loanTransactionList)
            }
        }
        
        let request = PensionTransactionsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            PensionTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             bankCode: pension.contract?.bankCode ?? "",
                                             branchCode: pension.contract?.branchCode ?? "",
                                             product: pension.contract?.product ?? "",
                                             contractNumber: pension.contract?.contractNumber ?? "",
                                             pagination: pagination,
                                             currencyType: pension.valueAmount?.currency?.currencyType,
                                             dateFilter: dateFilterToUse))
        
        let response: PensionTransactionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(pensionTransactionsList: response.pensionTransactions, forPensionId: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.pensionTransactions)
        }
        return BSANErrorResponse(meta);
    }
    
    public func getPensionDetail(forPension pension: PensionDTO) throws -> BSANResponse<PensionDetailDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contractString = pension.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed loan contract")
        }
        
        let pensionDetailDTO = try bsanDataProvider.get(\.pensionInfo).pensionDetailDictionary[contractString]
        
        if pensionDetailDTO != nil {
            return BSANOkResponse(pensionDetailDTO)
        }
        
        let request = GetPensionDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetPensionDetailRequestParams(token: authCredentials.soapTokenCredential,
                                          version: bsanHeaderData.version,
                                          terminalId: bsanHeaderData.terminalID,
                                          userDataDTO: userDataDTO,
                                          bankCode: pension.contract?.bankCode ?? "",
                                          branchCode: pension.contract?.branchCode ?? "",
                                          product: pension.contract?.product ?? "",
                                          contractNumber: pension.contract?.contractNumber ?? "",
                                          language: bsanHeaderData.language))
        
        let response: GetPensionDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(pensionDetail: response.pensionDetailDTO, forPension: pension)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.pensionInfo).pensionDetailDictionary[contractString]);
        }
        return BSANErrorResponse(meta);
    }
    
    public func getPensionContributions(pensionDTO: PensionDTO, pagination: PaginationDTO?) throws -> BSANResponse<PensionContributionsListDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionOperationsAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        guard let pensionContract = pensionDTO.contract?.formattedValue else {
            return BSANErrorResponse(nil)
        }
        
        let pensionContributionsListDTO = try bsanDataProvider.get(\.pensionInfo).pensionContributionsDictionary[pensionContract]
        var pagination = pagination
        
        if let pensionContributionsListDTO = pensionContributionsListDTO {
            if pagination == nil {
                return BSANOkResponse(pensionContributionsListDTO)
            }
            pagination = pensionContributionsListDTO.pagination
            
            if let pagination = pensionContributionsListDTO.pagination, pagination.endList {
                return BSANOkResponse(pensionContributionsListDTO)
            }
        }
        
        let request = GetPensionContributionsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetPensionContributionsRequestParams(token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                bankCode: pensionDTO.contract?.bankCode ?? "",
                branchCode: pensionDTO.contract?.branchCode ?? "",
                product: pensionDTO.contract?.product ?? "",
                contractNumber: pensionDTO.contract?.contractNumber ?? "",
                pagination: pagination))
        
        let response: GetPensionContributionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(pensionContributionsListDTO: response.pensionContributionsListDTO, withContract: pensionContract)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.pensionInfo).pensionContributionsDictionary[pensionContract])
        }
        return BSANErrorResponse(meta)
    }
    
    public func getAllPensionContributions(pensionDTO: PensionDTO) throws -> BSANResponse<PensionContributionsListDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionOperationsAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        guard let pensionContract = pensionDTO.contract?.formattedValue else {
            return BSANErrorResponse(nil)
        }
        
        let pensionContributionsListDTO = try bsanDataProvider.get(\.pensionInfo).pensionContributionsDictionary[pensionContract]
        var pagination: PaginationDTO? = nil
        
        if let pensionContributionsListDTO = pensionContributionsListDTO {
            return BSANOkResponse(pensionContributionsListDTO)
        }
        
        var output = [PensionContributionsDTO]()
        var lastResponse: GetPensionContributionsResponse? = nil
        var lastRequest: GetPensionContributionsRequest? = nil

        for _ in 0 ... 24 {
            let request = GetPensionContributionsRequest(
                bsanAssemble,
                bsanEnvironment.urlBase,
                GetPensionContributionsRequestParams(token: authCredentials.soapTokenCredential,
                                                     userDataDTO: userDataDTO,
                                                     bankCode: pensionDTO.contract?.bankCode ?? "",
                                                     branchCode: pensionDTO.contract?.branchCode ?? "",
                                                     product: pensionDTO.contract?.product ?? "",
                                                     contractNumber: pensionDTO.contract?.contractNumber ?? "",
                                                     pagination: pagination))
            lastRequest = request
            lastResponse = try sanSoapServices.executeCall(request)
            if let newPensionContributions = lastResponse?.pensionContributionsListDTO.pensionContributions {
                output.append(contentsOf: newPensionContributions)
            }
            
            if let lastResponse = lastResponse {
                pagination = lastResponse.pensionContributionsListDTO.pagination
                if let lastPagination = lastResponse.pensionContributionsListDTO.pagination {
                    if lastPagination.endList {
                        break
                    }
                }
            }
        }
        
        guard let outputResponse = lastResponse, let outputRequest = lastRequest else {
            let errorMeta = Meta.createKO()
            return BSANErrorResponse(errorMeta)
        }
        
        outputResponse.pensionContributionsListDTO.pensionContributions = output
        
        let meta = try Meta.createMeta(outputRequest, outputResponse)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(pensionContributionsListDTO: outputResponse.pensionContributionsListDTO, withContract: pensionContract)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.pensionInfo).pensionContributionsDictionary[pensionContract])
        }
        return BSANErrorResponse(meta)
    }
    
    public func getClausesPensionMifid(pensionDTO: PensionDTO, pensionInfoOperationDTO: PensionInfoOperationDTO, amountDTO: AmountDTO) throws -> BSANResponse<PensionMifidDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionOperationsAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        let request = GetClausesPensionMifidRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetClausesPensionMifidRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                bankCode: pensionDTO.contract?.bankCode ?? "",
                                                branchCode: pensionDTO.contract?.branchCode ?? "",
                                                product: pensionDTO.contract?.product ?? "",
                                                contractNumber: pensionDTO.contract?.contractNumber ?? "",
                                                amountValue: AmountFormats.getValueForWS(value: amountDTO.value),
                                                currency: amountDTO.currency?.currencyName ?? "",
                                                productType: pensionInfoOperationDTO.pensionProduct?.productType ?? "",
                                                productSubtype: pensionInfoOperationDTO.pensionProduct?.productSubtype ?? "",
                                                holder: pensionInfoOperationDTO.holder ?? ""))
        
        let response: GetClausesPensionMifidResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.pensionMifidDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmExtraordinaryContribution(pensionDTO: PensionDTO, amountDTO: AmountDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void>  {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionOperationsAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        let request = ConfirmExtraordinaryContributionRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmExtraordinaryContributionRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                bankCode: pensionDTO.contract?.bankCode ?? "",
                branchCode: pensionDTO.contract?.branchCode ?? "",
                product: pensionDTO.contract?.product ?? "",
                contractNumber: pensionDTO.contract?.contractNumber ?? "",
                amountValue: AmountFormats.getValueForWS(value: amountDTO.value),
                currency: amountDTO.currency?.currencyName ?? "",
                tokenPasos: signatureWithTokenDTO.magicPhrase ?? "",
                signatureDTO: signatureWithTokenDTO.signatureDTO ?? SignatureDTO()))
        
        let response: BSANSoapResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkEmptyResponse()
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmPeriodicalContribution(pensionDTO: PensionDTO, pensionContributionInput: PensionContributionInput, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPensionOperationsAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        let request = ConfirmPeriodicalContributionRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmPeriodicalContributionRequestParams(token: authCredentials.soapTokenCredential,
                                                       userDataDTO: userDataDTO,
                                                       bankCode: pensionDTO.contract?.bankCode ?? "",
                                                       branchCode: pensionDTO.contract?.branchCode ?? "",
                                                       product: pensionDTO.contract?.product ?? "",
                                                       contractNumber: pensionDTO.contract?.contractNumber ?? "",
                                                       amountValue: AmountFormats.getValueForWS(value: pensionContributionInput.amountDTO.value),
                                                       currency: pensionContributionInput.amountDTO.currency?.currencyName ?? "",
                                                       tokenPasos: signatureWithTokenDTO.magicPhrase ?? "",
                                                       signatureDTO: signatureWithTokenDTO.signatureDTO ?? SignatureDTO(),
                                                       startDate: pensionContributionInput.startDate,
                                                       frequencyQuota: pensionContributionInput.periodicyType.getFrequencyQuota(),
                                                       quotaUnitTime: pensionContributionInput.periodicyType.getUnitTime(),
                                                       percentage: pensionContributionInput.percentage,
                                                       indexRevaluesPension: pensionContributionInput.revaluationType.getIndexRevaluesPension(),
                                                       typeRevaluesPension: pensionContributionInput.revaluationType.getTypeRevaluesPension()))
        
        let response: BSANSoapResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkEmptyResponse()
        }
        return BSANErrorResponse(meta)
    }
    
    public func changePensionAlias(_ pension: PensionDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANErrorResponse(nil)
    }
}
