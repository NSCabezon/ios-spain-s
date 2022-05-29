import SANLegacyLibrary
import CoreDomain

public class BSANLoansManagerImplementation: BSANBaseManager, BSANLoansManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getLoanTransactions(forLoan loan: LoanDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> BSANResponse<LoanTransactionsListDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getLoanAssemble()
        
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
        guard var contractString = loan.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed loan contract")
        }

        contractString += dateFilterToUse.string
        let loanTransactionList = try bsanDataProvider.get(\.loanInfo).loanTransactionsDictionary[contractString]
        
        if let loanTransactionList = loanTransactionList {
            if pagination != nil {
                if loanTransactionList.pagination.endList {
                    return BSANOkResponse(loanTransactionList)
                }
            } else {
                return BSANOkResponse(loanTransactionList)
            }
        }
        
        let request = LoanTransactionsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            LoanTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                          userDataDTO: userDataDTO,
                                          terminalId: bsanHeaderData.terminalID,
                                          version: bsanHeaderData.version,
                                          language: bsanHeaderData.language,
                                          bankCode: loan.contract?.bankCode ?? "",
                                          branchCode: loan.contract?.branchCode ?? "",
                                          product: loan.contract?.product ?? "",
                                          contractNumber: loan.contract?.contractNumber ?? "",
                                          dateFilter: dateFilterToUse,
                                          currencyType: loan.availableAmount?.currency?.currencyType,
                                          pagination: pagination))
        
        let response: LoanTransactionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(loanTransactionsList: response.loanTransactions, forLoanId: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.loanTransactions);
        }
        return BSANErrorResponse(meta);
    }
    
    public func getLoanDetail(forLoan loan: LoanDTO) throws -> BSANResponse<LoanDetailDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getLoanAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contractString = loan.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed loan contract")
        }
        
        let loanDetailDTO = try bsanDataProvider.get(\.loanInfo).loanDetailDictionary[contractString]
        
        if loanDetailDTO != nil{
            return BSANOkResponse(loanDetailDTO)
        }
        
        let request = GetLoanDetailOldRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetLoanDetailRequestParams(token: authCredentials.soapTokenCredential,
                                       version: bsanHeaderData.version,
                                       terminalId: bsanHeaderData.terminalID,
                                       userDataDTO: userDataDTO,
                                       bankCode: loan.contract?.bankCode ?? "",
                                       branchCode: loan.contract?.branchCode ?? "",
                                       product: loan.contract?.product ?? "",
                                       contractNumber: loan.contract?.contractNumber ?? "",
                                       language: bsanHeaderData.language))
        
        let response: GetLoanDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(loanDetail: response.loanDetailDTO, forLoan: loan)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.loanInfo).loanDetailDictionary[contractString]);
        }
        return BSANErrorResponse(meta);
    }
    
    public func getLoanTransactionDetail(forLoan loan: LoanDTO, loanTransaction: LoanTransactionDTO) throws -> BSANResponse<LoanTransactionDetailDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getLoanAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contractString = loanTransaction.dgoNumber?.description else {
            throw BSANIllegalStateException("Malformed loanTransactionNumber")
        }
        
        let loanTransactionDetailDTO = try bsanDataProvider.get(\.loanInfo).loanTransactionDetailDictionary[contractString]
        
        if loanTransactionDetailDTO != nil{
            return BSANOkResponse(loanTransactionDetailDTO)
        }
        
        let request = GetLoanTransactionDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetLoanTransactionDetailRequestParams(token: authCredentials.soapTokenCredential,
                                       version: bsanHeaderData.version,
                                       terminalId: bsanHeaderData.terminalID,
                                       userDataDTO: userDataDTO,
                                       bankCode: loan.contract?.bankCode ?? "",
                                       branchCode: loan.contract?.branchCode ?? "",
                                       product: loan.contract?.product ?? "",
                                       contractNumber: loan.contract?.contractNumber ?? "",
                                       language: bsanHeaderData.language,
                                       loanTransactionDTO: loanTransaction))
        
        let response: GetLoanTransactionDetailResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(loanTransactionDetail: response.loanTransactionDetailDTO, forLoanTransaction: loanTransaction)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.loanInfo).loanTransactionDetailDictionary[contractString]);
        }
        return BSANErrorResponse(meta);
    }
    
    public func removeLoanDetail(loanDTO: LoanDTO) throws -> BSANResponse<Void> {
        try bsanDataProvider.removeLoanDetail(loanDTO)
        return BSANOkResponse(nil)
    }
    
    /**
     * Servicio para testear
     */
    public func confirmChangeAccount(loanDTO: LoanDTO, accountDTO: AccountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let accountContract = newGlobalPosition.accounts?.first(where: { $0.iban == accountDTO.iban })?.contract ?? accountDTO.contract
        
        let request = ConfirmChangeAccountRequest(
            BSANAssembleProvider.getLoanOperationsAssemble(),
            bsanEnvironment.urlBase,
            ConfirmChangeAccountRequestParams(token: authCredentials.soapTokenCredential,
                                              userDataDTO: userDataDTO,
                                              languageISO: bsanHeaderData.languageISO,
                                              dialectISO: bsanHeaderData.dialectISO,
                                              linkedCompany: bsanHeaderData.linkedCompany,
                                              loanContract: loanDTO.contract,
                                              accountContract: accountContract,
                                              signature: signatureDTO))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func changeLoanAlias(_ loan: LoanDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANErrorResponse(nil)
    }
}
