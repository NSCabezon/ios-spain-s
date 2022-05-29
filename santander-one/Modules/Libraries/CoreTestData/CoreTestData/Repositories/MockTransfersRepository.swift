import OpenCombine
import CoreDomain

public final class MockTransfersRepository: TransfersRepository {
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    // TransferType
    
    public func transferType(originAccount: AccountRepresentable, selectedCountry: String, selectedCurrerncy: String) throws -> Result<TransfersType, Error> {
        guard let transferType = self.mockDataInjector.mockDataProvider.transferData.transferType else {
            fatalError()
        }
        return .success(transferType)
    }
    
    // Validate transfer
    
    public func validateGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput) throws -> Result<ValidateAccountTransferRepresentable, Error> {
        fatalError()
    }
    
    public func validateDeferredTransfer(originAcount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        fatalError()
    }
    
    public func validatePeriodicTransfer(originAcount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        fatalError()
    }
    
    // Validate transfer OTP
    
    public func validateGenericTransferOTP(originAccount: AccountRepresentable, nationalTransferInput: NationalTransferInputRepresentable, signature: SignatureRepresentable) throws -> Result<OTPValidationRepresentable, Error> {
        fatalError()
    }
    
    public func validatePeriodicTransferOTP(signature: SignatureRepresentable, dataToken: String) throws -> Result<OTPValidationRepresentable, Error> {
        fatalError()
    }
    
    public func validateDeferredTransferOTP(signature: SignatureRepresentable, dataToken: String) throws -> Result<OTPValidationRepresentable, Error> {
        fatalError()
    }
    
    // Confirm transfer
    
    public func confirmGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput, otpValidation: OTPValidationRepresentable?, otpCode: String?) throws -> Result<TransferConfirmAccountRepresentable, Error> {
        fatalError()
    }
    
    public func confirmDeferredTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String) throws -> Result<Void, Error> {
        fatalError()
    }
    
    public func confirmPeriodicTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String) throws -> Result<Void, Error> {
        fatalError()
    }
    
    // Retrieve transfers
    
    public func getAllTransfers(accounts: [AccountRepresentable]?) throws -> Result<[TransferRepresentable], Error> {
        return .success(self.mockDataInjector.mockDataProvider.transferData.loadEmittedTransfers.transactionDTOs)
    }
    
    public func getTransferDetail(transfer: TransferRepresentable) throws -> Result<TransferRepresentable, Error> {
        return .success(self.mockDataInjector.mockDataProvider.transferData.getEmittedTransferDetail)
    }
    
    public func checkEntityAdhered(genericTransferInput: SendMoneyGenericTransferInput) throws -> Result<Void, Error> {
        fatalError("Conform protocol and implement the function")
    }
    
    public func loadAllUsualTransfers() -> AnyPublisher<[PayeeRepresentable], Error> {
        return Just(
            self.mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers
        )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func noSepaPayeeDetail(of alias: String, recipientType: String) -> AnyPublisher<NoSepaPayeeDetailRepresentable, Error> {
        return Just(
            self.mockDataInjector.mockDataProvider.transferData.noSepaPayeeDetail
        )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

