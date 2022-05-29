import Foundation
import Fuzi

public class GetCMPSStatusParser : BSANParser<GetCMPSStatusResponse, GetCMPSStatusHandler> {
    override func setResponseData(){
        response.cmpsdto = handler.cmpsdto
        response.telefonoOTPCifrado = handler.telefonoOTPCifrado
    }
}

public class GetCMPSStatusHandler: BSANHandler {
    
    var cmpsdto: CMPSDTO = CMPSDTO()
    var telefonoOTPCifrado: String = ""
    
    override func parseResult(result: XMLElement) throws {
        
        if let clienteCMPS = result.firstChild(tag: "clienteCMPS") {
            cmpsdto.clientCMPS = ClientDTOParser.parse(clienteCMPS)
        }
        
        if let nombreCMPS = result.firstChild(tag: "nombreCMPS") {
            cmpsdto.nameCMPS = nombreCMPS.stringValue.trim()
        }
        
        if let contratoCMPS = result.firstChild(tag: "contratoCMPS") {
            cmpsdto.originAccountContract = ContractDTOParser.parse(contratoCMPS)
        }
        
        if let ibanCMPS = result.firstChild(tag: "ibanCMPS") {
            cmpsdto.ibanCMPS = IBANDTOParser.parse(ibanCMPS)
        }
        
        if let indClienteRegistradoCMPS = result.firstChild(tag: "indClienteRegistradoCMPS") {
            cmpsdto.registeredClientInd = DTOParser.safeBoolean(indClienteRegistradoCMPS.stringValue)
        }
        
        if let telefonoOTPCifradoRes = result.firstChild(tag: "telefonoOTPCifrado") {
            telefonoOTPCifrado = telefonoOTPCifradoRes.stringValue.trim()
        }
        
        if let indExceptuadoOTP = result.firstChild(tag: "indExceptuadoOTP") {
            cmpsdto.otpExceptedInd = DTOParser.safeBoolean(indExceptuadoOTP.stringValue)
        }
        
        if let indListaNegra = result.firstChild(tag: "indListaNegra") {
            cmpsdto.blackListInd = DTOParser.safeBoolean(indListaNegra.stringValue)
        }
        
        if let indRegistradoOTP = result.firstChild(tag: "indRegistradoOTP") {
            cmpsdto.otpRegisteredInd = DTOParser.safeBoolean(indRegistradoOTP.stringValue)
        }
        
        if let indListaNegraBenef = result.firstChild(tag: "indListaNegraBenef") {
            cmpsdto.benefBlackListInd = DTOParser.safeBoolean(indListaNegraBenef.stringValue)
        }
    }
    
}
