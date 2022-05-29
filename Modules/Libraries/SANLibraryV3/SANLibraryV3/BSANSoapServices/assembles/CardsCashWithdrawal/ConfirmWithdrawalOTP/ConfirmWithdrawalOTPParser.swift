import Foundation
import Fuzi

public class ConfirmWithdrawalOTPParser : BSANParser <ConfirmWithdrawalOTPResponse, ConfirmWithdrawalOTPHandler> {
    override func setResponseData(){
        response.cashWithDrawalDTO = handler.cashWithDrawalDTO
    }
}

public class ConfirmWithdrawalOTPHandler: BSANHandler {
    var cashWithDrawalDTO = CashWithDrawalDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let impAdisp = result.firstChild(tag: "impAdisp") {
            cashWithDrawalDTO.amountDisp = impAdisp.stringValue.trim()
        }
        
        if let monedaDisp = result.firstChild(tag: "monedaDisp") {
            cashWithDrawalDTO.monedaDisp = monedaDisp.stringValue.trim()
        }
        
        if let descFechaHoraExp = result.firstChild(tag: "descFechaHoraExp") {
            cashWithDrawalDTO.expirationDate = descFechaHoraExp.stringValue.trim()
        }
        
        if let descListaActivadorClave = result.firstChild(tag: "descListaActivadorClave") {
            cashWithDrawalDTO.descListaActivadorClave = descListaActivadorClave.stringValue.trim()
        }
    }
}

