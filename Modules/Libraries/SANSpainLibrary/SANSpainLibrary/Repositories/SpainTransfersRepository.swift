//
//  SpainTransfersRepository.swift
//  SANSpainLibrary
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

import CoreDomain
import OpenCombine

public protocol SpainTransfersRepository: TransfersRepository {
    func confirmDeferredTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String, trusteerInfo: TrusteerInfoRepresentable?) throws -> Result<Void, Error>
    func confirmGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput, otpValidation: OTPValidationRepresentable?, otpCode: String?, trusteerInfo: TrusteerInfoRepresentable?) throws -> Result<TransferConfirmAccountRepresentable, Error>
    func checkTransferStatus(reference: ReferenceRepresentable) throws -> Result<CheckTransferStatusRepresentable, Error>
    func validateNoSEPATransfer(noSepaTransferInput: SendMoneyNoSEPAInput, validationSwift: ValidationSwiftRepresentable?) throws -> Result<ValidationIntNoSepaRepresentable, Error>
    func getNoSepaTransferDetail(transfer: TransferRepresentable) throws -> Result<NoSepaTransferRepresentable, Error>
    func getNoSepaPayeeDetail(alias: String, recipientType: String) throws -> Result <SPNoSepaPayeeDetailRepresentable, Error>
    func getNoSepaFees() throws -> Result<Data?, Error>
    func validateOtpNoSepa(input: SendMoneyNoSEPAInput, validationIntNoSepa: ValidationIntNoSepaRepresentable, signature: SignatureRepresentable) throws -> Result<OTPValidationRepresentable, Error>
    func confirmSendMoneyNoSepa(input: ConfirmSendMoneyNoSepaInputRepresentable) throws -> Result<ConfirmationNoSepaRepresentable, Error>

    // MARK: Get All Transfers
    
    func loadEmittedTransfers(
        account: AccountRepresentable,
        amountFrom: AmountRepresentable?,
        amountTo: AmountRepresentable?,
        dateFilter: DateFilter,
        pagination: PaginationRepresentable?
    ) -> AnyPublisher<TransferListResponse, Error>
    
    func getAccountTransactions(
        forAccount account: AccountRepresentable,
        pagination: PaginationRepresentable?,
        filter: AccountTransferFilterInput
    ) -> AnyPublisher<TransferListResponse, Error>
}
