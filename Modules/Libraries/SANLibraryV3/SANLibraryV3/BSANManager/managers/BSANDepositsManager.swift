import SANLegacyLibrary
import CoreDomain

public class BSANDepositsManagerImplementation: BSANBaseManager, BSANDepositsManager {

    var sanSoapServices: SanSoapServices

    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func getDepositImpositionsTransactions(depositDTO: DepositDTO, pagination: PaginationDTO?) throws -> BSANResponse<ImpositionsListDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let depositContract = depositDTO.contract?.formattedValue

        if let depositImpositionsTransactions = try bsanDataProvider.get(\.depositInfo).depositImpositionsTransactionsDictionary[depositContract ?? ""] {
            // Stored data
            if pagination == nil {
                //show the first page
                return BSANOkResponse(depositImpositionsTransactions)
            }
            if let pagination = depositImpositionsTransactions.pagination {
                if pagination.endList {
                    return BSANOkResponse(depositImpositionsTransactions)
                }
            }
        }

        let request = DepositImpositionRequest(
                BSANAssembleProvider.getDepositAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                DepositImpositionsRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        terminalId: bsanHeaderData.terminalID,
                        version: bsanHeaderData.version,
                        language: bsanHeaderData.language,
                        bankCode: depositDTO.contract?.bankCode ?? "",
                        branchCode: depositDTO.contract?.branchCode ?? "",
                        product: depositDTO.contract?.product ?? "",
                        contractNumber: depositDTO.contract?.contractNumber ?? "",
                        pagination: pagination))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            let responseList = response.impositionsDTOList
            bsanDataProvider.store(impositionList: responseList, forDeposit: depositDTO)
            return BSANOkResponse(meta, response.impositionsDTOList)
        }
        return BSANErrorResponse(meta)
    }

    public func getImpositionTransactions(impositionDTO: ImpositionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<ImpositionTransactionsListDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let dateFilter = dateFilter ?? generateDateFilter()
        let depositContract = impositionDTO.getLocalIdentifier() + dateFilter.string

        if let impositionsTransactions = try bsanDataProvider.get(\.depositInfo).impositionsTransactionsDictionary[depositContract] {
            // Stored data
            if pagination == nil {
                //show the first page
                return BSANOkResponse(impositionsTransactions)
            }
            if let pagination = impositionsTransactions.pagination {
                if pagination.endList {
                    return BSANOkResponse(impositionsTransactions)
                }
            }
        }

        let request = GetImpositionTransactionsRequest(
                BSANAssembleProvider.getDepositAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetImpositionTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        bankCode: impositionDTO.impositionSubContract?.contract?.bankCode ?? "",
                        branchCode: impositionDTO.impositionSubContract?.contract?.branchCode ?? "",
                        product: impositionDTO.impositionSubContract?.contract?.product ?? "",
                        contractNumber: impositionDTO.impositionSubContract?.contract?.contractNumber ?? "",
                        language: bsanHeaderData.language,
                        subContractString: impositionDTO.impositionSubContract?.subcontractString ?? "",
                        value: impositionDTO.settlementAmount?.value,
                        currency: impositionDTO.settlementAmount?.currency?.currencyName ?? "",
                        dateFilter: dateFilter,
                        pagination: pagination))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            let responseList = response.impositionTransactionsListDTO
            bsanDataProvider.store(impositionTransactionsList: responseList, impositionContract: depositContract)
            return BSANOkResponse(meta, responseList)
        }
        return BSANErrorResponse(meta)
    }

    public func getImpositionLiquidations(impositionDTO: ImpositionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<LiquidationTransactionListDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let dateFilter = dateFilter ?? generateDateFilter()
        let depositContract = impositionDTO.getLocalIdentifier() + dateFilter.string

        if let impositionsLiquidations = try bsanDataProvider.get(\.depositInfo).impositionsLiquidationsDictionary[depositContract] {
            // Stored data
            if pagination == nil {
                //show the first page
                return BSANOkResponse(impositionsLiquidations)
            }
            if let pagination = impositionsLiquidations.pagination {
                if pagination.endList {
                    return BSANOkResponse(impositionsLiquidations)
                }
            }
        }

        let request = ImpositionLiquidationsRequest(
                BSANAssembleProvider.getDepositAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                ImpositionLiquidationsRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        terminalId: bsanHeaderData.terminalID,
                        version: bsanHeaderData.version,
                        language: bsanHeaderData.language,
                        subContractString: impositionDTO.impositionSubContract?.subcontractString ?? "",
                        currency: impositionDTO.settlementAmount?.currency?.currencyName ?? "",
                        bankCode: impositionDTO.impositionSubContract?.contract?.bankCode ?? "",
                        branchCode: impositionDTO.impositionSubContract?.contract?.branchCode ?? "",
                        product: impositionDTO.impositionSubContract?.contract?.product ?? "",
                        contractNumber: impositionDTO.impositionSubContract?.contract?.contractNumber ?? "",
                        dateFilter: dateFilter,
                        pagination: pagination))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            let responseList = response.liquidationTransactionListDTO
            bsanDataProvider.store(impositionLiquidationTransactionsList: responseList, impositionContract: depositContract)
            return BSANOkResponse(meta, responseList)
        }
        return BSANErrorResponse(meta)
    }

    public func getLiquidationDetail(impositionDTO: ImpositionDTO, liquidationDTO: LiquidationDTO) throws -> BSANResponse<LiquidationDetailDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let depositContract = impositionDTO.getLocalIdentifier()

        if let liquidationDetail = try bsanDataProvider.get(\.depositInfo).liquidationDetailsDictionary[depositContract] {
            return BSANOkResponse(liquidationDetail)
        }

        let request = GetLiquidationDetailRequest(
                BSANAssembleProvider.getDepositAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetLiquidationDetailRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        bankCode: impositionDTO.impositionSubContract?.contract?.bankCode ?? "",
                        branchCode: impositionDTO.impositionSubContract?.contract?.branchCode ?? "",
                        product: impositionDTO.impositionSubContract?.contract?.product ?? "",
                        contractNumber: impositionDTO.impositionSubContract?.contract?.contractNumber ?? "",
                        language: bsanHeaderData.language,
                        validityClosingDate: liquidationDTO.validityClosingDate,
                        subcontractString: impositionDTO.impositionSubContract?.subcontractString ?? "",
                        settlementValue: liquidationDTO.settlementAmount?.value,
                        currencySettlement: liquidationDTO.settlementAmount?.currency?.currencyName ?? ""))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            let liquidationDetailDTO = response.liquidationDetailDTO
            bsanDataProvider.store(liquidationDetail: liquidationDetailDTO, contract: depositContract)
            return BSANOkResponse(meta, liquidationDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func changeDepositAlias(_ deposit: DepositDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANErrorResponse(nil)
    }
}
