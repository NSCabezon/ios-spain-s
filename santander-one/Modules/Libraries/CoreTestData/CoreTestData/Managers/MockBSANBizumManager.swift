import SANLegacyLibrary

public struct MockBSANBizumManager: BSANBizumManager {
        
    public func checkPayment(defaultXPAN: String) throws -> BSANResponse<BizumCheckPaymentDTO> {
        fatalError()
    }
    
    public func getContacts(_ input: BizumGetContactsInputParams) throws -> BSANResponse<BizumGetContactsDTO> {
        fatalError()
    }
    
    public func validateMoneyTransfer(_ input: BizumValidateMoneyTransferInputParams) throws -> BSANResponse<BizumValidateMoneyTransferDTO> {
        fatalError()
    }
    
    public func validateMoneyTransferMulti(_ input: BizumValidateMoneyTransferMultiInputParams) throws -> BSANResponse<BizumValidateMoneyTransferMultiDTO> {
        fatalError()
    }
    
    public func getSignPositions() throws -> BSANResponse<BizumSignPositionsDTO> {
        fatalError()
    }
    
    public func validateMoneyTransferOTP(_ input: BizumValidateMoneyTransferOTPInputParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO> {
        fatalError()
    }
    
    public func signRefundMoney(with input: BizumSignRefundMoneyInputParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO> {
        fatalError()
    }
    
    public func moneyTransferOTP(_ input: BizumMoneyTransferOTPInputParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO> {
        fatalError()
    }
    
    public func moneyTransferOTPMulti(_ input: BizumMoneyTransferOTPMultiInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        fatalError()
    }
    
    public func inviteNoClientOTP(_ input: BizumInviteNoClientOTPInputParams) throws -> BSANResponse<BizumInviteNoClientDTO> {
        fatalError()
    }
    
    public func inviteNoClient(_ input: BizumInviteNoClientInputParams) throws -> BSANResponse<BizumInviteNoClientDTO> {
        fatalError()
    }
    
    public func getOperations(_ input: BizumOperationsInputParams) throws -> BSANResponse<BizumOperationListDTO> {
        fatalError()
    }
    
    public func getListMultipleOperations(_ input: BizumOperationListMultipleInputParams) throws -> BSANResponse<BizumOperationMultiListDTO> {
        fatalError()
    }
    
    public func getListMultipleDetailOperation(_ input: BizumOperationMultipleListDetailInputParams) throws -> BSANResponse<BizumOperationMultipleListDetailDTO> {
        fatalError()
    }
    
    public func getMultimediaUsers(_ input: BizymMultimediaUsersInputParams) throws -> BSANResponse<BizumGetMultimediaContactsDTO> {
        fatalError()
    }
    
    public func getMultimediaContent(_ input: BizumMultimediaContentInputParams) throws -> BSANResponse<BizumGetMultimediaContentDTO> {
        fatalError()
    }
    
    public func sendImageText(_ input: BizumSendMultimediaInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        fatalError()
    }
    
    public func sendImageTextMulti(_ input: BizumSendImageTextMultiInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        fatalError()
    }
    
    public func validateMoneyRequest(_ input: BizumValidateMoneyRequestInputParams) throws -> BSANResponse<BizumValidateMoneyRequestDTO> {
        fatalError()
    }
    
    public func moneyRequest(_ input: BizumMoneyRequestInputParams) throws -> BSANResponse<BizumMoneyRequestDTO> {
        fatalError()
    }
    
    public func validateMoneyRequestMulti(_ input: BizumValidateMoneyRequestMultiInputParams) throws -> BSANResponse<BizumValidateMoneyRequestMultiDTO> {
        fatalError()
    }
    
    public func moneyRequestMulti(_ input: BizumMoneyRequestMultiInputParams) throws -> BSANResponse<BizumMoneyRequestMultiDTO> {
        fatalError()
    }
    
    public func cancelPendingTransfer(_ input: BizumCancelNotRegisterInputParam) throws -> BSANResponse<BizumResponseInfoDTO> {
        fatalError()
    }
    
    public func refundMoneyRequest(_ input: BizumRefundMoneyRequestInputParams) throws -> BSANResponse<BizumRefundMoneyResponseDTO> {
        fatalError()
    }
    
    public func acceptRequestMoneyTransferOTP(_ input: BizumAcceptRequestMoneyTransferOTPInputParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO> {
        fatalError()
    }
    
    public func getOrganizations(_ input: BizumGetOrganizationsInputParams) throws -> BSANResponse<BizumOrganizationsListDTO> {
        fatalError()
    }
    
    public func getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams) throws -> BSANResponse<BizumRedsysDocumentDTO> {
        fatalError()
    }
}
