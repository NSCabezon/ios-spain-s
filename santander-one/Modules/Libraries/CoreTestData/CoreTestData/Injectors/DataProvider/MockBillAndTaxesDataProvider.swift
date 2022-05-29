import SANLegacyLibrary

public class MockBillAndTaxesDataProvider {
    public var validateBillAndTaxesMock: PaymentBillTaxesDTO!
    public var confirmationBillAndTaxesMock: PaymentBillTaxesConfirmationDTO!
    public var consultSignatureBillAndTaxesMock: SignatureWithTokenDTO!
    public var confirmationSignatureBillAndTaxesMock: BillAndTaxesTokenDTO!
    public var consultFormatsMock: ConsultTaxCollectionFormatsDTO!
    public var loadBillsMock: BillListDTO!
    public var billAndTaxesDetailMock: BillDetailDTO!
    public var cancelDirectBillingMock: GetCancelDirectBillingDTO!
    public var duplicateBillMock: DuplicateBillDTO!
    public var downloadPdfBillMock: DocumentDTO!
    public var validateChangeMassiveDirectDebitsAccountMock: SignatureWithTokenDTO!
    public var loadFutureBillsMock: AccountFutureBillListDTO!
    public var emittersConsultMock: EmittersConsultDTO!
    public var loadBillCollectionListMock: BillCollectionListDTO!
    public var emittersPaymentConfirmationMock: BillEmittersPaymentConfirmationDTO!
}
