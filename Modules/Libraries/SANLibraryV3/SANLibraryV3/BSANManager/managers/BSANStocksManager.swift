import SANLegacyLibrary
import CoreDomain

public class BSANStocksManagerImplementation: BSANBaseManager, BSANStocksManager {
    
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
        bsanAssemble = BSANAssembleProvider.getStockAssemble()
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
    
    public func getStocks(stockAccountDTO: StockAccountDTO, pagination: PaginationDTO?) throws -> BSANResponse<StockListDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        guard let contractString = stockAccountDTO.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed stock contract")
        }
        
        let stockList = try bsanDataProvider.get(\.stockInfo).stockListDictionary[contractString]
        
        if let stockList = stockList {
            if pagination != nil {
                if stockList.pagination?.endList == true {
                    return BSANOkResponse(stockList)
                }
            } else {
                return BSANOkResponse(stockList)
            }
        }
        
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        
        let request = GetStockCCVRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetStockCCVRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             contract: stockAccountDTO.contract,
                                             pagination: pagination))
        
        let response: GetStockCCVResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(stockList: response.stockListDTO, stockContract: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.stockListDTO)
        }
        return BSANErrorResponse(meta);
    }
    
    public func getAllStocks(stockAccountDTO: StockAccountDTO) throws -> BSANResponse<StockListDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        guard let contractString = stockAccountDTO.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed stock contract")
        }
        
        let stockList = try bsanDataProvider.get(\.stockInfo).stockListDictionary[contractString]
        
        if let stockList = stockList {
            return BSANOkResponse(stockList)
        }
        
        var pagination: PaginationDTO? = nil
        var notIsEnd = true
        var transactions: [StockDTO] = []
        var response: BSANResponse<StockListDTO>?
        repeat {
            response = try self.getStocks(stockAccountDTO: stockAccountDTO, pagination: pagination)
            if response?.isSuccess() == true, let data = try response?.getResponseData() {
                if let nextPagination = data.pagination {
                    notIsEnd = !nextPagination.endList
                } else {
                    notIsEnd = false
                }
                pagination = data.pagination
                if let list = data.stockListDTO {
                    transactions.append(contentsOf: list)
                }
            } else {
                return BSANErrorResponse(Meta.createKO(try response?.getErrorMessage() ?? ""))
            }
        } while notIsEnd
        
        let outputStockList = StockListDTO(stockListDTO: transactions, pagination: nil, positionAmount: nil)
        bsanDataProvider.store(stockList: outputStockList, stockContract: contractString)
        return BSANOkResponse(Meta.createOk(), outputStockList)
    }
    
    public func getStocksQuotes(searchString: String, pagination: PaginationDTO?) throws -> BSANResponse<StockQuotesListDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = GetStockQuotesRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetStockQuotesRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             searchString: searchString.uppercased(),
                                             pagination: pagination))
        
        let response: GetStockQuotesResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.stockQuotesListDTO)
        }
        return BSANErrorResponse(meta);
    }
    
    public func getQuoteDetail(stockQuoteDTO: StockQuoteDTO) throws -> BSANResponse<StockQuoteDetailDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        guard let contractString = stockQuoteDTO.getLocalId() else {
            throw BSANIllegalStateException("Malformed stock contract")
        }
        
        if try bsanDataProvider.get(\.stockInfo).stockQuoteDetailDictionary.contains(where: {$0.key == contractString}) {
            let returnedDetail = try bsanDataProvider.get(\.stockInfo).stockQuoteDetailDictionary[contractString]
            return BSANOkResponse(returnedDetail)
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = GetStockQuoteDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetStockQuoteDetailRequestParams(token: authCredentials.soapTokenCredential,
                                     userDataDTO: userDataDTO,
                                     version: bsanHeaderData.version,
                                     terminalId: bsanHeaderData.terminalID,
                                     language: bsanHeaderData.language,
                                     stockCode: stockQuoteDTO.stockCode ?? "",
                                     identificationNumber: stockQuoteDTO.identificationNumber ?? ""))
        
        let response: GetStockQuoteDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(stockQuoteDetail: response.stockQuoteDetailDTO, stockContract: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.stockQuoteDetailDTO)
        }
        bsanDataProvider.store(stockQuoteDetail: nil, stockContract: contractString)
        return BSANErrorResponse(meta);
    }
    
    /**
     * Servicio para testear
     */
    public func getOrdenes(stockAccountDTO: StockAccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<OrderListDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        guard let contract = stockAccountDTO.contract?.formattedValue, let dateFilterString = dateFilter?.string else {
            throw BSANIllegalStateException("Unknown contract number")
        }
        
        let contractId = contract + dateFilterString
        
        let orderList = try bsanDataProvider.get(\.stockInfo).stockOrdersListDictionary[contractId]
        if let orderList = orderList {
            guard let pagination = pagination else {
                return BSANOkResponse(orderList)
            }
            
            if pagination.endList {
                return BSANOkResponse(OrderListDTO(orders: [], pagination: pagination))
            }
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = GetStockOrderRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetStockOrderRequestParams(token: authCredentials.soapTokenCredential,
                                        userDataDTO: userDataDTO,
                                        terminalId: bsanHeaderData.terminalID,
                                        version: bsanHeaderData.version,
                                        language: bsanHeaderData.language,
                                        stockContract: stockAccountDTO.contract,
                                        pagination: pagination,
                                        dateFilter: dateFilter ?? generateDateFilter()))
        
        let response: GetStockOrderResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Return last page only (In Android they return all everytime)
            bsanDataProvider.store(ordersList: response.orderListDTO, stockContract: contractId)
            return BSANOkResponse(meta, response.orderListDTO)
        }

        return BSANErrorResponse(meta);
    }
    
    public func deleteStockOrders() throws -> BSANResponse<Void> {
        bsanDataProvider.deleteStockOrders()
        return BSANOkEmptyResponse()
    }
    
    /**
     * Servicio para testear
     */
    public func getOrderDetail(order: OrderDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<OrderDetailDTO?> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        guard let stockId = stockAccountDTO.contract?.formattedValue,
            let orderId = order.number else {
            throw BSANIllegalStateException("Unknown contract number")
        }
        
        let contractId = stockId+orderId
        
        if try bsanDataProvider.get(\.stockInfo).stockOrderDetailsDictionary.contains(where: {$0.key == contractId}) {
            let returnedDetail = try bsanDataProvider.get(\.stockInfo).stockOrderDetailsDictionary[contractId]
            return BSANOkResponse(returnedDetail)
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = GetStockOrderDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetStockOrderDetailRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             stockContractDTO: stockAccountDTO.contract,
                                             orderNumber: order.number ?? ""))
        
        let response: GetStockOrderDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Return last page only (In Android they return all everytime)
            bsanDataProvider.store(orderDetail: response.orderDetailDTO, contractId: contractId)
            return BSANOkResponse(meta, response.orderDetailDTO)
        }
        
        bsanDataProvider.store(orderDetail: nil, contractId: contractId)
        return BSANErrorResponse(meta);
    }
    
    public func removeOrderDetail(order: OrderDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<Void> {
        
        guard let stockId = stockAccountDTO.contract?.formattedValue,
            let orderId = order.number else {
                throw BSANIllegalStateException("Unknown contract number")
        }
        let contractId = stockId + orderId
        
        if try bsanDataProvider.get(\.stockInfo).stockOrderDetailsDictionary.contains(where: { $0.key == contractId}) {
            bsanDataProvider.removeStockOrderDetail(for: contractId)
        }
        return BSANOkEmptyResponse()
    }
    
    public func getStocksQuoteIBEXSAN() throws -> BSANResponse<StockQuotesListDTO> {
        
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = GetStockQuoteIBEXSANRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetStockQuoteIBEXSANRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language))
        
        let response: GetStockQuoteIBEXSANResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.stockQuotesListDTO)
        }
        return BSANErrorResponse(meta);
    }
    
    public func setCancellationOrder(orderDTO: OrderDTO, signatureDTO: SignatureDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<Void> {

        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        guard let bsanAssemble = bsanAssemble, let bsanEnvironment = bsanEnvironment, let authCredentials = authCredentials, let userDataDTO = userDataDTO, let bsanHeaderData = bsanHeaderData else {
            return BSANErrorResponse(nil)
        }
        let request = CancellationOrderRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            CancellationOrderRequestParams(token: authCredentials.soapTokenCredential,
                                           userDataDTO: userDataDTO,
                                           terminalId: bsanHeaderData.terminalID,
                                           version: bsanHeaderData.version,
                                           language: bsanHeaderData.language,
                                           bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                           branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                           product: stockAccountDTO.contract?.product ?? "",
                                           contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                           numberOrder: orderDTO.number ?? "",
                                           orderSignature: signatureDTO))

        let response = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta);
    }
    
    public func validateBuyStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()

        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ValidateBuyStockLimitedRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateBuyStockLimitedRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 terminalId: bsanHeaderData.terminalID,
                                                 maxExchange: stockLimitedOperationInput.maxExchange,
                                                 version: bsanHeaderData.version,
                                                 language: bsanHeaderData.language,
                                                 bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                 branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                 product: stockAccountDTO.contract?.product ?? "",
                                                 contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                 stockCode: stockQuoteDTO.stockCode ?? "",
                                                 identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                 tradesShares: stockLimitedOperationInput.tradesShare,
                                                 limitDate: stockLimitedOperationInput.limitedDate))

        let response: ValidateBuyStockLimitedResponse = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockDataBuyDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateBuyStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput)
    throws -> BSANResponse<StockDataBuySellDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateBuyStockTypeOrderRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateBuyStockTypeOrderRequestParams(token: authCredentials.soapTokenCredential,
                                                   stockTradingType: stockTypeOrderOperationInput.stockTradingType,
                                                   userDataDTO: userDataDTO,
                                                   terminalId: bsanHeaderData.terminalID,
                                                   version: bsanHeaderData.version,
                                                   language: bsanHeaderData.language,
                                                   bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                   branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                   product: stockAccountDTO.contract?.product ?? "",
                                                   contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                   stockCode: stockQuoteDTO.stockCode ?? "",
                                                   identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                   tradesShares: stockTypeOrderOperationInput.tradesShare,
                                                   limitDate: stockTypeOrderOperationInput.limitedDate))
        
        let response: ValidateBuyStockTypeOrderResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockDataBuyDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmBuyStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
       
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmBuyStockLimitedRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmBuyStockLimitedRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                maxExchange: stockLimitedOperationInput.maxExchange,
                                                terminalId: bsanHeaderData.terminalID,
                                                version: bsanHeaderData.version,
                                                language: bsanHeaderData.language,
                                                bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                product: stockAccountDTO.contract?.product ?? "",
                                                contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                stockCode: stockQuoteDTO.stockCode ?? "",
                                                identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                tradesShares: stockLimitedOperationInput.tradesShare,
                                                limitDate: stockLimitedOperationInput.limitedDate,
                                                signatureDTO: signatureDTO))
        
        let response: ConfirmBuyStockLimitedResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockOperationDataConfirmDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmBuyStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmBuyStockTypeOrderRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmBuyStockTypeOrderRequestParams(token: authCredentials.soapTokenCredential,
                                                  stockTradingType: stockTypeOrderOperationInput.stockTradingType,
                                                  userDataDTO: userDataDTO,
                                                  terminalId: bsanHeaderData.terminalID,
                                                  version: bsanHeaderData.version,
                                                  language: bsanHeaderData.language,
                                                  bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                  branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                  product: stockAccountDTO.contract?.product ?? "",
                                                  contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                  stockCode: stockQuoteDTO.stockCode ?? "",
                                                  identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                  tradesShares: stockTypeOrderOperationInput.tradesShare,
                                                  limitDate: stockTypeOrderOperationInput.limitedDate,
                                                  signatureDTO: signatureDTO))
        
        let response: ConfirmBuyStockTypeOrderResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockOperationDataConfirmDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateSellStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateSellStockLimitedRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateSellStockLimitedRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  terminalId: bsanHeaderData.terminalID,
                                                  maxExchange: stockLimitedOperationInput.maxExchange,
                                                  version: bsanHeaderData.version,
                                                  language: bsanHeaderData.language,
                                                  bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                  branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                  product: stockAccountDTO.contract?.product ?? "",
                                                  contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                  stockCode: stockQuoteDTO.stockCode ?? "",
                                                  identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                  tradesShares: stockLimitedOperationInput.tradesShare,
                                                  limitDate: stockLimitedOperationInput.limitedDate))
        
        let response: ValidateSellStockLimitedResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockDataSellDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateSellStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateSellStockTypeOrderRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateSellStockTypeOrderRequestParams(token: authCredentials.soapTokenCredential,
                                                    stockTradingType: stockTypeOrderOperationInput.stockTradingType,
                                                    userDataDTO: userDataDTO,
                                                    terminalId: bsanHeaderData.terminalID,
                                                    version: bsanHeaderData.version,
                                                    language: bsanHeaderData.language,
                                                    bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                    branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                    product: stockAccountDTO.contract?.product ?? "",
                                                    contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                    stockCode: stockQuoteDTO.stockCode ?? "",
                                                    identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                    tradesShares: stockTypeOrderOperationInput.tradesShare,
                                                    limitDate: stockTypeOrderOperationInput.limitedDate))
        
        let response: ValidateSellStockTypeOrderResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockDataSellDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmSellStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmSellStockLimitedRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmSellStockLimitedRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 maxExchange: stockLimitedOperationInput.maxExchange,
                                                 terminalId: bsanHeaderData.terminalID,
                                                 version: bsanHeaderData.version,
                                                 language: bsanHeaderData.language,
                                                 bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                 branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                 product: stockAccountDTO.contract?.product ?? "",
                                                 contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                 stockCode: stockQuoteDTO.stockCode ?? "",
                                                 identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                 tradesShares: stockLimitedOperationInput.tradesShare,
                                                 limitDate: stockLimitedOperationInput.limitedDate,
                                                 signatureDTO: signatureDTO))
        
        let response: ConfirmSellStockLimitedResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockOperationDataConfirmDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmSellStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getStockAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmSellStockTypeOrderRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmSellStockTypeOrderRequestParams(token: authCredentials.soapTokenCredential,
                                                   stockTradingType: stockTypeOrderOperationInput.stockTradingType,
                                                   userDataDTO: userDataDTO,
                                                   terminalId: bsanHeaderData.terminalID,
                                                   version: bsanHeaderData.version,
                                                   language: bsanHeaderData.language,
                                                   bankCode: stockAccountDTO.contract?.bankCode ?? "",
                                                   branchCode: stockAccountDTO.contract?.branchCode ?? "",
                                                   product: stockAccountDTO.contract?.product ?? "",
                                                   contractNumber: stockAccountDTO.contract?.contractNumber ?? "",
                                                   stockCode: stockQuoteDTO.stockCode ?? "",
                                                   identificationNumber: stockQuoteDTO.identificationNumber ?? "",
                                                   tradesShares: stockTypeOrderOperationInput.tradesShare,
                                                   limitDate: stockTypeOrderOperationInput.limitedDate,
                                                   signatureDTO: signatureDTO))
        
        let response: ConfirmSellStockTypeOrderResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.stockOperationDataConfirmDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    
}
