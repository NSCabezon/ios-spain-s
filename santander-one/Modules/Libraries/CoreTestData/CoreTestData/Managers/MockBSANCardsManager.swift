import SANLegacyLibrary
import CoreDomain

struct MockBSANCardsManager: BSANCardsManager {

    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func onOffCard(cardDTO: CardDTO, option: CardBlockType) throws -> BSANResponse<Void> {
        fatalError()
    }

    func checkCardExtractPdf(cardDTO: CardDTO, dateFilter: DateFilter, isPCAS: Bool) throws -> BSANResponse<DocumentDTO> {
        fatalError()
    }
    
    func getCardTransactionLocation(card: CardDTO, transaction: CardTransactionDTO, transactionDetail: CardTransactionDetailDTO) throws -> BSANResponse<CardMovementLocationDTO> {
        fatalError()
    }
    
    func getCardTransactionLocationsList(card: CardDTO) throws -> BSANResponse<CardMovementLocationListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardMovementLocationListDTO
        return BSANOkResponse(dto)
    }
    
    func getCardTransactionLocationsListByDate(card: CardDTO, startDate: Date, endDate: Date) throws -> BSANResponse<CardMovementLocationListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardMovementLocationListDTO
        return BSANOkResponse(dto)
    }
    
    func getAllCards() throws -> BSANResponse<[CardDTO]> {
        fatalError()
    }
    
    func getCardsDataMap() throws -> BSANResponse<[String : CardDataDTO]> {
        fatalError()
    }
    
    func getPrepaidsCardsDataMap() throws -> BSANResponse<[String : PrepaidCardDataDTO]> {
        fatalError()
    }
    
    func getCardsDetailMap() throws -> BSANResponse<[String : CardDetailDTO]> {
        fatalError()
    }
    
    func getCardsWithDetailMap() throws -> BSANResponse<[String : CardDetailDTO]> {
        fatalError()
    }
    
    func getCardsBalancesMap() throws -> BSANResponse<[String : CardBalanceDTO]> {
        fatalError()
    }
    
    func getTemporallyInactiveCardsMap() throws -> BSANResponse<[String : InactiveCardDTO]> {
        fatalError()
    }
    
    func getInactiveCardsMap() throws -> BSANResponse<[String : InactiveCardDTO]> {
        fatalError()
    }
    
    func getCardData(_ pan: String) throws -> BSANResponse<CardDataDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardData
        return BSANOkResponse(dto)
    }
    
    func loadAllCardsData() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getTemporallyOffCard(pan: String) throws -> BSANResponse<InactiveCardDTO> {
        fatalError()
    }
    
    func getInactiveCard(pan: String) throws -> BSANResponse<InactiveCardDTO> {
        fatalError()
    }
    
    func loadCardDetail(cardDTO: CardDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getCardDetail(cardDTO: CardDTO) throws -> BSANResponse<CardDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardDetail
        return BSANOkResponse(dto)
    }
    
    func getCardBalance(cardDTO: CardDTO) throws -> BSANResponse<CardBalanceDTO> {
        fatalError()
    }
    
    func confirmPayOff(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, amountDTO: AmountDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func loadPrepaidCardData(cardDTO: CardDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getPrepaidCardData(cardDTO: CardDTO) throws -> BSANResponse<PrepaidCardDataDTO> {
        fatalError()
    }
    
    func validateLoadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO) throws -> BSANResponse<ValidateLoadPrepaidCardDTO> {
        fatalError()
    }
    
    func confirmOTPLoadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO, validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func validateUnloadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO) throws -> BSANResponse<ValidateLoadPrepaidCardDTO> {
        fatalError()
    }
    
    func confirmOTPUnloadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO, validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func validateOTPPrepaidCard(cardDTO: CardDTO, signatureDTO: SignatureDTO, validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func getCardDetailToken(cardDTO: CardDTO, cardTokenType: CardTokenType) throws -> BSANResponse<CardDetailTokenDTO> {
        fatalError()
    }
    
    func getAllCardTransactions(cardDTO: CardDTO,
                                searchTerm: String?,
                                dateFilter: DateFilter?,
                                fromAmount: Decimal?,
                                toAmount: Decimal?,
                                movementType: String?,
                                cardOperationType: String?) throws -> BSANResponse<CardTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardTransactionsList
        return BSANOkResponse(dto)
    }
    
    func getAllCardTransactions(cardDTO: CardDTO, dateFilter: DateFilter?) throws -> BSANResponse<CardTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardTransactionsList
        return BSANOkResponse(dto)
    }
    
    func getCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<CardTransactionsListDTO> {
        fatalError()
    }
    
    func getCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?, cached: Bool) throws -> BSANResponse<CardTransactionsListDTO> {
        fatalError()
    }
    
    func getCardTransactionDetail(cardDTO: CardDTO, cardTransactionDTO: CardTransactionDTO) throws -> BSANResponse<CardTransactionDetailDTO> {
        fatalError()
    }
    
    func loadInactiveCards(inactiveCardType: InactiveCardType) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func blockCard(cardDTO: CardDTO, blockText: String, cardBlockType: CardBlockType) throws -> BSANResponse<BlockCardDTO> {
        fatalError()
    }
    
    func confirmBlockCard(cardDTO: CardDTO, signatureDTO: SignatureDTO, blockText: String, cardBlockType: CardBlockType) throws -> BSANResponse<BlockCardConfirmDTO> {
        fatalError()
    }
    
    func activateCard(cardDTO: CardDTO, expirationDate: Date) throws -> BSANResponse<ActivateCardDTO> {
        fatalError()
    }
    
    func confirmActivateCard(cardDTO: CardDTO, expirationDate: Date, signatureDTO: SignatureDTO) throws -> BSANResponse<String> {
        fatalError()
    }
    
    func prepareDirectMoney(cardDTO: CardDTO) throws -> BSANResponse<DirectMoneyDTO> {
        fatalError()
    }
    
    func validateDirectMoney(cardDTO: CardDTO, amountValidatedDTO: AmountDTO) throws -> BSANResponse<DirectMoneyValidatedDTO> {
        fatalError()
    }
    
    func confirmDirectMoney(cardDTO: CardDTO, amountValidatedDTO: AmountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func loadCardSuperSpeed(pagination: PaginationDTO?) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func loadCardSuperSpeed(pagination: PaginationDTO?, isNegativeCreditBalanceEnabled: Bool) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func changeCardAlias(cardDTO: CardDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func validateCVV(cardDTO: CardDTO) throws -> BSANResponse<SCARepresentable> {
        fatalError()
    }
    
    func validateCVVOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func confirmCVV(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<NumberCipherDTO> {
        fatalError()
    }
    
    func validatePIN(cardDTO: CardDTO, cardDetailTokenDTO: CardDetailTokenDTO) throws -> BSANResponse<SignatureWithTokenDTO> {
        fatalError()
    }
    
    func validatePINOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func confirmPIN(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<NumberCipherDTO> {
        fatalError()
    }
    
    func getPayLaterData(cardDTO: CardDTO) throws -> BSANResponse<PayLaterDTO> {
        fatalError()
    }
    
    func confirmPayLaterData(cardDTO: CardDTO, payLaterDTO: PayLaterDTO, amountDTO: AmountDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getTransactionDetailEasyPay(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, cardTransactionDTO: CardTransactionDTO, cardTransactionDetailDTO: CardTransactionDetailDTO, easyPayContractTransactionDTO: EasyPayContractTransactionDTO) throws -> BSANResponse<EasyPayDTO> {
        fatalError()
    }
    
    func getAllTransactionsEasyPayContract(cardDTO: CardDTO, dateFilter: DateFilter?) throws -> BSANResponse<EasyPayContractTransactionListDTO> {
        fatalError()
    }
    
    func getTransactionsEasyPayContract(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<EasyPayContractTransactionListDTO> {
        fatalError()
    }
    
    func getFeesEasyPay(cardDTO: CardDTO) throws -> BSANResponse<FeeDataDTO> {
        fatalError()
    }
    
    func getAmortizationEasyPay(cardDTO: CardDTO, cardTransactionDTO: CardTransactionDTO, feeDataDTO: FeeDataDTO, numFeesSelected: String, balanceCode: Int, movementIndex: Int) throws -> BSANResponse<EasyPayAmortizationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getEasyPayAmortization
        return BSANOkResponse(dto)
    }
    
    func validateModifyDebitCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, debitLimitDailyAmount: AmountDTO, atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func validateModifyCreditCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func confirmModifyDebitCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, debitLimitDailyAmount: AmountDTO, atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func confirmModifyCreditCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getCardPendingTransactions(cardDTO: CardDTO, pagination: PaginationDTO?) throws -> BSANResponse<CardPendingTransactionsListDTO> {
        fatalError()
    }
    
    func getPaymentChange(cardDTO: CardDTO) throws -> BSANResponse<ChangePaymentDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getChangePayment
        return BSANOkResponse(dto)
    }
    
    func confirmPaymentChange(cardDTO: CardDTO, input: ChangePaymentMethodConfirmationInput) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func loadApplePayStatus(for addedPasses: [String]) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getApplePayStatus(for card: CardDTO, expirationDate: DateModel) throws -> BSANResponse<CardApplePayStatusDTO> {
        fatalError()
    }
    
    func validateApplePay(card: CardDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<ApplePayValidationDTO> {
        fatalError()
    }
    
    func confirmApplePay(card: CardDTO, cardDetail: CardDetailDTO, otpValidation: OTPValidationDTO, otpCode: String, encryptionScheme: String, publicCertificates: [Data], nonce: Data, nonceSignature: Data) throws -> BSANResponse<ApplePayConfirmationDTO> {
        fatalError()
    }
    
    func getCardApplePayStatus() throws -> BSANResponse<[String : CardApplePayStatusDTO]> {
        fatalError()
    }
    
    func getCardSettlementDetail(card: CardDTO, date: Date) throws -> BSANResponse<CardSettlementDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardSettlementDetail
        return BSANOkResponse(dto)
    }
    
    func getCardSettlementListMovements(card: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardSettlementMovements
        return BSANOkResponse(dto)
    }
    
    func getCardSettlementListMovementsByContract(card: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementWithPANDTO]> {
        fatalError()
    }
    
    func confirmationEasyPay(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getEasyPayFees(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<FeesInfoDTO> {
        fatalError()
    }
    
    func getEasyPayFinanceableList(input: FinanceableListParameters) throws -> BSANResponse<FinanceableMovementsListDTO> {
        fatalError()
    }
    
    func getCardSubscriptionsList(input: SubscriptionsListParameters) throws -> BSANResponse<CardSubscriptionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardSubscriptionsList
        return BSANOkResponse(dto)
    }
    
    func getCardSubscriptionsHistorical(input: SubscriptionsHistoricalInputParams) throws -> BSANResponse<CardSubscriptionsHistoricalListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardSubscriptionsHistoricalList
        return BSANOkResponse(dto)
    }
    
    func getCardSubscriptionsGraphData(input: SubscriptionsGraphDataInputParams) throws -> BSANResponse<CardSubscriptionsGraphDataDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardSubscriptionsGraphData
        return BSANOkResponse(dto)
    }
    
    func getFractionablePurchaseDetail(input: FractionablePurchaseDetailParameters) throws -> BSANResponse<FinanceableMovementDetailDTO> {
        guard !input.movID.isEmpty && !input.pan.isEmpty else { return BSANErrorResponse(nil) }
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getFinanceableMovementDetail
        return BSANOkResponse(dto)
    }
    
    func getAllCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, searchTerm: String?, dateFilter: DateFilter?, fromAmount: Decimal?, toAmount: Decimal?, movementType: String?, cardOperationType: String?) throws -> BSANResponse<CardTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.cardsData.getCardTransactionsList
        return BSANOkResponse(dto)
    }
}
