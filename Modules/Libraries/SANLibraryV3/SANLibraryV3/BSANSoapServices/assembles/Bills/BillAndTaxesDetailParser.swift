import Fuzi

public class BillAndTaxesDetailHandler: BSANHandler {
    
    var billDetailDTO: BillDetailDTO?
    
    override func parseResult(result: XMLElement) throws {
        billDetailDTO = try BillAndTaxesDetailParser.parse(from: result)
    }
    
}


public class BillAndTaxesDetailParser: BSANParser<BillAndTaxesDetailResponse, BillAndTaxesDetailHandler> {

    override func setResponseData() {
        response.billDetailDTO = handler.billDetailDTO
    }
    
    static func parse(from element: XMLElement) throws -> BillDetailDTO? {
        guard
            let holder = element.firstChild(tag: "titular")?.stringValue.trim(),
            let signatureElement = element.firstChild(tag: "datosFirma"),
            let issuerName = element.firstChild(tag: "nombreEmisor")?.stringValue.trim(),
            let holderNIF = element.firstChild(tag: "descNifTitular")?.stringValue.trim(),
            let debtorAccount = element.firstChild(tag: "descCuentaCargo")?.stringValue.trim(),
            let reference = element.firstChild(tag: "referencia")?.stringValue.trim(),
            let billNumber = element.firstChild(tag: "numRecibo")?.stringValue.trim(),
            let billAmount = element.firstChild(tag: "impRecibo")?.firstChild(tag: "IMPORTE")?.stringValue,
            let amount = DTOParser.safeDecimal(billAmount),
            let currency = element.firstChild(tag: "impRecibo")?.firstChild(tag: "DIVISA")?.stringValue,
            let chargeDate = DateFormats.safeDate(element.firstChild(tag: "fechaCargo")?.stringValue),
            let mandateReference = element.firstChild(tag: "referenciaMandato")?.stringValue.trim(),
            let sourceNIFSurf = element.firstChild(tag: "descNifSurfEmisora")?.stringValue.trim(),
            let state = element.firstChild(tag: "estado")?.stringValue.trim(),
            let stateDescription = element.firstChild(tag: "descSituacion")?.stringValue.trim(),
            let accountRefundDescription = element.firstChild(tag: "datosDevolucion")?.firstChild(tag: "descCuentaDevolucion")?.stringValue.trim(),
            let productSubtypeNode = element.firstChild(tag: "motivoDevolucion")?.firstChild(tag: "SUBTIPO_DE_PRODUCTO")
        else {
            return nil
        }
        let concept = element.firstChild(tag: "concepto")?.stringValue.trim()
        return BillDetailDTO(
            signature: SignatureDTOParser.parse(signatureElement),
            holder: holder,
            issuerName: issuerName,
            holderNIF: holderNIF,
            debtorAccount: debtorAccount,
            reference: reference,
            billNumber: billNumber,
            concept: concept,
            amount: AmountDTO(value: amount, currency: CurrencyDTO(currencyName: currency, currencyType: CurrencyType.parse(currency))),
            chargeDate: chargeDate,
            mandateReference: mandateReference,
            sourceNIFSurf: sourceNIFSurf,
            state: BillStatus(from: state),
            stateDescription: stateDescription,
            accountRefundDescription: accountRefundDescription,
            productSubtype: ProductSubtypeDTOParser.parse(productSubtypeNode))
        
    }

}
