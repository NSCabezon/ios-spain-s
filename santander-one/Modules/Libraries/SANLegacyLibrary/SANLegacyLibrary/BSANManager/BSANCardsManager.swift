
import CoreDomain

public protocol BSANCardsManager {
    func getCardTransactionLocation(card: CardDTO, transaction: CardTransactionDTO, transactionDetail: CardTransactionDetailDTO) throws -> BSANResponse<CardMovementLocationDTO>
    func getCardTransactionLocationsList(card: CardDTO) throws -> BSANResponse<CardMovementLocationListDTO>
    func getCardTransactionLocationsListByDate(card: CardDTO, startDate: Date, endDate: Date) throws -> BSANResponse<CardMovementLocationListDTO>
    func getAllCards() throws -> BSANResponse<[CardDTO]>
    func getCardsDataMap() throws -> BSANResponse<[String: CardDataDTO]>
    func getPrepaidsCardsDataMap() throws -> BSANResponse<[String: PrepaidCardDataDTO]>
    func getCardsDetailMap() throws -> BSANResponse<[String: CardDetailDTO]>
    func getCardsWithDetailMap() throws -> BSANResponse<[String: CardDetailDTO]>
    func getCardsBalancesMap() throws -> BSANResponse<[String: CardBalanceDTO]>
    func getTemporallyInactiveCardsMap() throws -> BSANResponse<[String: InactiveCardDTO]>
    func getInactiveCardsMap() throws -> BSANResponse<[String: InactiveCardDTO]>
//    func setCardsData(_ cardDataDTOList: [CardDataDTO])
    func getCardData(_ pan: String) throws -> BSANResponse<CardDataDTO>
    

    //TODO: ESTO SE ELIMINARA CUANDO SE USE UNICAMENTE EL SERVICIO SUPERSPEEDCARDS
    func loadAllCardsData() throws -> BSANResponse<Void>
    func getTemporallyOffCard(pan: String) throws -> BSANResponse<InactiveCardDTO>
    func getInactiveCard(pan: String) throws -> BSANResponse<InactiveCardDTO>
    func loadCardDetail(cardDTO: CardDTO) throws -> BSANResponse<Void>
    func getCardDetail(cardDTO: CardDTO) throws -> BSANResponse<CardDetailDTO>
    func getCardBalance(cardDTO: CardDTO) throws -> BSANResponse<CardBalanceDTO>
    func confirmPayOff(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, amountDTO: AmountDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void>
    func loadPrepaidCardData(cardDTO: CardDTO) throws -> BSANResponse<Void>
    func getPrepaidCardData(cardDTO: CardDTO) throws -> BSANResponse<PrepaidCardDataDTO>
    func validateLoadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO) throws -> BSANResponse<ValidateLoadPrepaidCardDTO>
    func confirmOTPLoadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO,
                                          prepaidCardDataDTO: PrepaidCardDataDTO,
                                          validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO,
                                          otpValidationDTO: OTPValidationDTO?,
                                          otpCode: String?) throws -> BSANResponse<Void>
    func validateUnloadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO) throws -> BSANResponse<ValidateLoadPrepaidCardDTO>
    func confirmOTPUnloadPrepaidCard(cardDTO: CardDTO,
                                            amountDTO: AmountDTO,
                                            accountDTO: AccountDTO,
                                            prepaidCardDataDTO: PrepaidCardDataDTO,
                                            validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO,
                                            otpValidationDTO: OTPValidationDTO?,
                                            otpCode: String?) throws -> BSANResponse<Void>
    func validateOTPPrepaidCard(cardDTO: CardDTO, signatureDTO: SignatureDTO, validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO) throws -> BSANResponse<OTPValidationDTO>
    func getCardDetailToken(cardDTO: CardDTO, cardTokenType: CardTokenType) throws -> BSANResponse<CardDetailTokenDTO>
    func getAllCardTransactions(cardDTO: CardDTO,
                                pagination: PaginationDTO?,
                                searchTerm: String?,
                                dateFilter: DateFilter?,
                                fromAmount: Decimal?,
                                toAmount: Decimal?,
                                movementType: String?,
                                cardOperationType: String?) throws -> BSANResponse<CardTransactionsListDTO>
    func getCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<CardTransactionsListDTO>
    func getCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?, cached: Bool) throws -> BSANResponse<CardTransactionsListDTO>
    func getCardTransactionDetail(cardDTO: CardDTO, cardTransactionDTO: CardTransactionDTO) throws -> BSANResponse<CardTransactionDetailDTO>
    func loadInactiveCards(inactiveCardType: InactiveCardType) throws -> BSANResponse<Void>
    func blockCard(cardDTO: CardDTO, blockText: String, cardBlockType: CardBlockType) throws -> BSANResponse<BlockCardDTO>
    func onOffCard(cardDTO: CardDTO, option: CardBlockType) throws -> BSANResponse<Void>
    func confirmBlockCard(cardDTO: CardDTO, signatureDTO: SignatureDTO, blockText: String, cardBlockType: CardBlockType) throws -> BSANResponse<BlockCardConfirmDTO>
    func activateCard(cardDTO: CardDTO, expirationDate: Date) throws -> BSANResponse<ActivateCardDTO>
    func confirmActivateCard(cardDTO: CardDTO, expirationDate: Date, signatureDTO: SignatureDTO) throws -> BSANResponse<String>
    func prepareDirectMoney(cardDTO: CardDTO) throws -> BSANResponse<DirectMoneyDTO>
    func validateDirectMoney(cardDTO: CardDTO, amountValidatedDTO: AmountDTO) throws -> BSANResponse<DirectMoneyValidatedDTO>
    func confirmDirectMoney(cardDTO: CardDTO, amountValidatedDTO: AmountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func loadCardSuperSpeed(pagination: PaginationDTO?) throws -> BSANResponse<Void>
    func loadCardSuperSpeed(pagination: PaginationDTO?, isNegativeCreditBalanceEnabled: Bool) throws -> BSANResponse<Void>
    func changeCardAlias(cardDTO: CardDTO, newAlias: String) throws -> BSANResponse<Void>
    func validateCVV(cardDTO: CardDTO) throws -> BSANResponse<SCARepresentable>
    func validateCVVOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmCVV(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<NumberCipherDTO>
    func validatePIN(cardDTO: CardDTO, cardDetailTokenDTO: CardDetailTokenDTO) throws -> BSANResponse<SignatureWithTokenDTO>
    func validatePINOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmPIN(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<NumberCipherDTO>
    func getPayLaterData(cardDTO: CardDTO) throws -> BSANResponse<PayLaterDTO>
    func confirmPayLaterData(cardDTO: CardDTO, payLaterDTO: PayLaterDTO, amountDTO: AmountDTO) throws -> BSANResponse<Void>
    func getTransactionDetailEasyPay(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, cardTransactionDTO: CardTransactionDTO, cardTransactionDetailDTO: CardTransactionDetailDTO, easyPayContractTransactionDTO: EasyPayContractTransactionDTO) throws -> BSANResponse<EasyPayDTO>
    func getAllTransactionsEasyPayContract(cardDTO: CardDTO, dateFilter: DateFilter?) throws -> BSANResponse<EasyPayContractTransactionListDTO>
    func getTransactionsEasyPayContract(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<EasyPayContractTransactionListDTO>
    func getFeesEasyPay(cardDTO: CardDTO) throws -> BSANResponse<FeeDataDTO>
    func getAmortizationEasyPay(cardDTO: CardDTO, cardTransactionDTO: CardTransactionDTO, feeDataDTO: FeeDataDTO, numFeesSelected: String, balanceCode: Int, movementIndex: Int) throws -> BSANResponse<EasyPayAmortizationDTO>
    func validateModifyDebitCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, debitLimitDailyAmount: AmountDTO, atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO>
    func validateModifyCreditCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmModifyDebitCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, debitLimitDailyAmount: AmountDTO, atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void>
    func confirmModifyCreditCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void>
    func getCardPendingTransactions(cardDTO: CardDTO, pagination: PaginationDTO?) throws -> BSANResponse<CardPendingTransactionsListDTO>
    func checkCardExtractPdf(cardDTO: CardDTO, dateFilter: DateFilter, isPCAS: Bool) throws -> BSANResponse<DocumentDTO>
    func getPaymentChange(cardDTO: CardDTO) throws -> BSANResponse<ChangePaymentDTO>
    func confirmPaymentChange(cardDTO: CardDTO, input: ChangePaymentMethodConfirmationInput) throws -> BSANResponse<Void>
    func loadApplePayStatus(for addedPasses: [String]) throws -> BSANResponse<Void>
    func getApplePayStatus(for card: CardDTO, expirationDate: DateModel) throws -> BSANResponse<CardApplePayStatusDTO>
    func validateApplePay(card: CardDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<ApplePayValidationDTO>
    func confirmApplePay(card: CardDTO, cardDetail: CardDetailDTO, otpValidation: OTPValidationDTO, otpCode: String, encryptionScheme: String, publicCertificates: [Data], nonce: Data, nonceSignature: Data) throws -> BSANResponse<ApplePayConfirmationDTO>
    func getCardApplePayStatus() throws -> BSANResponse<[String: CardApplePayStatusDTO]>
    func getCardSettlementDetail(card: CardDTO, date: Date) throws -> BSANResponse<CardSettlementDetailDTO>
    func getCardSettlementListMovements(card: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementDTO]>
    func getCardSettlementListMovementsByContract(card: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementWithPANDTO]>
    func confirmationEasyPay(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<Void>
    func getEasyPayFees(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<FeesInfoDTO>
    func getEasyPayFinanceableList(input: FinanceableListParameters) throws -> BSANResponse<FinanceableMovementsListDTO>
    func getCardSubscriptionsList(input: SubscriptionsListParameters) throws -> BSANResponse<CardSubscriptionsListDTO>
    func getCardSubscriptionsHistorical(input: SubscriptionsHistoricalInputParams) throws -> BSANResponse<CardSubscriptionsHistoricalListDTO>
    func getCardSubscriptionsGraphData(input: SubscriptionsGraphDataInputParams) throws -> BSANResponse<CardSubscriptionsGraphDataDTO>
    func getFractionablePurchaseDetail(input: FractionablePurchaseDetailParameters) throws -> BSANResponse<FinanceableMovementDetailDTO>
}
