import Foundation
import Fuzi

class ValidateLoadPrepaidCardDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ValidateLoadPrepaidCardDTO {
        var validateLoadPrepaidCardDTO = ValidateLoadPrepaidCardDTO()
        
        if let token = node.firstChild(tag: "token"){
            validateLoadPrepaidCardDTO.token = token.stringValue.trim()
        }
        
        if let datosPreliq = node.firstChild(tag: "datosPreliq"){
            validateLoadPrepaidCardDTO.preliqDataDTO = PreliqDataDTO()
            if let conceptoLiq = datosPreliq.firstChild(tag: "conceptoLiq"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.liqConcept = conceptoLiq.stringValue.trim()
            }
            if let indTipoCobro = datosPreliq.firstChild(tag: "indTipoCobro"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.chargeTypeInd = indTipoCobro.stringValue.trim()
            }
            if let importeComision = datosPreliq.firstChild(tag: "importeComision"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.bankCharge = AmountDTOParser.parse(importeComision)
            }
            if let importeEstandar = datosPreliq.firstChild(tag: "importeEstandar"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.standardAmount = AmountDTOParser.parse(importeEstandar)
            }
            if let importeOperacion = datosPreliq.firstChild(tag: "importeOperacion"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.operationAmount = AmountDTOParser.parse(importeOperacion)
            }
            if let importeTeorico = datosPreliq.firstChild(tag: "importeTeorico"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.notionalAmount = AmountDTOParser.parse(importeTeorico)
            }
            if let canalComercial = datosPreliq.firstChild(tag: "canalComercial"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.commercialChannel = canalComercial.stringValue.trim()
            }
            if let saldoActualPrepago = datosPreliq.firstChild(tag: "saldoActualPrepago"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.prepaidCurrentBalance = AmountDTOParser.parse(saldoActualPrepago)
            }
            if let importeTotalOperacion = datosPreliq.firstChild(tag: "importeTotalOperacion"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.totalOperationAmount = AmountDTOParser.parse(importeTotalOperacion)
            }
            if let importeCobro = datosPreliq.firstChild(tag: "importeCobro"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.receivableAmount = AmountDTOParser.parse(importeCobro)
            }
            if let estandarDeReferencia = datosPreliq.firstChild(tag: "estandarDeReferencia"){
                validateLoadPrepaidCardDTO.preliqDataDTO?.referenceStandard = ReferenceStandardDTOParser.parse(estandarDeReferencia)
            }
        }
        
        return validateLoadPrepaidCardDTO
    }
}
