import Foundation
import Fuzi

public class GetTransactionDetailEasyPayParser : BSANParser <GetTransactionDetailEasyPayResponse, GetTransactionDetailEasyPayHandler> {
    override func setResponseData(){
        response.easyPayDTO = handler.easyPayDTO
    }
}

public class GetTransactionDetailEasyPayHandler: BSANHandler {
    
    var easyPayDTO = EasyPayDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let descComercioCajero = result.firstChild(tag: "descComercioCajero") {
            easyPayDTO.atmCommerceDesc = descComercioCajero.stringValue.trim()
        }
        
        if let formaDePago = result.firstChild(tag: "formaDePago") {
            easyPayDTO.paymentMethod = formaDePago.stringValue.trim()
        }
        
        if let fechaEmision = result.firstChild(tag: "fechaEmision") {
            easyPayDTO.issueDate = DateFormats.safeDate(fechaEmision.stringValue.trim())
        }
        
        if let tipoVariacionTasa_INDVAR1 = result.firstChild(tag: "tipoVariacionTasa_INDVAR1") {
            easyPayDTO.feeVariationType = tipoVariacionTasa_INDVAR1.stringValue.trim()
        }
        
        if let codSoporte_CODSOPOR = result.firstChild(tag: "codSoporte_CODSOPOR") {
            easyPayDTO.supportCode = codSoporte_CODSOPOR.stringValue.trim()
        }
        
        if let tipoModoOperMovi_JTIPOMOD = result.firstChild(tag: "tipoModoOperMovi_JTIPOMOD") {
            easyPayDTO.transactionOperationModeType = tipoModoOperMovi_JTIPOMOD.stringValue.trim()
        }
        
        if let tipoOrigenMov_JTIPORIG = result.firstChild(tag: "tipoOrigenMov_JTIPORIG") {
            easyPayDTO.transactionOriginType = tipoOrigenMov_JTIPORIG.stringValue.trim()
        }
        
        if let nombreComercioContratado_NCOMERC = result.firstChild(tag: "nombreComercioContratado_NCOMERC") {
            easyPayDTO.contractedCommerceName = nombreComercioContratado_NCOMERC.stringValue.trim()
        }
        
        if let tipoSubprod_IDSUBTIP = result.firstChild(tag: "tipoSubprod_IDSUBTIP") {
            var newSubprod = ProductSubtypeDTO()
            if let TIPO_DE_PRODUCTO = tipoSubprod_IDSUBTIP.firstChild(tag: "TIPO_DE_PRODUCTO") {
                newSubprod.productType = TIPO_DE_PRODUCTO.stringValue.trim()
            }
            
            if let SUBTIPO_DE_PRODUCTO = tipoSubprod_IDSUBTIP.firstChild(tag: "SUBTIPO_DE_PRODUCTO") {
                newSubprod.productSubtype = SUBTIPO_DE_PRODUCTO.stringValue.trim()
            }
            
            if let EMPRESA = tipoSubprod_IDSUBTIP.firstChild(tag: "EMPRESA") {
                newSubprod.company = EMPRESA.stringValue.trim()
            }
            
            easyPayDTO.productSubtype = newSubprod
        }
    }
}
