import Fuzi
public class ValidationBillTaxesParser: BSANParser<ValidationBillTaxesResponse, ValidationBillTaxesHandler> {
    override func setResponseData() {
        response.paymentBillTaxesDTO = handler.paymentBillTaxesDTO
    }
}

public class ValidationBillTaxesHandler: BSANHandler {
    var paymentBillTaxesDTO = PaymentBillTaxesDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "recaEmisora":
            var takingsIssuing = TakingsIssuingDTO()
            
            takingsIssuing.issuing = element.firstChild(css: "EMISORA")?.stringValue.trim()
            
            takingsIssuing.product = element.firstChild(css: "PRODUCTO")?.stringValue.trim()
            
            if let subtipoRecaudacion = element.firstChild(css: "SUBTIPO_DE_RECAUDACION"){
                var takingsSubType = TakingsSubTypeDTO()
                takingsSubType.type = subtipoRecaudacion.firstChild(css: "TIPO_DE_RECAUDACION")?.stringValue.trim()
                takingsSubType.subtype = subtipoRecaudacion.firstChild(css: "CODIGO_DE_SUBTIPO")?.stringValue.trim()
                takingsIssuing.takingsSubType = takingsSubType
            }
            
            paymentBillTaxesDTO.takingsIssuing = takingsIssuing
        case "impRecibo":
            paymentBillTaxesDTO.billAmount = AmountDTOParser.parse(element)
            
        case "descEmisora":
            paymentBillTaxesDTO.issuingDescription = element.stringValue.trim()
            
        case "descRecaudacion":
            paymentBillTaxesDTO.takingsDescription = element.stringValue.trim()
            
        case "impComision":
            paymentBillTaxesDTO.bankChargesAmount = AmountDTOParser.parse(element)
            
        case "impImpuesto":
            paymentBillTaxesDTO.taxAmount = AmountDTOParser.parse(element)
            
        case "indComision":
            paymentBillTaxesDTO.bankChargesIndicator = "S" == element.stringValue.trim()
            
        case "referencia":
            paymentBillTaxesDTO.reference = element.stringValue.trim()
            
        case "descReferencia":
            paymentBillTaxesDTO.referenceDescription = element.stringValue.trim()
            
        case "lista":
            var list = [PaymentBillTaxesItemDTO]()
            
            for dato in element.children {
                var item = PaymentBillTaxesItemDTO()
                item.formatDescription = dato.firstChild(css: "descFormato")?.stringValue.trim()
                item.fieldDescription = dato.firstChild(css: "descCampAbrv")?.stringValue.trim()
                item.fieldLengh = DTOParser.safeInteger(dato.firstChild(css: "longCampo")?.stringValue.trim())
                item.mandatoryIndicator = "S" == dato.firstChild(css: "indObligatorio")?.stringValue.trim()
                item.referenceIndicator = "S" == dato.firstChild(css: "indReferencia")?.stringValue.trim()
                
                list.append(item)
            }
            paymentBillTaxesDTO.list = list
            
        default:
            BSANLogger.e("ValidationBillTaxesHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
