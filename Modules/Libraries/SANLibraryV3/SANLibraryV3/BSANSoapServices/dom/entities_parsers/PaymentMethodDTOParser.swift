import Fuzi

class PaymentMethodDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        
        if let importeCuota = node.firstChild(tag: "importeCuota") {
            paymentMethodDTO.feeAmount = AmountDTOParser.parse(importeCuota)
        }
        
        if let importeIncModali = node.firstChild(tag: "importeIncModali") {
            paymentMethodDTO.incModeAmount = AmountDTOParser.parse(importeIncModali)
        }
        
        if let importeMaxModali = node.firstChild(tag: "importeMaxModali") {
            paymentMethodDTO.maxModeAmount = AmountDTOParser.parse(importeMaxModali)
        }
        
        if let importeMinAmort = node.firstChild(tag: "importeMinAmort") {
            paymentMethodDTO.minAmortAmount = AmountDTOParser.parse(importeMinAmort)
        }
        
        if let importeMinModali = node.firstChild(tag: "importeMinModali") {
            paymentMethodDTO.minModeAmount = AmountDTOParser.parse(importeMinModali)
        }
        
        if let tipoLiquidacionNueva = node.firstChild(tag: "tipoLiquidacionNueva") {
            paymentMethodDTO.liquidationType = tipoLiquidacionNueva.stringValue.trim()
        }
        
        if let formaDePagoNueva = node.firstChild(tag: "formaDePagoNueva") {
            paymentMethodDTO.paymentMethod = PaymentMethodType(rawValue: formaDePagoNueva.stringValue.trim())
        }
        
        if let descFormaDePagoNueva = node.firstChild(tag: "descFormaDePagoNueva") {
            paymentMethodDTO.paymentMethodDesc = descFormaDePagoNueva.stringValue.trim()
        }
        
        if let idRangoFP = node.firstChild(tag: "idRangoFP") {
            paymentMethodDTO.idRangeFP = idRangoFP.stringValue.trim()
        }
        
        if let descUmbral = node.firstChild(tag: "descUmbral") {
            paymentMethodDTO.thresholdDesc = safeDecimal(descUmbral.stringValue.trim())
        }
        
        return paymentMethodDTO
    }
    
    
}
