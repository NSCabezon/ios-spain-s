import Foundation
import Fuzi

class PrepaidCardDataDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PrepaidCardDataDTO {
        var prepaidCardDataDTO = PrepaidCardDataDTO()
        
        if let datosTarjeta = node.firstChild(tag: "datosTarjeta"){
            
            if let canalComercial = datosTarjeta.firstChild(tag: "canalComercial"){
                prepaidCardDataDTO.commercialChannel = canalComercial.stringValue.trim()
            }
            if let saldoActualPrepago = datosTarjeta.firstChild(tag: "saldoActualPrepago"){
                prepaidCardDataDTO.currentBalance = AmountDTOParser.parse(saldoActualPrepago)
            }
            if let estandarDeReferencia = datosTarjeta.firstChild(tag: "estandarDeReferencia"){
                prepaidCardDataDTO.referenceStandardDTO = ReferenceStandardDTOParser.parse(estandarDeReferencia)
            }
            if let tipoLiquidacion = datosTarjeta.firstChild(tag: "tipoLiquidacion"){
                prepaidCardDataDTO.liquidationType = tipoLiquidacion.stringValue.trim()
            }
            if let formaDePago = datosTarjeta.firstChild(tag: "formaDePago"){
                prepaidCardDataDTO.paymentMethod = formaDePago.stringValue.trim()
            }
            if let nomTitular = datosTarjeta.firstChild(tag: "nomTitular"){
                prepaidCardDataDTO.holderName = nomTitular.stringValue.trim()
            }
            if let descNomProdISBAN = datosTarjeta.firstChild(tag: "descNomProdISBAN"){
                prepaidCardDataDTO.prodNameDescISBAN = descNomProdISBAN.stringValue.trim()
            }
        }
        
        if let datosFirma = node.firstChild(tag: "datosFirma"){
            prepaidCardDataDTO.signatureDTO = SignatureDTOParser.parse(datosFirma)
        }
        
        if let token = node.firstChild(tag: "token"){
            prepaidCardDataDTO.token = token.stringValue.trim()
        }
        
        return prepaidCardDataDTO
    }
}
