import SANLegacyLibrary
import CoreDomain

struct MockBSANTransfersManager: BSANTransfersManager {
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func validateUpdateSepaPayee(payeeId: String?, payee: PayeeRepresentable?, newCurrencyDTO: CurrencyDTO?, newBeneficiaryBAOName: String?, newIban: IBANDTO?) throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateUpdateSepaPayee
        return BSANOkResponse(dto)
    }
    
    
    func loadUsualTransfersOld() throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func loadUsualTransfers() throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func sepaPayeeDetail(of alias: String, recipientType: String) throws -> BSANResponse<SepaPayeeDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.sepaPayeeDetail
        return BSANOkResponse(dto)
    }
    
    func validateCreateSepaPayee(alias: String, recipientType: FavoriteRecipientType?, beneficiary: String, iban: IBANDTO?, serviceType: String?, contractType: String?, accountIdType: String?, accountId: String?, streetName: String?, townName: String?, location: String?, country: String?, operationDate: Date?) throws -> BSANResponse<SignatureWithTokenDTO?> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateCreateSepaPayee
        return BSANOkResponse(dto)
    }
    
    func validateCreateSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateCreateSepaPayeeOTP
        return BSANOkResponse(dto)
    }
    
    func confirmCreateSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func validateRemoveSepaPayee(ofAlias alias: String, payeeCode: String, recipientType: String, accountType: String) throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateRemoveSepaPayee
        return BSANOkResponse(dto)
    }
    
    func confirmRemoveSepaPayee(payeeId: String?, signatureWithTokenDTO: SignatureWithTokenDTO?) throws -> BSANResponse<SignatureWithTokenDTO?> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmRemoveSepaPayee
        return BSANOkResponse(dto)
    }
    
    func validateUpdateSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateUpdateSepaPayeeOTP
        return BSANOkResponse(dto)
    }
    
    func confirmUpdateSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func getUsualTransfers() throws -> BSANResponse<[PayeeDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.getUsualTransfers
        return BSANOkResponse(dto)
    }
    
    func validateUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable) throws -> BSANResponse<ValidateAccountTransferDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateUsualTransfer
        return BSANOkResponse(dto)
    }
    
    func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO) throws -> BSANResponse<TransferConfirmAccountDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmUsualTransfer
        return BSANOkResponse(dto)
    }

    func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmUsualTransfer
        return BSANOkResponse(dto)
    }

    func getScheduledTransfers() throws -> BSANResponse<[String : TransferScheduledListDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.getScheduledTransfers
        return BSANOkResponse(dto)
    }
    
    func loadScheduledTransfers(account: AccountDTO, amountFrom: AmountDTO?, amountTo: AmountDTO?, pagination: PaginationDTO?) throws -> BSANResponse<TransferScheduledListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.loadScheduledTransfers
        return BSANOkResponse(dto)
    }
    
    func getScheduledTransferDetail(account: AccountDTO, transferScheduledDTO: TransferScheduledDTO) throws -> BSANResponse<TransferScheduledDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.getScheduledTransferDetail
        return BSANOkResponse(dto)
    }
    
    func loadScheduledTransferDetail(account: AccountDTO, transferScheduledDTO: TransferScheduledDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func removeScheduledTransfer(accountDTO: AccountDTO, orderIbanDTO: IBANDTO, transferScheduledDTO: TransferScheduledDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func getHistoricalTransferCompleted() throws -> Bool {
        return true
    }
    
    func storeGetHistoricalTransferCompleted(_ completed: Bool) throws {
    }
    
    func validateScheduledTransfer(originAcount: AccountDTO, scheduledTransferInput: ScheduledTransferInput) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        fatalError()
    }
    
    func validateScheduledTransferOTP(signatureDTO: SignatureDTO, dataToken: String) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateScheduledTransferOTP
        return BSANOkResponse(dto)
    }
    
    func confirmScheduledTransfer(originAccountDTO: AccountDTO, scheduledTransferInput: ScheduledTransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        fatalError()
    }
    
    func modifyPeriodicTransferDetail(originAccountDTO: AccountDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<ModifyPeriodicTransferDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.modifyPeriodicTransferDetail
        return BSANOkResponse(dto)
    }
    
    func validateModifyPeriodicTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyPeriodicTransferDTO: ModifyPeriodicTransferDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateModifyPeriodicTransfer
        return BSANOkResponse(dto)
    }
    
    func confirmModifyPeriodicTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyPeriodicTransferDTO: ModifyPeriodicTransferDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO, otpValidationDTO: OTPValidationDTO, otpCode: String, scheduledDayType: ScheduledDayDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func validateDeferredTransfer(originAcount: AccountDTO, scheduledTransferInput: ScheduledTransferInput) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        fatalError()
    }
    
    func validateDeferredTransferOTP(signatureDTO: SignatureDTO, dataToken: String) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateDeferredTransferOTP
        return BSANOkResponse(dto)
    }
    
    func confirmDeferredTransfer(originAccountDTO: AccountDTO, scheduledTransferInput: ScheduledTransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func modifyDeferredTransferDetail(originAccountDTO: AccountDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<ModifyDeferredTransferDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.modifyDeferredTransferDetail
        return BSANOkResponse(dto)
    }
    
    func validateModifyDeferredTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyDeferredTransferDTO: ModifyDeferredTransferDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateModifyDeferredTransfer
        return BSANOkResponse(dto)
    }
    
    func confirmModifyDeferredTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyDeferredTransferDTO: ModifyDeferredTransferDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO, otpValidationDTO: OTPValidationDTO, otpCode: String, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func getEmittedTransfers() throws -> BSANResponse<[String : TransferEmittedListDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.getEmittedTransfers
        return BSANOkResponse(dto)
    }
    
    func loadEmittedTransfers(account: AccountRepresentable, amountFrom: AmountRepresentable?, amountTo: AmountRepresentable?, dateFilter: DateFilter, pagination: PaginationRepresentable?) throws -> BSANResponse<TransferEmittedListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.loadEmittedTransfers
        return BSANOkResponse(dto)
    }
    
    func getEmittedTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<TransferEmittedDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.getEmittedTransferDetail
        return BSANOkResponse(dto)
    }
    
    func loadEmittedTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func getAccountTransactions(forAccount account: AccountRepresentable, pagination: PaginationRepresentable?, filter: AccountTransferFilterInput) throws -> BSANResponse<AccountTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.getAccountTransactions
        return BSANOkResponse(dto)
    }
    
    func transferType(originAccountDTO: AccountDTO, selectedCountry: String, selectedCurrerncy: String) throws -> BSANResponse<TransfersType> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.transferType
        return BSANOkResponse(dto)
    }
    
    func validateSwift(noSepaTransferInput: NoSEPATransferInput) throws -> BSANResponse<ValidationSwiftDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateSwift
        return BSANOkResponse(dto)
    }
    
    func validationIntNoSEPA(noSepaTransferInput: NoSEPATransferInput, validationSwiftDTO: ValidationSwiftDTO?) throws -> BSANResponse<ValidationIntNoSepaDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validationIntNoSEPA
        return BSANOkResponse(dto)
    }
    
    func validationOTPIntNoSEPA(validationIntNoSepaDTO: ValidationIntNoSepaDTO, noSepaTransferInput: NoSEPATransferInput) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validationOTPIntNoSEPA
        return BSANOkResponse(dto)
    }
    
    func confirmationIntNoSEPA(validationIntNoSepaDTO: ValidationIntNoSepaDTO, validationSwiftDTO: ValidationSwiftDTO?, noSepaTransferInput: NoSEPATransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String, countryCode: String?, aliasPayee: String?, isNewPayee: Bool, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<ConfirmationNoSEPADTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmationIntNoSEPA
        return BSANOkResponse(dto)
    }
    
    func loadEmittedNoSepaTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<NoSepaTransferEmittedDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.loadEmittedNoSepaTransferDetail
        return BSANOkResponse(dto)
    }
    
    func validateGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateGenericTransfer
        return BSANOkResponse(dto)
    }
    
    func validateGenericTransferOTP(originAccountDTO: AccountDTO, nationalTransferInput: NationalTransferInput, signatureDTO: SignatureDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateGenericTransferOTP
        return BSANOkResponse(dto)
    }
    
    func confirmGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmGenericTransfer
        return BSANOkResponse(dto)
    }
    
    func confirmGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmGenericTransfer
        return BSANOkResponse(dto)
    }
    
    func validateAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput) throws -> BSANResponse<TransferAccountDTO> {
        fatalError()
    }
    
    func confirmAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func confirmAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func checkEntityAdhered(genericTransferInput: GenericTransferInputDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func checkTransferStatus(referenceDTO: ReferenceDTO) throws -> BSANResponse<CheckTransferStatusDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.checkTransferStatus
        return BSANOkResponse(dto)
    }
    
    func loadAllUsualTransfers() throws -> BSANResponse<[PayeeDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers
        return BSANOkResponse(dto)
    }
    
    func noSepaPayeeDetail(of alias: String, recipientType: String) throws -> BSANResponse<NoSepaPayeeDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.noSepaPayeeDetail
        return BSANOkResponse(dto)
    }
    
    func validateCreateNoSepaPayee(newAlias: String, newCurrency: CurrencyDTO?, noSepaPayeeDTO: NoSepaPayeeDTO?) throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateCreateNoSepaPayee
        return BSANOkResponse(dto)
    }
    
    func validateCreateNoSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateCreateNoSepaPayeeOTP
        return BSANOkResponse(dto)
    }
    
    func confirmCreateNoSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<ConfirmCreateNoSepaPayeeDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.confirmCreateNoSepaPayee
        return BSANOkResponse(dto)
    }
    
    func validateUpdateNoSepaPayee(alias: String, noSepaPayeeDTO: NoSepaPayeeDTO?, newCurrencyDTO: CurrencyDTO?) throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateUpdateNoSepaPayee
        return BSANOkResponse(dto)
    }
    
    func validateUpdateNoSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.validateUpdateNoSepaPayeeOTP
        return BSANOkResponse(dto)
    }
    
    func confirmUpdateNoSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func loadTransferSubTypeCommissions(originAccount: AccountDTO, destinationAccount: IBANDTO, amount: AmountDTO, beneficiary: String, concept: String) throws -> BSANResponse<TransferSubTypeCommissionDTO> {
        let dto = self.mockDataInjector.mockDataProvider.transferData.loadTransferSubTypeCommissions
        return BSANOkResponse(dto)
    }
}
