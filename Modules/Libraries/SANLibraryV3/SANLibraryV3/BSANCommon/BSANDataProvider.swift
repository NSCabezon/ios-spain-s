import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public class BSANDataProvider {
    
    private var dataRepository: DataRepository
    private var bsanHeaderDataES: BSANHeaderData
    private var bsanHeaderDataPB: BSANHeaderData
    private var bsanHeaderDataES0049: BSANHeaderData
    private var bsanAlternativeHeaderDataPB: BSANHeaderData
    private var bsanAlternativeHeaderDataES: BSANHeaderData
    
    public init(dataRepository: DataRepository, appInfo: VersionInfoDTO) {
        self.dataRepository = dataRepository
        self.bsanHeaderDataES = BSANHeaderData.newInstanceForSanES(version: appInfo.getVersionName());
        self.bsanHeaderDataPB = BSANHeaderData.newInstanceForSanPB(version: appInfo.getVersionName());
        self.bsanHeaderDataES0049 = BSANHeaderData.newInstanceForSanESMobileRecharge(version: appInfo.getVersionName());
        self.bsanAlternativeHeaderDataPB = BSANHeaderData.newInstanceForAlternativeSanPB(version: appInfo.getVersionName());
        self.bsanAlternativeHeaderDataES = BSANHeaderData.newInstanceForAlternativeSanES(version: appInfo.getVersionName());
    }
    
    /*
     * BSANHeaderData
     */
    public func getBsanHeaderDataESforMobileRecharge() -> BSANHeaderData {
        return bsanHeaderDataES0049
    }
    
    public func getBsanHeaderDataForCVV() throws -> BSANHeaderData {
        return try isPB() ? bsanHeaderDataPB : bsanHeaderDataES0049
    }
    
    public func getBsanHeaderData() throws -> BSANHeaderData {
        return try isPB() ? bsanHeaderDataPB : bsanHeaderDataES
    }
    
    public func getBsanHeaderData(_ isPB: Bool) -> BSANHeaderData {
        return isPB ? bsanHeaderDataPB : bsanHeaderDataES
    }
    
    public func getAlternativeBsanHeaderData() throws -> BSANHeaderData {
        return try isPB() ? bsanAlternativeHeaderDataPB : bsanAlternativeHeaderDataES
    }
    
    /*
     * SessionData Shortcuts
     */
    private func getSessionData() throws -> SessionData {
        if let sessionData = dataRepository.get(SessionData.self) {
            return sessionData
        }
        throw BSANIllegalStateException("SessionData nil in DataRepository")
    }
    
    public func getUserData() throws -> UserDataDTO {
        if let sessionData = try? getSessionData(), let userDataDTO = sessionData.globalPositionDTO.userDataDTO {
            return userDataDTO
        }
        throw BSANIllegalStateException("UserDataDTO nil in DataRepository")
    }
    
    public func getUserDTO() throws -> UserDTO {
        guard let userDTO = try? getSessionData().userDTO else {
            throw BSANIllegalStateException("UserDTO nil in DataRepository")
        }
        return userDTO
    }
    
    public func getEnvironment() throws -> BSANEnvironmentDTO {
        if let bsanEnvironmentDTO = dataRepository.get(BSANEnvironmentDTO.self) {
            return bsanEnvironmentDTO
        }
        throw BSANIllegalStateException("BSANEnvironment is nil in DataRepository")
    }
    
    public func getNewGlobalPositionDTO() throws -> GlobalPositionDTO? {
        let newGlobalPositionDTO = try self.get(\.newGlobalPositionDTO)
        return newGlobalPositionDTO.userDataDTO != nil ? newGlobalPositionDTO : nil
    }
    
    public func updateSoapCredentials(token: String) {
        objc_sync_enter(dataRepository)
        if let authCredentials = dataRepository.get(AuthCredentials.self) {
            authCredentials.soapTokenCredential = token
            dataRepository.store(authCredentials)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func getAuthCredentials() throws -> AuthCredentials {
        if let authCredentials = dataRepository.get(AuthCredentials.self) {
            return authCredentials
        }
        throw BSANIllegalStateException("AuthCredentials nil in DataRepository")
    }
    
    /*
     * Is PB User
     */
    public func isPB() throws -> Bool {
        if let sessionData = try? getSessionData() {
            return sessionData.isPB
        }
        throw BSANIllegalStateException("UserDataDTO nil in DataRepository")
    }
    
    /*
     * Is Select User
     */
    public func isSelect() throws -> Bool {
        if let sessionData = try? getSessionData() {
            return sessionData.isSelect ?? false
        }
        throw BSANIllegalStateException("UserDataDTO nil in DataRepository")
    }
    
    /*
     * Is Smart User
     */
    public func isSmart() throws -> Bool {
        if let sessionData = try? getSessionData() {
            return sessionData.isSmart ?? false
        }
        throw BSANIllegalStateException("UserDataDTO nil in DataRepository")
    }
    
    /*
     * Close session
     */
    public func closeSession() {
        dataRepository.remove(DemoMode.self)
        dataRepository.remove(AuthCredentials.self)
        dataRepository.remove(SessionData.self)
    }
    
    public func createSessionData(_ userDTO: UserDTO) {
        let sessionData = SessionData(userDTO)
        objc_sync_enter(dataRepository)
        dataRepository.store(sessionData)
        objc_sync_exit(dataRepository)
    }
    
    public func updateSessionData(_ globalPositionDTO: GlobalPositionDTO, _ isPB: Bool) {
        if let sessionData = try? getSessionData() {
            sessionData.updateSessionData(globalPositionDTO, isPB)
            objc_sync_enter(dataRepository)
            dataRepository.store(sessionData)
            objc_sync_exit(dataRepository)
        }
    }
    
    private func updateSessionData(_ sessionData: SessionData) {
        objc_sync_enter(dataRepository)
        dataRepository.store(sessionData)
        objc_sync_exit(dataRepository)
    }
    
    /*
     * DELETE METHODS
     */
    
    public func deletePortfoliosProducts() {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.portfolioInfo.portfolioProductsList.removeAll()
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func deleteStockOrders() {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.stockInfo.removeStockOrderList()
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func deleteScheduledTransfer(_ scheduledTransfer: TransferScheduledDTO, contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.transferInfo.removeScheduledTransfer(scheduledTransferDTO: scheduledTransfer, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    internal func deleteBillList() {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.billAndTaxesInfo.removeCache()
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func removeFavouriteTransfer() {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.transferInfo.removeFavouriteTransfer()
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func removeFutureBillList() {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.billAndTaxesInfo.removeBillFutureList()
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    /*
     * STORE METHODS
     */
    
    public func storeEnviroment(_ enviroment: BSANEnvironmentDTO) {
        objc_sync_enter(dataRepository)
        dataRepository.store(enviroment)
        objc_sync_exit(dataRepository)
    }
    
    public func storeAuthCredentials(_ authCredentials: AuthCredentials) {
        objc_sync_enter(dataRepository)
        dataRepository.store(authCredentials)
        objc_sync_exit(dataRepository)
    }
    
    public func storeUsualTransfers(payeeDTOs: [PayeeDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.usualTransfersList = payeeDTOs
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeScheduledTransfers(transferScheduledListDTO: TransferScheduledListDTO, contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.addTransferScheduled(transferScheduledListDTO: transferScheduledListDTO, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeEmittedTransfers(transferEmittedListDTO: TransferEmittedListDTO, contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.addTransferEmittedCache(transferEmittedListDTO: transferEmittedListDTO, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeEmptyEmittedTransfers(contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.addEmptyTransferEmittedCache(contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeEmittedTransferDetail(transferEmittedDetailDTO: TransferEmittedDetailDTO, idTransfer: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.transfersEmittedDetailDictionary[idTransfer] = transferEmittedDetailDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeScheduledTransferDetail(transferScheduledDetailDTO: TransferScheduledDetailDTO, idTransfer: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.transfersScheduledDetailDictionary[idTransfer] = transferScheduledDetailDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeFavouriteTransfers(_ payeeDTOs: [PayeeDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.transferInfo.microFavouriteTransferList = payeeDTOs
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeBillAndTaxesList(billListDTO: BillListDTO, key: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.billAndTaxesInfo.addToBillAndTaxesListCache(billListDTO, contract: key)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeFutureBillList(_ key: String, futureBillList: AccountFutureBillListDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.billAndTaxesInfo.addFutureBillsListCache(key, futureBillList: futureBillList)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeVariableIncomePortfoliosPb(portfolioRVManagedList: [PortfolioDTO], portfolioRVManagedStockAccountList: [StockAccountDTO], portfolioRVNotManagedList: [PortfolioDTO], portfolioRVNotManagedStockAccountList: [StockAccountDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.portfolioInfo
                .setPortfolioRVManagedList(portfolioRVManagedList)
                .setPortfolioRVManagedStockAccountList(portfolioRVManagedStockAccountList: portfolioRVManagedStockAccountList)
                .setPortfolioRVNotManagedList(portfolioRVNotManagedList)
                .setPortfolioRVNotManagedStockAccountList(portfolioRVNotManagedStockAccountList: portfolioRVNotManagedStockAccountList)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeVariableIncomePortfoliosSelect(portfolioRVManagedList: [PortfolioDTO], portfolioRVManagedStockAccountList: [StockAccountDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.portfolioInfo
                .setPortfolioRVManagedList(portfolioRVManagedList)
                .setPortfolioRVManagedStockAccountList(portfolioRVManagedStockAccountList: portfolioRVManagedStockAccountList)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func resetPortfolios() {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.portfolioInfo.removePortfolios()
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storePortfoliosPb(portfoliosManagedList: [PortfolioDTO], portfoliosNotManagedList: [PortfolioDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            _ = sessionData.portfolioInfo
                .setPortfolioManagedList(portfoliosManagedList)
                .setPortfolioNotManagedList(portfoliosNotManagedList)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storePortfoliosSelect(portfoliosManagedList: [PortfolioDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            _ = sessionData.portfolioInfo
                .setPortfolioManagedList(portfoliosManagedList)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storePortfolioProductsList(portfolioProductPBDTOS: [PortfolioProductDTO], contractId: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            _ = sessionData.portfolioInfo.portfolioProductsList[contractId] = portfolioProductPBDTOS
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storePortfolioProductTransactionsList(portfolioProductTransaction: PortfolioTransactionsListDTO, contractId: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.portfolioInfo.addPortfolioProductTransactionList(portfolioProductTransactionList: portfolioProductTransaction, contractId: contractId)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storePrepaidCard(_ PAN: String, _ prepaidCardDTO: PrepaidCardDataDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.addToPrepaidCards(PAN, prepaidCardDTO);
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeUserSegment(userSegmentDTO: UserSegmentDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.userSegmentDTO = userSegmentDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(isSelect: Bool) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.isSelect = isSelect
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeIsSmart(_ isSmart: Bool) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.isSmart = isSmart
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(accountDetail: AccountDetailDTO, forAccount account: AccountDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = account.contract?.formattedValue else {
                fatalError("Invalid account contract")
            }
            let _ = sessionData.accountInfo.accountDetailDictionary[contractString] = accountDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(personDataDTO: PersonDataDTO, forAccount account: AccountDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = account.contract?.formattedValue else {
                fatalError("Invalid account contract")
            }
            let _ = sessionData.accountInfo.personDataMap[contractString] = personDataDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(accountTransactionsList: AccountTransactionsListDTO, forAccountId contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.accountInfo.addAccountTransactions(accountTransactionsListDTO: accountTransactionsList, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(cardTransactionsList: CardTransactionsListDTO, forCardId contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.cardInfo.addCardTransactions(cardTransactionsListDTO: cardTransactionsList, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(cardTransactionDetail: CardTransactionDetailDTO, id: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.cardInfo.cardTransactionDetails[id] = cardTransactionDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(accountTransactionDetail: AccountTransactionDetailDTO, forAccountTransaction accountTransaction: AccountTransactionDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = accountTransaction.dgoNumber?.description else {
                fatalError("Invalid account dgoNumber")
            }
            let _ = sessionData.accountInfo.accountTransactionDetailDictionary[contractString] = accountTransactionDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(impositionList: ImpositionsListDTO, forDeposit deposit: DepositDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = deposit.contract?.formattedValue else {
                fatalError("Invalid contract")
            }
            sessionData.depositInfo.add(impositionsListDTO: impositionList, contract: contractString)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(impositionTransactionsList: ImpositionTransactionsListDTO, impositionContract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.depositInfo.add(impositionTransactionsListDTO: impositionTransactionsList, contract: impositionContract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(impositionLiquidationTransactionsList: LiquidationTransactionListDTO, impositionContract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.depositInfo.add(impositionsLiquidationsListDTO: impositionLiquidationTransactionsList, contract: impositionContract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(liquidationDetail: LiquidationDetailDTO, contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.depositInfo.liquidationDetailsDictionary[contract] = liquidationDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(stockList: StockListDTO, stockContract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.stockInfo.add(stockList: stockList, contract: stockContract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(stockQuoteDetail: StockQuoteDetailDTO?, stockContract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.stockInfo.stockQuoteDetailDictionary[stockContract] = stockQuoteDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(ordersList: OrderListDTO?, stockContract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.stockInfo.add(ordersList: ordersList, contract: stockContract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(orderDetail: OrderDetailDTO?, contractId: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.stockInfo.stockOrderDetailsDictionary[contractId] = orderDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func store(loanSimulatorLimitDto: LoanSimulatorLimitDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.loanSimulatorLimitDto = loanSimulatorLimitDto
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(checkActiveData: CampaignsCheckLoanSimulatorDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.loanSimulatorCheckActiveDataDTO = checkActiveData
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(selectedCampaign: LoanSimulatorCampaignDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.loanSimulatorSelectedCampaignDto = selectedCampaign
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(fundTransactionsList: FundTransactionsListDTO, forFundId contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.fundInfo.addFundTransactions(fundTransactionsListDTO: fundTransactionsList, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeFundTransactionDetail(fundTransactionDetail: FundTransactionDetailDTO, forFundTransaction fundTransaction: FundTransactionDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = fundTransaction.getFundTransactionKey() else {
                fatalError("Invalid fund transactionNumber")
            }
            let _ = sessionData.fundInfo.fundTransactionWithDetailDictionary[contractString] = fundTransactionDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(fundDetail: FundDetailDTO, forFund fund: FundDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = fund.contract?.formattedValue else {
                fatalError("Invalid fund contract")
            }
            let _ = sessionData.fundInfo.fundWithDetailDictionary[contractString] = fundDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(loanTransactionsList: LoanTransactionsListDTO, forLoanId contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.loanInfo.addLoanTransactions(loanTransactionsListDTO: loanTransactionsList, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(loanDetail: LoanDetailDTO, forLoan loan: LoanDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = loan.contract?.formattedValue else {
                fatalError("Invalid account contract")
            }
            let _ = sessionData.loanInfo.loanDetailDictionary[contractString] = loanDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(loanTransactionDetail: LoanTransactionDetailDTO, forLoanTransaction loanTransaction: LoanTransactionDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = loanTransaction.dgoNumber?.description else {
                fatalError("Invalid account contract")
            }
            let _ = sessionData.loanInfo.loanTransactionDetailDictionary[contractString] = loanTransactionDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(pensionTransactionsList: PensionTransactionsListDTO, forPensionId contract: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.pensionInfo.addPensionTransactions(pensionTransactionsListDTO: pensionTransactionsList, contract: contract)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(pensionDetail: PensionDetailDTO, forPension pension: PensionDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            guard let contractString = pension.contract?.formattedValue else {
                fatalError("Invalid account contract")
            }
            let _ = sessionData.pensionInfo.pensionDetailDictionary[contractString] = pensionDetail
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeCardData(cardDataDTOList: [CardDataDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            for cardDataDTO in cardDataDTOList {
                sessionData.cardInfo.addToCardsData(cardDataDTO);
            }
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeInactiveCards(inactiveCards: [InactiveCardDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            for inactiveCard in inactiveCards {
                sessionData.cardInfo.addToInactiveCards(inactiveCard);
            }
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeTemporallyInactiveCards(temporallyInactiveCards: [InactiveCardDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            for temporallyInactiveCard in temporallyInactiveCards {
                sessionData.cardInfo.addToTemporallyOffCards(temporallyInactiveCard)
            }
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeCardDetail(PAN: String, cardDetailDTO: CardDetailDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.addToCardsDetail(PAN, cardDetailDTO)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeCardDetails(dictionaryPANDetail: [String: CardDetailDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            if dictionaryPANDetail.count > 0 {
                for cardDetail in dictionaryPANDetail {
                    sessionData.cardInfo.addToCardsDetail(cardDetail.key, cardDetail.value)
                }
            }
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeCardBalances(dictionaryPANBalances: [String: CardBalanceDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            if dictionaryPANBalances.count > 0 {
                for cardBalanceDTO in dictionaryPANBalances {
                    sessionData.cardInfo.addToCardBalances(cardBalanceDTO.key, cardBalanceDTO.value)
                }
            }
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeCMCSignature(response: CMCSignatureResponse) {
        guard let sessionData = try? getSessionData(), let signatureDataDTO = response.signatureDataDTO else {
            return
        }
        objc_sync_enter(dataRepository)
        sessionData.signStatusInfo = SignStatusInfo.createSignStatus(signatureDataDTO: signatureDataDTO)
        updateSessionData(sessionData)
        objc_sync_exit(dataRepository)
    }
    
    public func storeUserCampaigns(userCampaigns: [String]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.userCampaigns = userCampaigns;
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeSociusTotalLiquidation(sociusAccountDetailDTO: SociusAccountDetailDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.sociusInfo.sociusLiquidationDTO = sociusAccountDetailDTO.totalLiquidation
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeSociusAccounts(sociusAccountDTOList: [SociusAccountDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.sociusInfo.sociusAccountsList = sociusAccountDTOList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeCMPS(cmpsdto: CMPSDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.cmpsDTO = cmpsdto;
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeInsuranceData(contractId: String, insuranceDataDTO: InsuranceDataDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.insuranceInfo.insuranceData[contractId] = insuranceDataDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeInsuranceParticipants(policyId: String, insuranceParticipantsList: [InsuranceParticipantDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.insuranceInfo.participants[policyId] = insuranceParticipantsList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeInsuranceBeneficiaries(policyId: String, insuranceBeneficiariesList: [InsuranceBeneficiaryDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.insuranceInfo.beneficiaries[policyId] = insuranceBeneficiariesList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeInsuranceCoverages(policyId: String, insuranceCoveragesList: [InsuranceCoverageDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.insuranceInfo.coverages[policyId] = insuranceCoveragesList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(pensionContributionsListDTO: PensionContributionsListDTO, withContract contractId: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.pensionInfo.addPensionContributions(pensionContributionsListDTO: pensionContributionsListDTO, contractId: contractId)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(paymentBillTaxes: PaymentBillTaxesDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.billAndTaxesInfo.paymentBillTaxesDTO = paymentBillTaxes
            updateSessionData(sessionData)
        }
        
        objc_sync_exit(dataRepository)
    }
    
    public func store(managers: YourManagersListDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.managersInfo.yourManagersListDTO = managers
            updateSessionData(sessionData)
        }
        
        objc_sync_exit(dataRepository)
    }
    
    public func store(tokenCredential: BillAndTaxesTokenDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.billAndTaxesInfo.billAndTaxesTokenDTO = tokenCredential
            updateSessionData(sessionData)
        }
        
        objc_sync_exit(dataRepository)
    }
    
    public func store(mobileOperatorDTO: MobileOperatorDTO?) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData(), let mobileOperatorDTO = mobileOperatorDTO {
            sessionData.cardInfo.mobileOperatorDTO = mobileOperatorDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(validateMobileRechargeDTO: ValidateMobileRechargeDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.validateMobileRechargeDTO = validateMobileRechargeDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(payLaterDTO: PayLaterDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.payLaterDTO = payLaterDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(feeData: FeeDataDTO, id: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.feesData[id] = feeData
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(easyPayDto: EasyPayDTO, id: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.easyPayDTOs[id] = easyPayDto
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(easyPayContractTransactionListDTO: EasyPayContractTransactionListDTO, contractId: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardInfo.easyPayContractTransactionsList[contractId] = easyPayContractTransactionListDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(newGlobalPositionDTO: GlobalPositionDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.newGlobalPositionDTO = newGlobalPositionDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func updateCard(cardDTO: CardDTO, newAlias: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData(), let cards = sessionData.globalPositionDTO.cards {
            var newCardDTO = cardDTO
            newCardDTO.alias = newAlias
            let cardsUpdated = updateCard(cards: cards, cardDTO: newCardDTO)
            sessionData.globalPositionDTO.cards = cardsUpdated
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }

    public func updateCard(cardDTO: CardDTO, newType: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData(), let cards = sessionData.globalPositionDTO.cards {
            var newCardDTO = cardDTO
            newCardDTO.cardType = newType
            let cardsUpdated = updateCard(cards: cards, cardDTO: newCardDTO)
            sessionData.globalPositionDTO.cards = cardsUpdated
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }

    public func updateAccount(accountDTO: AccountDTO, newAlias: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData(), let accounts = sessionData.globalPositionDTO.accounts {
            var newAccountDTO = accountDTO
            newAccountDTO.alias = newAlias
            let accountsUpdated = updateAccount(accounts: accounts, accountDTO: newAccountDTO)
            sessionData.globalPositionDTO.accounts = accountsUpdated
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(accountEasyPayCampaigns: [AccountEasyPayDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.accountEasyPayCampaigns = accountEasyPayCampaigns
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(pendingSolicitudes: [PendingSolicitudeDTO]?) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.pendingSolicitudes = pendingSolicitudes
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(codeOTPPush: ReturnCodeOTPPush?) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.codeOTPPush = codeOTPPush
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(identifier: String, customerContractListDTO: CustomerContractListDTO, httpCode: Int) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.customerContractDictionary[identifier] = customerContractListDTO
            sessionData.checkOnePlanStatusCodeDictionary[identifier] = httpCode
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(aviosDTO: AviosDetailDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.aviosDetail = aviosDTO
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func store(recoveryDTOs: [RecoveryDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.recoveryNotices = recoveryDTOs
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func remove<T>(_ type: T.Type) {
        objc_sync_enter(dataRepository)
        dataRepository.remove(type)
        objc_sync_exit(dataRepository)
    }
    
    private func updateCard(cards: [CardDTO], cardDTO: CardDTO) -> [CardDTO] {
        var cards: [CardDTO] = cards
        if let index = (cards.firstIndex {$0 == cardDTO}) {
            cards[index] = cardDTO
        }
        return cards
    }
    
    private func updateAccount(accounts: [AccountDTO], accountDTO: AccountDTO) -> [AccountDTO] {
        var accounts: [AccountDTO] = accounts
        if let index = (accounts.firstIndex {$0 == accountDTO}) {
            accounts[index] = accountDTO
        }
        return accounts
    }
    
    func updateApplePayStatus(applePayStatus: [String: CardApplePayStatusDTO]) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            applePayStatus.forEach {
                sessionData.cardApplePayStatus[$0.key] = $0.value
            }
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func removeApplePayStatus(for pan: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardApplePayStatus.removeValue(forKey: pan)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func removeLoanDetail(_ loan: LoanDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.loanInfo.removeLoanDetail(contractId: loan.contract?.formattedValue ?? "")
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func removeStockOrderDetail(for key: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.stockInfo.stockOrderDetailsDictionary.removeValue(forKey: key)
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    public func storeGetHistoricalTransferCompleted(_ completed: Bool) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            let _ = sessionData.getHistoricalTransferCompleted = completed
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    /*
     * Get Historical Transfers Completed
     */
    public func getHistoricalTransferCompleted() throws -> Bool {
        if let sessionData = try? getSessionData() {
            return sessionData.getHistoricalTransferCompleted ?? false
        }
        throw BSANIllegalStateException("UserDataDTO nil in DataRepository")
    }
    
    // MARK: - GlobalSessionData
    
    func createGlobalSessionData() {
        let globalSessionData: GlobalSessionData = GlobalSessionData()
        objc_sync_enter(dataRepository)
        dataRepository.store(globalSessionData)
        objc_sync_exit(dataRepository)
    }
    
    func getGlobalSessionData() throws -> GlobalSessionData {
        if let authCredentials = dataRepository.get(GlobalSessionData.self) {
            return authCredentials
        }
        throw BSANIllegalStateException("AuthCredentials nil in DataRepository")
    }
    
    func updateGlobalSessionData(scaInfo: ScaInfo) {
        if let globalSessionData: GlobalSessionData = try? getGlobalSessionData() {
            globalSessionData.scaInfo = scaInfo
            objc_sync_enter(dataRepository)
            dataRepository.store(globalSessionData)
            objc_sync_exit(dataRepository)
        }
    }
    
    // MARK: - Bizum
    
    func storeBizumOperationList(operationList: BizumOperationListDTO, key: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.bizumInfo.historicOperationsDictionary[key] = operationList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func storeBizumMultipleOperationList(operationList: BizumOperationMultiListDTO, key: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.bizumInfo.historicMultipleOperationsDictionary[key] = operationList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func storeBizumContactList(operationList: BizumGetContactsDTO, key: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.bizumInfo.bizumGetContactsDictionary[key] = operationList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func storeBizumCheckPayment(operationList: BizumCheckPaymentDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.bizumInfo.bizumCheckPayment = operationList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func storeBizumOrganizationList(operationList: BizumOrganizationsListDTO, key: String) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.bizumInfo.bizumOrganizationsDictionary[key] = operationList
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func storeBizumRedsysDocument(_ redsysDocument: BizumRedsysDocumentDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.bizumInfo.redsysDocument = redsysDocument
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func store(_ finantialAgregatorDto: FinancialAgregatorDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.financialAgregatorDTO = finantialAgregatorDto
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func store(_ key: String, cardSettlementDetailDTO: CardSettlementDetailDTO) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.cardSettlementDetailInfo.addCardSettlementDetailsCache(
                key,
                cardSettlementDetailDTO: cardSettlementDetailDTO
            )
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
    
    func storeFinanceableCardMovements(_ key: String, financeableList: FinanceableMovementsListDTO, status: MovementStatus) {
        objc_sync_enter(dataRepository)
        if let sessionData = try? getSessionData() {
            sessionData.financeableCardMovementsInfo.addFinanceableCardMovementsCache(
                key,
                financeableList: financeableList,
                status: status
            )
            updateSessionData(sessionData)
        }
        objc_sync_exit(dataRepository)
    }
}

extension BSANDataProvider {
    func get<T>(_ keyPath: KeyPath<SessionData, T>) throws -> T {
        let value: T
        objc_sync_enter(dataRepository)
        do {
            let sessionData = try getSessionData()
            value = sessionData[keyPath: keyPath]
        } catch let error {
            objc_sync_exit(dataRepository)
            throw error
        }
        objc_sync_exit(dataRepository)
        return value
    }
}

// MARK: - BSANDataProviderProtocol

extension BSANDataProvider: BSANDataProviderProtocol {
    public func getAuthCredentialsProvider() throws -> AuthCredentialsProvider {
        if let authCredentials = dataRepository.get(AuthCredentials.self) {
            return authCredentials
        }
        throw BSANIllegalStateException("AuthCredentials nil in DataRepository")
    }
    
    public func getLanguageISO() throws -> String {
        return try self.getBsanHeaderData().languageISO
    }
    
    public func getDialectISO() throws -> String {
        return try self.getBsanHeaderData().dialectISO
    }
}

// MARK: - BSANDemoProviderProtocol

extension BSANDataProvider: BSANDemoProviderProtocol {
    public func setDemoMode(_ isDemo: Bool, _ demoUser: String?) {
        if isDemo, let demoUser = demoUser {
            objc_sync_enter(dataRepository)
            dataRepository.store(DemoMode(demoUser))
            objc_sync_exit(dataRepository)
        } else {
            dataRepository.remove(DemoMode.self)
        }
    }
    
    public func isDemo() -> Bool {
        return dataRepository.get(DemoMode.self) != nil
    }
    
    public func getDemoMode() -> DemoMode? {
        return dataRepository.get(DemoMode.self)
    }
}
