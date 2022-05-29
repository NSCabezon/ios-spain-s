protocol BizumDataSourceProtocol: RestDataSource {
    func checkPayment() throws -> BSANResponse<BizumCheckPaymentDTO>
    func getContacts(params: BizumGetContactsParams) throws -> BSANResponse<BizumGetContactsDTO>
    func validateMoneyTransfer(params: BizumValidateMoneyTransferParams) throws -> BSANResponse<BizumValidateMoneyTransferDTO>
    func validateMoneyTransferMulti(params: BizumValidateMoneyTransferMultiParams) throws -> BSANResponse<BizumValidateMoneyTransferMultiDTO>
    func getSignPositions(params: SignPositionParams) throws -> BSANResponse<BizumSignPositionsDTO>
    func validateMoneyTransferOTP(params: BizumValidateMoneyTransferOTPParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO>
    func moneyTransferOTP(params: BizumMoneyTransferOTPParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO>
    func moneyTransferOTPMulti(params: BizumMoneyTransferMultiParams) throws -> BSANResponse<BizumTransferInfoDTO>
    func inviteNoClientOTP(params: BizumInviteNoClientOTPParams) throws -> BSANResponse<BizumInviteNoClientDTO>
    func inviteNoClient(params: BizumInviteNoClientParams) throws -> BSANResponse<BizumInviteNoClientDTO>
    func getOperations(_ params: BizumOperationsParams) throws -> BSANResponse<BizumOperationListDTO>
    func getOperationsMultipleDetail(_ params: BizumOperationMultipleDetail) throws -> BSANResponse<BizumOperationMultipleListDetailDTO>
    func getOperationsMultiple(_ params: BizumOperationListMultiple) throws -> BSANResponse<BizumOperationMultiListDTO>
    func validateMoneyRequest(_ params: BizumValidateMoneyRequestParams) throws -> BSANResponse<BizumValidateMoneyRequestDTO>
    func moneyRequest(_ params: BizumMoneyRequestParams) throws  -> BSANResponse<BizumMoneyRequestDTO>
    func validateMoneyRequestMulti(_ params: BizumValidateMoneyRequestMultiParams) throws -> BSANResponse<BizumValidateMoneyRequestMultiDTO>
    func moneyRequestMulti(_ params: BizumMoneyRequestMultiParams) throws -> BSANResponse<BizumMoneyRequestMultiDTO>
    func cancelPendingTransfer(_ params : BizumCancelNotRegisterParam) throws -> BSANResponse<BizumResponseInfoDTO>
    func refundMoneyRequest(_ params: BizumRefundMoneyRequestParams) throws -> BSANResponse<BizumRefundMoneyResponseDTO>
    func getOrganizations(_ params: BizumGetOrganizationsParams) throws -> BSANResponse<BizumOrganizationsListDTO>
}
