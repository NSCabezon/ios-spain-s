import Foundation
import Fuzi

public class ConsultTaxCollectionParser: BSANParser<ConsultTaxCollectionResponse, ConsultTaxCollectionHandler> {
    
    override func setResponseData() {
        response.consultTaxCollection = ConsultTaxCollectionFormatsDTO(fields: handler.fields, signature: handler.signature, systemDate: handler.systemDate)
    }
}

public class ConsultTaxCollectionHandler: BSANHandler {
    
    fileprivate var fields: [TaxCollectionFieldDTO] = []
    fileprivate var signature: SignatureDTO = SignatureDTO.init()
    fileprivate var systemDate: Date = Date()
    
    
    override func parseResult(result: XMLElement) throws {
        let consultFormat = result.firstChild(tag: "listaFormatos")
        try consultFormat?.children.forEach(parseElement)
        systemDate = DateFormats.safeDate(result.firstChild(tag: "fechaSistema")?.stringValue) ?? Date()
        signature = SignatureDTOParser.parse(result)
    }
    
    override func parseElement(element: XMLElement) throws {
        guard let consult = try ConsultTaxParser.parse(from: element) else {
            return
        }
        fields.append(consult)
    }
}

class ConsultTaxParser {
    
    static func parse(from element: XMLElement) throws -> TaxCollectionFieldDTO? {
        guard
            let fieldDescription = element.firstChild(tag: "descripcionCampo")?.stringValue.trim(),
            let fieldId = element.firstChild(tag: "idCampo")?.stringValue,
            let referenceId = element.firstChild(tag: "idReferencia")?.stringValue,
            let fieldLength = element.firstChild(tag: "longitudCampo")?.stringValue
        else {
            return nil
        }
        return TaxCollectionFieldDTO(
            fieldDescription: fieldDescription,
            fieldId: fieldId,
            referenceId: referenceId,
            fieldLength: fieldLength
        )
    }
}



