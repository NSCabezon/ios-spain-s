import Fuzi

class EasyPayDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> EasyPayDTO {
        var easyPayDTO = EasyPayDTO()
        
        if let descComercioCajero = node.firstChild(css: "descComercioCajero"){
            easyPayDTO.atmCommerceDesc = descComercioCajero.stringValue.trim()
        }
        
        if let formaDePago = node.firstChild(css: "formaDePago"){
            easyPayDTO.paymentMethod = formaDePago.stringValue.trim()
        }
        
        if let fechaEmision = node.firstChild(css: "fechaEmision"){
            easyPayDTO.issueDate = DateFormats.safeDate(fechaEmision.stringValue)
        }
        
        if let tipoVariacionTasa_INDVAR1 = node.firstChild(css: "tipoVariacionTasa_INDVAR1"){
            easyPayDTO.feeVariationType = tipoVariacionTasa_INDVAR1.stringValue.trim()
        }
        
        if let codSoporte_CODSOPOR = node.firstChild(css: "codSoporte_CODSOPOR"){
            easyPayDTO.supportCode = codSoporte_CODSOPOR.stringValue.trim()
        }
        
        if let tipoModoOperMovi_JTIPOMOD = node.firstChild(css: "tipoModoOperMovi_JTIPOMOD"){
            easyPayDTO.transactionOperationModeType = tipoModoOperMovi_JTIPOMOD.stringValue.trim()
        }
        
        if let tipoOrigenMov_JTIPORIG = node.firstChild(css: "tipoOrigenMov_JTIPORIG"){
            easyPayDTO.transactionOriginType = tipoOrigenMov_JTIPORIG.stringValue.trim()
        }
        
        if let nombreComercioContratado_NCOMERC = node.firstChild(css: "nombreComercioContratado_NCOMERC"){
            easyPayDTO.contractedCommerceName = nombreComercioContratado_NCOMERC.stringValue.trim()
        }
        
        if let tipoSubprod_IDSUBTIP = node.firstChild(css: "tipoSubprod_IDSUBTIP"){
            easyPayDTO.productSubtype = ProductSubtypeDTOParser.parse(tipoSubprod_IDSUBTIP)
        }
        
        return easyPayDTO
    }
}
