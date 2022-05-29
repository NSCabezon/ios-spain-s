//
//  TransfersRepository.swift
//  CoreFoundationLib
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

import Foundation
import OpenCombine

public protocol TransfersRepository: ParseSignature {
    
    // TransferType
    
    func transferType(originAccount: AccountRepresentable, selectedCountry: String, selectedCurrerncy: String) throws -> Result<TransfersType, Error>
    
    // Validate transfer
    
    func validateGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput) throws -> Result<ValidateAccountTransferRepresentable, Error>
    
    func validateDeferredTransfer(originAcount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput) throws -> Result<ValidateScheduledTransferRepresentable, Error>
    
    func validatePeriodicTransfer(originAcount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput) throws -> Result<ValidateScheduledTransferRepresentable, Error>

    func validateNoSEPATransfer(noSepaTransferInput: SendMoneyNoSEPAInput, validationSwift: ValidationSwiftRepresentable?) throws -> Result<ValidationIntNoSepaRepresentable, Error>
    
    func validateSwift(noSepaTransferInput: SendMoneyNoSEPAInput) throws -> Result<ValidationSwiftRepresentable, Error>
    
    // Validate transfer OTP

    func validateGenericTransferOTP(originAccount: AccountRepresentable, nationalTransferInput: NationalTransferInputRepresentable, signature: SignatureRepresentable) throws -> Result<OTPValidationRepresentable, Error>
    
    func validatePeriodicTransferOTP(signature: SignatureRepresentable, dataToken: String) throws -> Result<OTPValidationRepresentable, Error>

    func validateDeferredTransferOTP(signature: SignatureRepresentable, dataToken: String) throws -> Result<OTPValidationRepresentable, Error>

    // Confirm transfer

    func confirmGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput, otpValidation: OTPValidationRepresentable?, otpCode: String?) throws -> Result<TransferConfirmAccountRepresentable, Error>
    
    func confirmDeferredTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String) throws -> Result<Void, Error>
    
    func confirmPeriodicTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String) throws -> Result<Void, Error>

    // Retrieve transfers

    func getAllTransfers(accounts: [AccountRepresentable]?) throws -> Result<[TransferRepresentable], Error>
    func getAllTransfersReactive(accounts: [AccountRepresentable]?) -> AnyPublisher<[TransferRepresentable], Error>

    func getTransferDetail(transfer: TransferRepresentable) throws -> Result<TransferRepresentable, Error>
    
    func loadAllUsualTransfers() -> AnyPublisher<[PayeeRepresentable], Error>
    
    func noSepaPayeeDetail(of alias: String, recipientType: String) -> AnyPublisher<NoSepaPayeeDetailRepresentable, Error>

    // Check entity Adhered
    
    func checkEntityAdhered(genericTransferInput: SendMoneyGenericTransferInput) throws -> Result<Void, Error>
}

public extension TransfersRepository {

    func getAllTransfers(accounts: [AccountRepresentable]?) throws -> Result<[TransferRepresentable], Error> {
        fatalError("Conform protocol and implement the function")
    }
    
    func getAllTransfersReactive(accounts: [AccountRepresentable]?) -> AnyPublisher<[TransferRepresentable], Error> {
        return Future { promise in
            do {
                promise(try getAllTransfers(accounts: accounts))
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func getTransferDetail(transfer: TransferRepresentable) throws -> Result<TransferRepresentable, Error> {
        fatalError("Conform protocol and implement the function")
    }
    
    func checkEntityAdhered(genericTransferInput: SendMoneyGenericTransferInput) throws -> Result<Void, Error> {
        fatalError("Conform protocol and implement the function")
    }
    
    func validateNoSEPATransfer(noSepaTransferInput: SendMoneyNoSEPAInput, validationSwift: ValidationSwiftRepresentable?) throws -> Result<ValidationIntNoSepaRepresentable, Error> {
        fatalError("Conform protocol and implement the function")
    }
    
    func validateSwift(noSepaTransferInput: SendMoneyNoSEPAInput) throws -> Result<ValidationSwiftRepresentable, Error> {
        fatalError("Conform protocol and implement the function")
    }
}
