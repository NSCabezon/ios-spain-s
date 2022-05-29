import CoreDomain
import Foundation
import SANLegacyLibrary

public class BSANPortfoliosPBManagerImplementation: BSANBaseManager, BSANPortfoliosPBManager {
    
    var bsanAssemble: BSANAssemble?
    var bsanEnvironment: BSANEnvironmentDTO?
    
    var userDataDTO : UserDataDTO?
    var authCredentials : AuthCredentials?
    var bsanHeaderData : BSANHeaderData?
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    private func initManager() throws{
        bsanAssemble = BSANAssembleProvider.getPortfoliosAssemble()
        bsanEnvironment = try bsanDataProvider.getEnvironment()
        userDataDTO = try bsanDataProvider.getUserData()
        authCredentials = try bsanDataProvider.getAuthCredentials()
        bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        if bsanAssemble == nil ||
            bsanEnvironment == nil ||
            userDataDTO == nil ||
            authCredentials == nil ||
            bsanHeaderData == nil{
            throw BSANIllegalStateException("MANAGER NOT INITIALIZED - \(#function)")
        }
    }
    
    public func getPortfoliosNotManaged() throws -> BSANResponse<[PortfolioDTO]> {
        let portfolioPBDTOs = try bsanDataProvider.get(\.portfolioInfo).portfolioNotManagedList
        return BSANOkResponse(portfolioPBDTOs)
    }
    
    public func getPortfoliosManaged() throws -> BSANResponse<[PortfolioDTO]> {
        let portfolioPBDTOs = try bsanDataProvider.get(\.portfolioInfo).portfolioManagedList
        return BSANOkResponse(portfolioPBDTOs)
    }
    
    public func getRVPortfoliosNotManaged() throws -> BSANResponse<[PortfolioDTO]> {
        let portfolioPBDTOs = try bsanDataProvider.get(\.portfolioInfo).portfolioRVNotManagedList
        return BSANOkResponse(portfolioPBDTOs)
    }
    
    public func getRVPortfoliosManaged() throws -> BSANResponse<[PortfolioDTO]> {
        let portfolioPBDTOs = try bsanDataProvider.get(\.portfolioInfo).portfolioRVManagedList
        return BSANOkResponse(portfolioPBDTOs)
    }
    
    public func getRVManagedStockAccountList() throws -> BSANResponse<[StockAccountDTO]> {
       let accountList = try bsanDataProvider.get(\.portfolioInfo).getRVManagedStockAccountList()
        return BSANOkResponse(accountList)
    }
    
    public func getRVNotManagedStockAccountList() throws -> BSANResponse<[StockAccountDTO]> {
        let accountList = try bsanDataProvider.get(\.portfolioInfo).getRVNotManagedStockAccountList()
        return BSANOkResponse(accountList)
    }
    
    private func getGetVariableIncomePortfoliosRequest() throws -> GetVariableIncomePortfoliosRequest {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDto = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        return GetVariableIncomePortfoliosRequest(
            BSANAssembleProvider.getPortfoliosAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetVariableIncomePortfoliosRequestParams.createParams(authCredentials.soapTokenCredential)
                .setLanguageISO(bsanHeaderData.languageISO)
                .setTerminalId(bsanHeaderData.terminalID)
                .setVersion(bsanHeaderData.version)
                .setDialectISO(bsanHeaderData.dialectISO)
                .setUserDataDTO(userDataDto))
    }
    
    private func getRequestPortfolio() throws -> GetPortfoliosRequest {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        return GetPortfoliosRequest(
            BSANAssembleProvider.getPortfoliosAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetPortfoliosRequestParams.createParams(authCredentials.soapTokenCredential)
                .setLanguageISO(bsanHeaderData.languageISO)
                .setTerminalId(bsanHeaderData.terminalID)
                .setVersion(bsanHeaderData.version)
                .setDialectISO(bsanHeaderData.dialectISO)
                .setUserDataDTO(userDataDTO))
    }
    
    public func loadPortfoliosPb() throws -> BSANResponse<Void> {
        let request = try getRequestPortfolio()
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            if let portfolios = response.portfolioPBDTOs {
                try storePortfolios(portfolios, userTypePortfolio: .portfolioPb)
                return BSANOkResponse(meta)
            }
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadPortfoliosSelect() throws -> BSANResponse<Void> {
        let request = try getRequestPortfolio()
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            if let portfolios = response.portfolioPBDTOs {
                try storePortfolios(portfolios, userTypePortfolio: .portfolioSelect)
                return BSANOkResponse(meta)
            }
        }
        return BSANErrorResponse(meta)
    }
    
    private func storePortfolios(_ portfolioPBDTOs: [PortfolioDTO], userTypePortfolio: UserTypePortfolio) throws {
        var portfoliosManagedList: [PortfolioDTO] = []
        var portfoliosNotManagedList: [PortfolioDTO] = []
        for portfolioPBDTO in portfolioPBDTOs {
            if "A" == portfolioPBDTO.portfolioTypeInd {
                portfoliosManagedList.append(portfolioPBDTO)
            } else {
                portfoliosNotManagedList.append(portfolioPBDTO)
            }
        }
        if userTypePortfolio == .portfolioSelect {
            bsanDataProvider.storePortfoliosSelect(portfoliosManagedList: portfoliosManagedList)
        } else {
            bsanDataProvider.storePortfoliosPb(portfoliosManagedList: portfoliosManagedList, portfoliosNotManagedList: portfoliosNotManagedList)
        }
        
        try GlobalPositionPorfolioMerger(bsanDataProvider: bsanDataProvider)
    }
    
    public func resetPortfolios() {
        bsanDataProvider.resetPortfolios()
    }
    
    private func classifyPortfolios(list: [PortfolioDTO], managed: PortfolioDTO, notManaged: PortfolioDTO) {
        
    }
    
    public func loadVariableIncomePortfolioPb() throws -> BSANResponse<Void> {
        let request = try getGetVariableIncomePortfoliosRequest()
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            if let portfolios = response.portfolioPBDTOs {
                try storeVariableIncomePortfolios(portfolios, userTypePortfolio: .portfolioPb)
                return BSANOkResponse(meta)
            }
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadVariableIncomePortfolioSelect() throws -> BSANResponse<Void> {
        let request = try getGetVariableIncomePortfoliosRequest()
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            if let portfolios = response.portfolioPBDTOs {
                try storeVariableIncomePortfolios(portfolios, userTypePortfolio: .portfolioSelect)
                return BSANOkResponse(meta)
            }
        }
        return BSANErrorResponse(meta)
    }
    
    private func storeVariableIncomePortfolios(_ portfolioPBDTOs: [PortfolioDTO], userTypePortfolio: UserTypePortfolio) throws {
        
        var portfolioRVManagedList: [PortfolioDTO] = []
        var portfolioRVManagedStockAccountList: [StockAccountDTO] = []
        var portfolioRVNotManagedList: [PortfolioDTO] = []
        var portfolioRVNotManagedStockAccountList: [StockAccountDTO] = []
        
        for portfolioPBDTO in portfolioPBDTOs {
            if let _ = portfolioPBDTO.stockAccountData {
                if "A" == portfolioPBDTO.portfolioTypeInd {
                    portfolioRVManagedList.append(portfolioPBDTO)
                    portfolioRVManagedStockAccountList.append(getStockAccountFromPortfolioRV(portfolioPBDTO, type: .RVManaged))
                } else {
                    portfolioRVNotManagedList.append(portfolioPBDTO)
                    portfolioRVNotManagedStockAccountList.append(getStockAccountFromPortfolioRV(portfolioPBDTO, type: .RVNotManaged))
                }
            }
        }
        
        if userTypePortfolio == .portfolioSelect {
            bsanDataProvider.storeVariableIncomePortfoliosSelect(portfolioRVManagedList: portfolioRVManagedList, portfolioRVManagedStockAccountList: portfolioRVManagedStockAccountList)
        } else {
            bsanDataProvider.storeVariableIncomePortfoliosPb(portfolioRVManagedList: portfolioRVManagedList, portfolioRVManagedStockAccountList: portfolioRVManagedStockAccountList, portfolioRVNotManagedList: portfolioRVNotManagedList, portfolioRVNotManagedStockAccountList: portfolioRVNotManagedStockAccountList)
        }
        
        try GlobalPositionPorfolioMerger(bsanDataProvider: bsanDataProvider)

    }
    
    private func getStockAccountFromPortfolioRV(_ portfolioPBDTO: PortfolioDTO, type: StockAccountType) -> StockAccountDTO {
        var stockAccountDTO = StockAccountDTO()
        stockAccountDTO.contractDescription = portfolioPBDTO.portfolioId
        stockAccountDTO.contract = portfolioPBDTO.stockAccountData?.contract
        stockAccountDTO.ownershipTypeDesc = portfolioPBDTO.ownershipTypeDesc
        stockAccountDTO.valueAmount = portfolioPBDTO.consolidatedBalance
        stockAccountDTO.alias = portfolioPBDTO.alias
        stockAccountDTO.stockAccountType = type
        return stockAccountDTO
    }
    
    @discardableResult
    public func deletePortfoliosProducts() throws -> BSANResponse<Void> {
        bsanDataProvider.deletePortfoliosProducts()
        return BSANOkResponse(Meta.createOk())
    }
    
    public func getPortfolioProducts(portfolioPBDTO: PortfolioDTO) throws -> BSANResponse<[PortfolioProductDTO]> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let userDataDTO = userDataDTO, let authCredentials = authCredentials, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        
        guard let contractString = portfolioPBDTO.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed portfolio contract")
        }
        
        let portfolioProductsList = try bsanDataProvider.get(\.portfolioInfo).portfolioProductsList[contractString]
        
        if let portfolioProductsList = portfolioProductsList {
            return BSANOkResponse(portfolioProductsList)
        }
        
        let request = GetPortfolioProductsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetPortfolioProductsRequestParams(token: authCredentials.soapTokenCredential,
                                       userDataDTO: userDataDTO,
                                       terminalId: bsanHeaderData.terminalID,
                                       version: bsanHeaderData.version,
                                       languageISO: bsanHeaderData.languageISO,
                                       dialectISO: bsanHeaderData.dialectISO,
                                       portfolioId: portfolioPBDTO.portfolioId ?? "",
                                       portfolioTypeInd: portfolioPBDTO.portfolioTypeInd ?? ""))
        
        let response: GetPortfolioProductsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Return last page only (In Android they return all everytime)
            bsanDataProvider.storePortfolioProductsList(portfolioProductPBDTOS: response.portfolioProductPBDTOs, contractId: contractString)
            return BSANOkResponse(meta, response.portfolioProductPBDTOs)
        }
        return BSANErrorResponse(meta);
    }
    
    public func getHolderDetail(portfolioPBDTO: PortfolioDTO) throws -> BSANResponse<[HolderDTO]> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        guard let userDataDTO = userDataDTO, let authCredentials = authCredentials, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        
        let request = GetHolderDetailRequest(
            BSANAssembleProvider.getPortfoliosAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetHolderDetailRequestParams(token: authCredentials.soapTokenCredential,
                                              userDataDTO: userDataDTO,
                                              terminalId: bsanHeaderData.terminalID,
                                              version: bsanHeaderData.version,
                                              languageISO: bsanHeaderData.languageISO,
                                              dialectISO: bsanHeaderData.dialectISO,
                                              portfolioId: portfolioPBDTO.portfolioId ?? "",
                                              portfolioTypeInd: portfolioPBDTO.portfolioTypeInd ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.holders)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getPortfolioProductTransactionDetail(transactionDTO: PortfolioTransactionDTO) throws -> BSANResponse<PortfolioTransactionDetailDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        guard let userDataDTO = userDataDTO, let authCredentials = authCredentials, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = GetProductTransactionDetailRequest(
            BSANAssembleProvider.getPortfoliosAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetProductTransactionDetailRequestParams(token: authCredentials.soapTokenCredential,
                                         userDataDTO: userDataDTO,
                                         terminalId: bsanHeaderData.terminalID,
                                         version: bsanHeaderData.version,
                                         languageISO: bsanHeaderData.languageISO,
                                         dialectISO: bsanHeaderData.dialectISO,
                                         transactionNumber: transactionDTO.transactionNumber ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.portfolioTransactionDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getPortfolioProductTransactions(portfolioProductPBDTO: PortfolioProductDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<PortfolioTransactionsListDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }

        let dateFilterToUse = dateFilter ?? DateFilter.getDateFilterFor(numberOfYears: -1)

        guard var contractString = portfolioProductPBDTO.valueName else {
            throw BSANIllegalStateException("Malformed fund contract")
        }

        contractString += dateFilterToUse.string
        let portfolioTransactionsListDTO = try bsanDataProvider.get(\.portfolioInfo).portfolioProductTransacions[contractString]
        
        if let portfolioTransactionsListDTO = portfolioTransactionsListDTO {
            if pagination != nil {
                if let portfolioTransactionListPagination = portfolioTransactionsListDTO.pagination{
                    if portfolioTransactionListPagination.endList {
                        return BSANOkResponse(portfolioTransactionsListDTO)
                    }
                }
            } else {
                return BSANOkResponse(portfolioTransactionsListDTO)
            }
        }
        guard let userDataDTO = userDataDTO, let authCredentials = authCredentials, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        
        let request = GetPortfolioTransactionsRequest(
            BSANAssembleProvider.getPortfoliosAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetPortfolioTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                         userDataDTO: userDataDTO,
                                         terminalId: bsanHeaderData.terminalID,
                                         version: bsanHeaderData.version,
                                         languageISO: bsanHeaderData.languageISO,
                                         dialectISO: bsanHeaderData.dialectISO,
                                         portfolioId: portfolioProductPBDTO.portfolioId ?? "",
                                         portfolioValueName: portfolioProductPBDTO.valueName ?? "",
                                         portfolioActiveType: portfolioProductPBDTO.activeType ?? "",
                                         dateFilter: dateFilterToUse,
                                         pagination: pagination ?? getDefaultPagination()))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            
            bsanDataProvider.storePortfolioProductTransactionsList(portfolioProductTransaction: response.transactionList, contractId: contractString)
            return BSANOkResponse(meta, response.transactionList)
        }
        return BSANErrorResponse(meta)
    }
    
    private func getDefaultPagination() -> PaginationDTO{
        var pagination = PaginationDTO()
        pagination.repositionXML = "<repos><clavePaginacion/><indRepos>N</indRepos></repos>"
        pagination.endList = false
        
        return pagination
    }
}
