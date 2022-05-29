import SANLegacyLibrary
import CoreDomain

struct MockBSANBillTaxesManager: BSANBillTaxesManager {
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func validateBillAndTaxes(accountDTO: AccountDTO, barCode: String) throws -> BSANResponse<PaymentBillTaxesDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.validateBillAndTaxesMock
        return BSANOkResponse(dto)
    }
    
    func confirmationBillAndTaxes(chargeAccountDTO: AccountDTO, paymentBillTaxesDTO: PaymentBillTaxesDTO, billAndTaxesTokenDTO: BillAndTaxesTokenDTO, directDebit: Bool) throws -> BSANResponse<PaymentBillTaxesConfirmationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.confirmationBillAndTaxesMock
        return BSANOkResponse(dto)
        
    }
    
    func consultSignatureBillAndTaxes(chargeAccountDTO: AccountDTO, directDebit: Bool, amountDTO: AmountDTO) throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.consultSignatureBillAndTaxesMock
        return BSANOkResponse(dto)
    }
    
    func confirmationSignatureBillAndTaxes(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<BillAndTaxesTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.confirmationSignatureBillAndTaxesMock
        return BSANOkResponse(dto)
    }
    
    func consultFormats(of account: AccountDTO, emitterCode: String, productIdentifier: String, collectionTypeCode: String, collectionCode: String) throws -> BSANResponse<ConsultTaxCollectionFormatsDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.consultFormatsMock
        return BSANOkResponse(dto)
    }
    
    func loadBills(of account: AccountDTO, from fromDate: DateModel, to toDate: DateModel, status: BillListStatus) throws -> BSANResponse<BillListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.loadBillsMock
        return BSANOkResponse(dto)
    }
    
    func loadBills(of account: AccountDTO, pagination: PaginationDTO?, from fromDate: DateModel, to toDate: DateModel, status: BillListStatus) throws -> BSANResponse<BillListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.loadBillsMock
        return BSANOkResponse(dto)
    }
    
    func deleteBillList() throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func billAndTaxesDetail(of account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<BillDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.billAndTaxesDetailMock
        return BSANOkResponse(dto)
    }
    
    func cancelDirectBilling(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<GetCancelDirectBillingDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.cancelDirectBillingMock
        return BSANOkResponse(dto)
    }
    
    func confirmCancelDirectBilling(account: AccountDTO, bill: BillDTO, signature: SignatureDTO, getCancelDirectBillingDTO: GetCancelDirectBillingDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func duplicateBill(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<DuplicateBillDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.duplicateBillMock
        return BSANOkResponse(dto)
    }
    
    func confirmDuplicateBill(account: AccountDTO, bill: BillDTO, signature: SignatureDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func confirmReceiptReturn(account: AccountDTO, bill: BillDTO, billDetail: BillDetailDTO, signature: SignatureDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func confirmChangeDirectDebit(account: AccountDTO, bill: BillDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func downloadPdfBill(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<DocumentDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.downloadPdfBillMock
        return BSANOkResponse(dto)
    }
    
    func validateChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, destinationAccount: AccountDTO) throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.validateChangeMassiveDirectDebitsAccountMock
        return BSANOkResponse(dto)
    }
    
    func confirmChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func loadFutureBills(account: AccountDTO, status: String, numberOfElements: Int, page: Int) throws -> BSANResponse<AccountFutureBillListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.loadFutureBillsMock
        return BSANOkResponse(dto)
    }
    
    func emittersConsult(params: EmittersConsultParamsDTO) throws -> BSANResponse<EmittersConsultDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.emittersConsultMock
        return BSANOkResponse(dto)
    }
    
    func loadBillCollectionList(emitterCode: String, account: AccountDTO) throws -> BSANResponse<BillCollectionListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.loadBillCollectionListMock
        return BSANOkResponse(dto)
    }
    
    func loadBillCollectionList(emitterCode: String, account: AccountDTO, pagination: PaginationDTO?) throws -> BSANResponse<BillCollectionListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.loadBillCollectionListMock
        return BSANOkResponse(dto)
    }
    
    func emittersPaymentConfirmation(account: AccountDTO, signature: SignatureDTO, amount: AmountDTO, emitterCode: String, productIdentifier: String, collectionTypeCode: String, collectionCode: String, billData: [String]) throws -> BSANResponse<BillEmittersPaymentConfirmationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.billAndTaxesData.emittersPaymentConfirmationMock
        return BSANOkResponse(dto)
    }
}
