import CoreDomain

public protocol BSANBillTaxesManager {
    func validateBillAndTaxes(accountDTO: AccountDTO, barCode: String) throws -> BSANResponse<PaymentBillTaxesDTO>
    func confirmationBillAndTaxes(chargeAccountDTO: AccountDTO, paymentBillTaxesDTO: PaymentBillTaxesDTO, billAndTaxesTokenDTO: BillAndTaxesTokenDTO, directDebit: Bool) throws -> BSANResponse<PaymentBillTaxesConfirmationDTO>
    func consultSignatureBillAndTaxes(chargeAccountDTO: AccountDTO, directDebit: Bool, amountDTO: AmountDTO) throws -> BSANResponse<SignatureWithTokenDTO>
    func confirmationSignatureBillAndTaxes(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<BillAndTaxesTokenDTO>
    func consultFormats(of account: AccountDTO, emitterCode: String, productIdentifier: String, collectionTypeCode: String, collectionCode: String) throws -> BSANResponse<ConsultTaxCollectionFormatsDTO>
    func loadBills(of account: AccountDTO, from fromDate: DateModel, to toDate: DateModel, status: BillListStatus) throws -> BSANResponse<BillListDTO>
    func loadBills(of account: AccountDTO, pagination: PaginationDTO?, from fromDate: DateModel, to toDate: DateModel, status: BillListStatus) throws -> BSANResponse<BillListDTO>
    func deleteBillList() throws -> BSANResponse<Void>
    func billAndTaxesDetail(of account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<BillDetailDTO>
    func cancelDirectBilling(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<GetCancelDirectBillingDTO>
    func confirmCancelDirectBilling(account: AccountDTO, bill: BillDTO, signature: SignatureDTO, getCancelDirectBillingDTO: GetCancelDirectBillingDTO) throws -> BSANResponse<Void>
    func duplicateBill(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<DuplicateBillDTO>
    func confirmDuplicateBill(account: AccountDTO, bill: BillDTO, signature: SignatureDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<Void>
    func confirmReceiptReturn(account: AccountDTO, bill: BillDTO, billDetail: BillDetailDTO, signature: SignatureDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<Void>
    func confirmChangeDirectDebit(account: AccountDTO, bill: BillDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<Void>
    func downloadPdfBill(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<DocumentDTO>
    func validateChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, destinationAccount: AccountDTO) throws -> BSANResponse<SignatureWithTokenDTO>
    func confirmChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<Void>
    func loadFutureBills(account: AccountDTO, status: String, numberOfElements: Int, page: Int) throws -> BSANResponse<AccountFutureBillListDTO>
    func emittersConsult(params: EmittersConsultParamsDTO) throws -> BSANResponse<EmittersConsultDTO>
    func loadBillCollectionList(emitterCode: String, account: AccountDTO) throws -> BSANResponse<BillCollectionListDTO>
    func loadBillCollectionList(emitterCode: String, account: AccountDTO, pagination: PaginationDTO?) throws -> BSANResponse<BillCollectionListDTO>
    func emittersPaymentConfirmation(account: AccountDTO, signature: SignatureDTO, amount: AmountDTO, emitterCode: String, productIdentifier: String, collectionTypeCode: String, collectionCode: String, billData: [String]) throws -> BSANResponse<BillEmittersPaymentConfirmationDTO>
}
