
public struct ConfirmOTPInternalTransferUseCaseInput {
    public let originAccount: AccountEntity?
    public let destinationAccount: AccountEntity?
    public let time: TransferTime?
    public let otpValidation: OTPValidationEntity?
    public let code: String?
    public let concept: String?
    public let scheduledTransfer: ValidateScheduledTransferEntity?
    public let amount: AmountEntity?
    
    public init(originAccount: AccountEntity?, destinationAccount: AccountEntity?, time: TransferTime?, otpValidation: OTPValidationEntity?, code: String?, concept: String?, scheduledTransfer: ValidateScheduledTransferEntity?, amount: AmountEntity?) {
        self.originAccount = originAccount
        self.destinationAccount = destinationAccount
        self.time = time
        self.otpValidation = otpValidation
        self.code = code
        self.concept = concept
        self.scheduledTransfer = scheduledTransfer
        self.amount = amount
    }
}
