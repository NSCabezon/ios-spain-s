import Fuzi

public class ConfirmationBillTaxesParser: BSANParser<ConfirmationBillTaxesResponse, ConfirmationBillTaxesHandler> {
    override func setResponseData() {
        response.paymentBillTaxesConfirmationDTO = handler.paymentBillTaxesConfirmationDTO
    }
}

public class ConfirmationBillTaxesHandler: BSANHandler {
    var paymentBillTaxesConfirmationDTO = PaymentBillTaxesConfirmationDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
            
        case "contabilizOk":
            paymentBillTaxesConfirmationDTO.posted = DTOParser.safeBoolean(element.stringValue.trim())
            
        case "listaCerti":
            var list = [String]()
            
            for descFormato in element.children {
                list.append(descFormato.stringValue.trim())
            }
            paymentBillTaxesConfirmationDTO.certiList = list
            
        case "impComision":
            paymentBillTaxesConfirmationDTO.bankChargesAmount = AmountDTOParser.parse(element)
            
        case "impImpuesto":
            paymentBillTaxesConfirmationDTO.taxAmount = AmountDTOParser.parse(element)
        default:
            BSANLogger.e("ConfirmationBillTaxesHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
