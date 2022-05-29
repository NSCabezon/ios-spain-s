import SANLegacyLibrary
import CoreDomain

public class BSANAccountsManagerImplementation: BSANBaseManager, BSANAccountsManager {
    
    var sanSoapServices: SanSoapServices
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices, sanRestServices: SanRestServices) {
        self.sanSoapServices = sanSoapServices
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getAllAccounts() throws -> BSANResponse<[AccountDTO]> {
        let accountDTOs = try bsanDataProvider.get(\.globalPositionDTO).accounts
        return BSANOkResponse(accountDTOs)
    }
    
    public func getAccountDetail(forAccount account: AccountDTO) throws -> BSANResponse<AccountDetailDTO> {
        
        let isPb = try bsanDataProvider.isPB()
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getAccountsAssemble(isPb)
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        guard let contractString = account.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed account contract")
        }
        
        let accountDetail = try bsanDataProvider.get(\.accountInfo).accountDetailDictionary[contractString]
        
        if let accountDetail = accountDetail {
            return BSANOkResponse(accountDetail)
        }
        
        let request = GetAccountDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetAccountDetailRequestParams(token: authCredentials.soapTokenCredential,
                                          userDataDTO: userDataDTO,
                                          bankCode: account.oldContract?.bankCode ?? "",
                                          branchCode: account.oldContract?.branchCode ?? "",
                                          product: account.oldContract?.product ?? "",
                                          contractNumber: account.oldContract?.contractNumber ?? ""))
        
        let response: GetAccountDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(accountDetail: response.accountDetailDTO, forAccount: account)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.accountInfo).accountDetailDictionary[contractString]);
        }
        return BSANErrorResponse(meta);
    }
    
    public func getAllAccountTransactions(forAccount account: AccountDTO, dateFilter: DateFilter?) throws -> BSANResponse<AccountTransactionsListDTO> {
        var response = try getAccountTransactions(forAccount: account, pagination: nil, dateFilter: dateFilter)
        while response.isSuccess(), let accountTransactions = try response.getResponseData(), !accountTransactions.pagination.endList {
            response = try getAccountTransactions(forAccount: account, pagination: accountTransactions.pagination, dateFilter: dateFilter)
        }
        return try getAccountTransactions(forAccount: account, pagination: nil, dateFilter: dateFilter);
    }

    public func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<AccountTransactionsListDTO> {
        try getAccountTransactions(forAccount: account, pagination: pagination, dateFilter: dateFilter, cached: true)
    }

    public func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?, cached: Bool) throws -> BSANResponse<AccountTransactionsListDTO> {
        
        let isPb = try bsanDataProvider.isPB()
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getAccountsAssemble(isPb)
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard var contractString = account.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed account contract")
        }
        if let dateFilter = dateFilter {
            contractString += dateFilter.string
        }
        let accountTransactionList = try bsanDataProvider.get(\.accountInfo).accountTransactionsDictionary[contractString]
        
        if let accountTransactionList = accountTransactionList {
            if pagination != nil {
                if accountTransactionList.pagination.endList {
                    return BSANOkResponse(accountTransactionList)
                }
            } else {
                return BSANOkResponse(accountTransactionList)
            }
        }
        
        let request = AccountTransactionsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            AccountTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             bankCode: account.oldContract?.bankCode ?? "",
                                             branchCode: account.oldContract?.branchCode ?? "",
                                             product: account.oldContract?.product ?? "",
                                             contractNumber: account.oldContract?.contractNumber ?? "",
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             pagination: pagination,
                                             dateFilter: dateFilter,
                                             filter: nil))
        
        let response: AccountTransactionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            if cached {
                bsanDataProvider.store(accountTransactionsList: response.accountTransactions, forAccountId: contractString)
            }
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.accountTransactions);
        }
        let errorResponse: BSANResponse<AccountTransactionsListDTO> = BSANErrorResponse(meta)
        // Workaround
        // Ñapa obligatoria, el servicio puede devolver como error algo que no lo es
        if BSANSoapResponse.RESULT_ERROR == response.errorCode, let errorDesc = response.errorDesc, errorDesc.lowercased().contains("no existen movimientos") {
            let pagination = PaginationDTO(repositionXML: "", accountAmountXML: "", endList: true)
            let transactionList = AccountTransactionsListDTO(transactionDTOs: [], pagination: pagination)
            if cached {
                bsanDataProvider.store(accountTransactionsList: transactionList, forAccountId: contractString)
            }
            return BSANOkResponse(transactionList)
        }
        return errorResponse
    }
    
    public func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, filter: AccountTransferFilterInput) throws -> BSANResponse<AccountTransactionsListDTO> {
        
        let isPb = try bsanDataProvider.isPB()
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getAccountsAssemble(isPb)
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard var contractString = account.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed account contract")
        }
        
        contractString += filter.string
        let accountTransactionList = try bsanDataProvider.get(\.accountInfo).accountTransactionsDictionary[contractString]
        
        if let accountTransactionList = accountTransactionList {
            if pagination != nil {
                if accountTransactionList.pagination.endList {
                    return BSANOkResponse(accountTransactionList)
                }
            } else {
                return BSANOkResponse(accountTransactionList)
            }
        }
        
        let request = AccountTransactionsFilterRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            AccountTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             bankCode: account.oldContract?.bankCode ?? "",
                                             branchCode: account.oldContract?.branchCode ?? "",
                                             product: account.oldContract?.product ?? "",
                                             contractNumber: account.oldContract?.contractNumber ?? "",
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             pagination: pagination,
                                             dateFilter: filter.dateFilter,
                                             filter: filter))
        
        let response: AccountTransactionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(accountTransactionsList: response.accountTransactions, forAccountId: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.accountTransactions);
        }
        return BSANErrorResponse(meta);
    }
    
    
    public func getAccountTransactionDetail(from transactionDTO: AccountTransactionDTO) throws -> BSANResponse<AccountTransactionDetailDTO> {
        
        let isPb = try bsanDataProvider.isPB()
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getAccountsAssemble(isPb)
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contractNumber = transactionDTO.dgoNumber?.description else {
            throw BSANIllegalStateException("Malformed account transactionNumer")
        }
        
        let accountTransactionDetailDTO = try bsanDataProvider.get(\.accountInfo).accountTransactionDetailDictionary[contractNumber]
        
        if accountTransactionDetailDTO != nil {
            return BSANOkResponse(accountTransactionDetailDTO)
        }
        
        let request = GetAccountTransactionDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetAccountTransactionDetailRequestParams(token: authCredentials.soapTokenCredential,
                                                     userDataDTO: userDataDTO,
                                                     bankCode: transactionDTO.newContract?.bankCode ?? "",
                                                     branchCode: transactionDTO.newContract?.branchCode ?? "",
                                                     product: transactionDTO.newContract?.product ?? "",
                                                     contractNumber: transactionDTO.newContract?.contractNumber ?? "",
                                                     value: transactionDTO.amount?.value,
                                                     currency: transactionDTO.amount?.currency?.currencyName ?? "",
                                                     transactionType: transactionDTO.transactionType ?? "",
                                                     transactionDay: transactionDTO.transactionDay ?? "",
                                                     operationDate: transactionDTO.operationDate,
                                                     annotationDate: transactionDTO.annotationDate,
                                                     dgoTerminalCode: transactionDTO.dgoNumber?.terminalCode ?? "",
                                                     dgoNumber: transactionDTO.dgoNumber?.number ?? "",
                                                     dgoCenter: transactionDTO.dgoNumber?.center ?? "",
                                                     dgoCompany: transactionDTO.dgoNumber?.company ?? "",
                                                     transactionNumber: transactionDTO.transactionNumber ?? "",
                                                     productSubtype: transactionDTO.productSubtypeCode ?? "",
                                                     terminalId: bsanHeaderData.terminalID,
                                                     version: bsanHeaderData.version,
                                                     language: bsanHeaderData.language))
        
        let response: GetAccountTransactionDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(accountTransactionDetail: response.accountTransactionDetailDTO, forAccountTransaction: transactionDTO)
            return BSANOkResponse(meta, response.accountTransactionDetailDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func checkAccountMovementPdf(accountDTO: AccountDTO, accountTransactionDTO: AccountTransactionDTO) throws -> BSANResponse<DocumentDTO> {
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = CheckMovementPdfRequest(
            BSANAssembleProvider.getAccountsMovementPdfAssemble(),
            bsanEnvironment.urlBase,
            CheckMovementPdfRequestParams(token: authCredentials.soapTokenCredential,
                                          userDataDTO: userDataDTO,
                                          languageISO: bsanHeaderData.languageISO,
                                          dialectISO: bsanHeaderData.dialectISO,
                                          company: userDataDTO.company ?? "",
                                          currency: accountTransactionDTO.amount?.currency?.currencyName ?? "",
                                          date: accountTransactionDTO.operationDate,
                                          transactionDay: accountTransactionDTO.transactionDay ?? "",
                                          iban: accountDTO.iban))
        
        let response: CheckMovementPdfResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.documentDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func getAccount(fromOldContract oldContract: ContractDTO?) throws -> BSANResponse<AccountDTO> {
        let accountDTOs = try bsanDataProvider.get(\.globalPositionDTO).accounts
        
        if let contract = oldContract, let accounts = accountDTOs, !accounts.isEmpty {
            let account = accounts.filter { $0.oldContract == contract }.first
            return BSANOkResponse(account)
        }
        return BSANOkResponse(Meta.createOk())
    }
    
    public func getAccount(fromIBAN iban: IBANDTO?) throws -> BSANResponse<AccountDTO> {
        let accountDTOs = try bsanDataProvider.get(\.globalPositionDTO).accounts
        let accountDTO = accountDTOs?.filter { $0.iban == iban }.first
        return BSANOkResponse(accountDTO)
    }
    
    public func getAccountEasyPay() throws -> BSANResponse<[AccountEasyPayDTO]> {
        guard let accountEasyPayCampaigns = try bsanDataProvider.get(\.accountEasyPayCampaigns) else {
            let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
            let userDataDTO = try bsanDataProvider.getUserData()
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
            let request = AccountEasyPayRequest(
                BSANAssembleProvider.getAccountEasyPayAssemble(),
                bsanEnvironment.urlBase,
                AccountEasyPayRequestParams(
                    token: authCredentials.soapTokenCredential,
                    userDataDTO: userDataDTO,
                    language: bsanHeaderData.languageISO,
                    dialect: bsanHeaderData.dialectISO
                )
            )
            let response: AccountEasyPayResponse = try sanSoapServices.executeCall(request)
            let meta = try Meta.createMeta(request, response)
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                bsanDataProvider.store(accountEasyPayCampaigns: response.campaigns)
                return BSANOkResponse(meta, response.campaigns)
            }
            return BSANErrorResponse(meta)
        }
        return BSANOkResponse(accountEasyPayCampaigns)
    }
    
    /// Method that call `personalizarPosicionGlobal_LA` service
    public func changeAccountAlias(accountDTO: AccountDTO, newAlias: String) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ChangeProductAliasRequest(
            BSANAssembleProvider.getChangeProductAliasAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ChangeProductAliasRequestParams(token: authCredentials.soapTokenCredential,
                                            userDataDTO: userDataDTO,
                                            languageISO: bsanHeaderData.languageISO,
                                            dialectISO: bsanHeaderData.dialectISO,
                                            linkedCompany: bsanHeaderData.linkedCompany,
                                            accountDTO: accountDTO,
                                            newAlias: newAlias))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.updateAccount(accountDTO: accountDTO, newAlias: newAlias)
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func changeMainAccount(accountDTO: AccountDTO, newMain: Bool) throws -> BSANResponse<Void> {
        return BSANOkResponse(nil)
    }
    
    //	Withholding list from account. Regarding if pb or not
    public func getWithholdingList(iban: String, currency: String) throws -> BSANResponse<WithholdingListDTO> {
        let withHoldingDataSource = WithholdingListDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let withHoldingDataDTOResponse = try withHoldingDataSource.getWithholdingList(body: WithholdingListQueryDTO(iban: iban, currency: currency))
        
        if withHoldingDataDTOResponse.isSuccess() {
            return withHoldingDataDTOResponse
        }
        return BSANOkResponse(nil)
    }
    
    @available(*, deprecated, message: "Use getAccountMovements(params: AccountMovementListParams, account: String) instead")
    public func getAccountMovements(params: AccountMovementListParams) throws -> BSANResponse<AccountMovementListDTO> {
        let dataSource = AccountMovementListDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.loadAccountMovementsList(params: params)
    }
    
    public func getAccountMovements(params: AccountMovementListParams, account: String) throws -> BSANResponse<AccountMovementListDTO> {
        let dataSource = AccountMovementListDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.loadAccountMovementsList(params: params, account: account)
    }
    
    @available(*, deprecated, message: "Use BSANBillTaxesManager.loadFutureBills instead")
    public func getAccountFutureBills(params: AccountFutureBillParams) throws -> BSANResponse<AccountFutureBillListDTO> {
        let dataSource = AccountFutureBillListDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.loadAccountFutureBillList(params: params)
    }
    
    public func getAccountTransactionCategory(params: TransactionCategorizerInputParams) throws -> BSANResponse<TransactionCategorizerDTO> {
        let datasource = AccountMovementCategorizerDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: bsanDataProvider)
        return try datasource.loadAccountTransactionCategory(params: params)
    }
}

