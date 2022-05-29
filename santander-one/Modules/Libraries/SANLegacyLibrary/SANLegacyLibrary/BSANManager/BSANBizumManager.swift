public protocol BSANBizumManager {
    func checkPayment(defaultXPAN: String) throws -> BSANResponse<BizumCheckPaymentDTO>
    func getContacts(_ input: BizumGetContactsInputParams) throws -> BSANResponse<BizumGetContactsDTO>
    func validateMoneyTransfer(_ input: BizumValidateMoneyTransferInputParams) throws -> BSANResponse<BizumValidateMoneyTransferDTO>
    func validateMoneyTransferMulti(_ input: BizumValidateMoneyTransferMultiInputParams) throws -> BSANResponse<BizumValidateMoneyTransferMultiDTO>
    func getSignPositions() throws -> BSANResponse<BizumSignPositionsDTO>
    func validateMoneyTransferOTP(_ input: BizumValidateMoneyTransferOTPInputParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO>
    func signRefundMoney(with input: BizumSignRefundMoneyInputParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO>
    func moneyTransferOTP(_ input: BizumMoneyTransferOTPInputParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO>
    func moneyTransferOTPMulti(_ input: BizumMoneyTransferOTPMultiInputParams) throws -> BSANResponse<BizumTransferInfoDTO>
    func inviteNoClientOTP(_ input: BizumInviteNoClientOTPInputParams) throws -> BSANResponse<BizumInviteNoClientDTO>
    func inviteNoClient(_ input: BizumInviteNoClientInputParams) throws -> BSANResponse<BizumInviteNoClientDTO>
    func getOperations(_ input: BizumOperationsInputParams) throws -> BSANResponse<BizumOperationListDTO>
    func getListMultipleOperations(_ input: BizumOperationListMultipleInputParams) throws -> BSANResponse<BizumOperationMultiListDTO>
    func getListMultipleDetailOperation(_ input: BizumOperationMultipleListDetailInputParams) throws -> BSANResponse<BizumOperationMultipleListDetailDTO>
    func getMultimediaUsers(_ input: BizymMultimediaUsersInputParams) throws -> BSANResponse<BizumGetMultimediaContactsDTO>
    func getMultimediaContent(_ input: BizumMultimediaContentInputParams) throws -> BSANResponse<BizumGetMultimediaContentDTO>
    func sendImageText(_ input: BizumSendMultimediaInputParams) throws -> BSANResponse<BizumTransferInfoDTO>
    func sendImageTextMulti(_ input : BizumSendImageTextMultiInputParams) throws -> BSANResponse<BizumTransferInfoDTO>
    func validateMoneyRequest(_ input : BizumValidateMoneyRequestInputParams) throws -> BSANResponse<BizumValidateMoneyRequestDTO>
    func moneyRequest(_ input : BizumMoneyRequestInputParams) throws -> BSANResponse<BizumMoneyRequestDTO>
    func validateMoneyRequestMulti(_ input : BizumValidateMoneyRequestMultiInputParams) throws -> BSANResponse<BizumValidateMoneyRequestMultiDTO>
    func moneyRequestMulti(_ input : BizumMoneyRequestMultiInputParams) throws -> BSANResponse<BizumMoneyRequestMultiDTO>
    func cancelPendingTransfer(_ input : BizumCancelNotRegisterInputParam) throws -> BSANResponse<BizumResponseInfoDTO>
    func refundMoneyRequest(_ input: BizumRefundMoneyRequestInputParams) throws -> BSANResponse<BizumRefundMoneyResponseDTO>
    func acceptRequestMoneyTransferOTP(_ input: BizumAcceptRequestMoneyTransferOTPInputParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO>
    func getOrganizations(_ input: BizumGetOrganizationsInputParams) throws -> BSANResponse<BizumOrganizationsListDTO>
    func getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams) throws -> BSANResponse<BizumRedsysDocumentDTO>
}
