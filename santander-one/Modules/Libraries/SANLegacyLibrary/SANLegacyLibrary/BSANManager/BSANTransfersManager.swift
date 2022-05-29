import Foundation
import CoreDomain

public protocol BSANTransfersManager {
    func loadUsualTransfersOld() throws -> BSANResponse<Void>
    func loadUsualTransfers() throws -> BSANResponse<Void>
    func sepaPayeeDetail(of alias: String, recipientType: String) throws -> BSANResponse<SepaPayeeDetailDTO>
    func validateCreateSepaPayee(alias: String,
                                 recipientType: FavoriteRecipientType?,
                                 beneficiary: String,
                                 iban: IBANDTO?,
                                 serviceType: String?,
                                 contractType: String?,
                                 accountIdType: String?,
                                 accountId: String?,
                                 streetName: String?,
                                 townName: String?,
                                 location: String?,
                                 country: String?,
                                 operationDate: Date?) throws -> BSANResponse<SignatureWithTokenDTO?>
    func validateCreateSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmCreateSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void>
    func validateRemoveSepaPayee(ofAlias alias: String, payeeCode: String, recipientType: String, accountType: String) throws -> BSANResponse<SignatureWithTokenDTO>
    func confirmRemoveSepaPayee(payeeId: String?, signatureWithTokenDTO: SignatureWithTokenDTO?) throws -> BSANResponse<SignatureWithTokenDTO?>
    func validateUpdateSepaPayee(payeeId: String?, payee: PayeeRepresentable?, newCurrencyDTO: CurrencyDTO?, newBeneficiaryBAOName: String?, newIban: IBANDTO?) throws -> BSANResponse<SignatureWithTokenDTO>
    func validateUpdateSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmUpdateSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void>
    func getUsualTransfers() throws -> BSANResponse<[PayeeDTO]>
    func validateUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable) throws -> BSANResponse<ValidateAccountTransferDTO>
    func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO) throws -> BSANResponse<TransferConfirmAccountDTO>
    func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO>
    
// MARK: -
// MARK: Generic Scheduled Transfers
    
    func getScheduledTransfers() throws -> BSANResponse<[String : TransferScheduledListDTO]>
    func loadScheduledTransfers(account: AccountDTO, amountFrom: AmountDTO?, amountTo: AmountDTO?, pagination: PaginationDTO?) throws -> BSANResponse<TransferScheduledListDTO>
    func getScheduledTransferDetail(account: AccountDTO, transferScheduledDTO: TransferScheduledDTO) throws -> BSANResponse<TransferScheduledDetailDTO>
    func loadScheduledTransferDetail(account: AccountDTO, transferScheduledDTO: TransferScheduledDTO) throws -> BSANResponse<Void>
    func removeScheduledTransfer(accountDTO: AccountDTO, orderIbanDTO: IBANDTO, transferScheduledDTO: TransferScheduledDTO,
                                        signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void>
    func getHistoricalTransferCompleted() throws -> Bool
    func storeGetHistoricalTransferCompleted(_ completed: Bool) throws
    
// MARK: -
// MARK: Scheduled Transfers
    
    func validateScheduledTransfer(originAcount: AccountDTO, scheduledTransferInput: ScheduledTransferInput) throws -> BSANResponse<ValidateScheduledTransferDTO>
    func validateScheduledTransferOTP(signatureDTO: SignatureDTO, dataToken: String) throws -> BSANResponse<OTPValidationDTO>
    func confirmScheduledTransfer(originAccountDTO: AccountDTO, scheduledTransferInput: ScheduledTransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String) throws -> BSANResponse<ValidateScheduledTransferDTO>
    func modifyPeriodicTransferDetail(originAccountDTO: AccountDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<ModifyPeriodicTransferDTO>
    func validateModifyPeriodicTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyPeriodicTransferDTO: ModifyPeriodicTransferDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmModifyPeriodicTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyPeriodicTransferDTO: ModifyPeriodicTransferDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO, otpValidationDTO: OTPValidationDTO, otpCode: String, scheduledDayType: ScheduledDayDTO) throws -> BSANResponse<Void>
    
// MARK: Deferred Transfer
    
    func validateDeferredTransfer(originAcount: AccountDTO, scheduledTransferInput: ScheduledTransferInput) throws -> BSANResponse<ValidateScheduledTransferDTO>
    func validateDeferredTransferOTP(signatureDTO: SignatureDTO, dataToken: String) throws -> BSANResponse<OTPValidationDTO>
    func confirmDeferredTransfer(originAccountDTO: AccountDTO, scheduledTransferInput: ScheduledTransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void>
    func modifyDeferredTransferDetail(originAccountDTO: AccountDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<ModifyDeferredTransferDTO>
    func validateModifyDeferredTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyDeferredTransferDTO: ModifyDeferredTransferDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmModifyDeferredTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyDeferredTransferDTO: ModifyDeferredTransferDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO, otpValidationDTO: OTPValidationDTO, otpCode: String, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void>

// MARK: Emitted Transfers
    
    func getEmittedTransfers() throws -> BSANResponse<[String : TransferEmittedListDTO]>
    func loadEmittedTransfers(account: AccountRepresentable, amountFrom: AmountRepresentable?, amountTo: AmountRepresentable?, dateFilter: DateFilter, pagination: PaginationRepresentable?) throws -> BSANResponse<TransferEmittedListDTO>
    func getEmittedTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<TransferEmittedDetailDTO>
    func loadEmittedTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<Void>
    
// MARK: - Received transfers
    
    func getAccountTransactions(forAccount account: AccountRepresentable, pagination: PaginationRepresentable?, filter: AccountTransferFilterInput) throws -> BSANResponse<AccountTransactionsListDTO>
    
// MARK: -
// MARK: No SEPA Transfer
    
    func transferType(originAccountDTO: AccountDTO, selectedCountry: String, selectedCurrerncy: String) throws -> BSANResponse<TransfersType>
    func validateSwift(noSepaTransferInput: NoSEPATransferInput) throws -> BSANResponse<ValidationSwiftDTO>
    func validationIntNoSEPA(noSepaTransferInput: NoSEPATransferInput, validationSwiftDTO: ValidationSwiftDTO?) throws -> BSANResponse<ValidationIntNoSepaDTO>
    func validationOTPIntNoSEPA(validationIntNoSepaDTO: ValidationIntNoSepaDTO, noSepaTransferInput: NoSEPATransferInput) throws -> BSANResponse<OTPValidationDTO>
    func confirmationIntNoSEPA(validationIntNoSepaDTO: ValidationIntNoSepaDTO, validationSwiftDTO: ValidationSwiftDTO?, noSepaTransferInput: NoSEPATransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String, countryCode: String?, aliasPayee: String?, isNewPayee: Bool, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<ConfirmationNoSEPADTO>
    func loadEmittedNoSepaTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<NoSepaTransferEmittedDetailDTO>

// MARK: -
// MARK: Generic Transfer
    
    func validateGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO>
    func validateSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO>
    func validateGenericTransferOTP(originAccountDTO: AccountDTO, nationalTransferInput: NationalTransferInput, signatureDTO: SignatureDTO) throws -> BSANResponse<OTPValidationDTO>
    func validateSanKeyTransferOTP(originAccountDTO: AccountDTO, nationalTransferInput: NationalTransferInput, signatureDTO: SignatureDTO?, tokenSteps: String, footPrint: String?, deviceToken: String?) throws -> BSANResponse<SanKeyOTPValidationDTO>
    func confirmGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<TransferConfirmAccountDTO>
    func confirmGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO>
    func validateAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput) throws -> BSANResponse<TransferAccountDTO>
    func confirmAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func confirmAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void>
    func checkEntityAdhered(genericTransferInput: GenericTransferInputDTO) throws -> BSANResponse<Void>
    func checkTransferStatus(referenceDTO: ReferenceDTO) throws -> BSANResponse<CheckTransferStatusDTO>
    func loadAllUsualTransfers() throws -> BSANResponse<[PayeeDTO]>
    func noSepaPayeeDetail(of alias: String, recipientType: String) throws -> BSANResponse<NoSepaPayeeDetailDTO>
    func validateCreateNoSepaPayee(newAlias: String, newCurrency: CurrencyDTO?, noSepaPayeeDTO: NoSepaPayeeDTO?) throws -> BSANResponse<SignatureWithTokenDTO>
    func validateCreateNoSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmCreateNoSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<ConfirmCreateNoSepaPayeeDTO>
    func validateUpdateNoSepaPayee(alias: String, noSepaPayeeDTO: NoSepaPayeeDTO?, newCurrencyDTO: CurrencyDTO?) throws -> BSANResponse<SignatureWithTokenDTO>
    func validateUpdateNoSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmUpdateNoSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void>
    func loadTransferSubTypeCommissions(originAccount: AccountDTO, destinationAccount: IBANDTO, amount: AmountDTO, beneficiary: String, concept: String) throws -> BSANResponse<TransferSubTypeCommissionDTO>
    func confirmSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, tokenSteps: String) throws -> BSANResponse<TransferConfirmAccountDTO>
    func confirmSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, trusteerInfo: TrusteerInfoDTO?, tokenSteps: String) throws -> BSANResponse<TransferConfirmAccountDTO>
}

public extension BSANTransfersManager {
    func validateSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        BSANErrorResponse(nil)
    }
    func validateSanKeyTransferOTP(originAccountDTO: AccountDTO, nationalTransferInput: NationalTransferInput, signatureDTO: SignatureDTO?, tokenSteps: String, footPrint: String?, deviceToken: String?) throws -> BSANResponse<SanKeyOTPValidationDTO> {
        BSANErrorResponse(nil)
    }
    func confirmSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, tokenSteps: String) throws -> BSANResponse<TransferConfirmAccountDTO> {
        BSANErrorResponse(nil)
    }
    func confirmSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, trusteerInfo: TrusteerInfoDTO?, tokenSteps: String) throws -> BSANResponse<TransferConfirmAccountDTO> {
        BSANErrorResponse(nil)
    }

    func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO) throws -> BSANResponse<TransferConfirmAccountDTO> {
        BSANErrorResponse(nil)
    }

    func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        BSANErrorResponse(nil)
    }
}
