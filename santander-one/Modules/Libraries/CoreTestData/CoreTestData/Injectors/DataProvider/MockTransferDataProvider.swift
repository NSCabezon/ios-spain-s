import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public class MockTransferDataProvider {
    public var validateUpdateSepaPayee: SignatureWithTokenDTO!
    public var sepaPayeeDetail: SepaPayeeDetailDTO!
    public var validateCreateSepaPayee: SignatureWithTokenDTO!
    public var validateCreateSepaPayeeOTP: OTPValidationDTO!
    public var validateRemoveSepaPayee: SignatureWithTokenDTO!
    public var confirmRemoveSepaPayee: SignatureWithTokenDTO!
    public var validateUpdateSepaPayeeOTP: OTPValidationDTO!
    public var getUsualTransfers: [PayeeDTO]!
    public var validateUsualTransfer: ValidateAccountTransferDTO!
    public var confirmUsualTransfer: TransferConfirmAccountDTO!
    public var getScheduledTransfers: [String : TransferScheduledListDTO]!
    public var loadScheduledTransfers: TransferScheduledListDTO!
    public var getScheduledTransferDetail: TransferScheduledDetailDTO!
    public var validateScheduledTransferOTP: OTPValidationDTO!
    public var modifyPeriodicTransferDetail: ModifyPeriodicTransferDTO!
    public var validateModifyPeriodicTransfer: OTPValidationDTO!
    public var validateDeferredTransferOTP: OTPValidationDTO!
    public var modifyDeferredTransferDetail: ModifyDeferredTransferDTO!
    public var validateModifyDeferredTransfer: OTPValidationDTO!
    public var getEmittedTransfers: [String : TransferEmittedListDTO]!
    public var loadEmittedTransfers: TransferEmittedListDTO!
    public var getEmittedTransferDetail: TransferEmittedDetailDTO!
    public var getAccountTransactions: AccountTransactionsListDTO!
    public var transferType: TransfersType!
    public var validateSwift: ValidationSwiftDTO!
    public var validationIntNoSEPA: ValidationIntNoSepaDTO!
    public var validationOTPIntNoSEPA: OTPValidationDTO!
    public var confirmationIntNoSEPA: ConfirmationNoSEPADTO!
    public var loadEmittedNoSepaTransferDetail: NoSepaTransferEmittedDetailDTO!
    public var validateGenericTransfer: ValidateAccountTransferDTO!
    public var validateGenericTransferOTP: OTPValidationDTO!
    public var confirmGenericTransfer: TransferConfirmAccountDTO!
    public var checkTransferStatus: CheckTransferStatusDTO!
    public var loadAllUsualTransfers: [PayeeDTO]!
    public var noSepaPayeeDetail: NoSepaPayeeDetailDTO!
    public var validateCreateNoSepaPayee: SignatureWithTokenDTO!
    public var validateCreateNoSepaPayeeOTP: OTPValidationDTO!
    public var confirmCreateNoSepaPayee: ConfirmCreateNoSepaPayeeDTO!
    public var validateUpdateNoSepaPayee: SignatureWithTokenDTO!
    public var validateUpdateNoSepaPayeeOTP: OTPValidationDTO!
    public var loadTransferSubTypeCommissions: TransferSubTypeCommissionDTO!
    public var ibansSepa: [String]!
    public var ibansNoSepa: [String]!
    public var fetchContacts: [PayeeDTO]!
}
