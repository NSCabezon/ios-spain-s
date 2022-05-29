import Foundation
import Fuzi

public class NoSepaPayeeDetailParser: BSANParser<NoSepaPayeeDetailResponse, NoSepaPayeeDetailHandler> {
    override func setResponseData(){
        response.noSepaPayeeDetailDTO = handler.noSepaPayeeDetailDTO
    }
}

public class NoSepaPayeeDetailHandler: BSANHandler {
    var noSepaPayeeDetailDTO = NoSepaPayeeDetailDTO()
    
    override func parseResult(result: XMLElement) throws {
        var noSepaPayeeName, noSepaPayeePaymentDescription, noSepaPayeeCountryCode, noSepaPayeeCountryName, noSepaPayeeTown, noSepaPayeeAddress, noSepaPayeeSwiftCode, noSepaPayeeBankName, noSepaPayeeBankCountryCode, noSepaPayeeBankCountryName, noSepaPayeeBankTown, noSepaPayeeBankAddress: String?
        
        if let beneficiarioNoSepa = result.firstChild(tag: "beneficiarioNoSepa") {
            noSepaPayeeCountryCode = beneficiarioNoSepa.firstChild(tag: "pais")?.stringValue
            noSepaPayeeCountryName = beneficiarioNoSepa.firstChild(tag: "nombrePais")?.stringValue
            noSepaPayeeTown = beneficiarioNoSepa.firstChild(tag: "localidad")?.stringValue
            noSepaPayeeAddress = beneficiarioNoSepa.firstChild(tag: "domicilio")?.stringValue
        }
        
        if let concept = result.firstChild(tag: "concepto") {
            noSepaPayeeDetailDTO.concept = concept.stringValue.trim()
        }
        
        if let bancoNoSepa = result.firstChild(tag: "bancoNoSepa") {
            noSepaPayeeSwiftCode = bancoNoSepa.firstChild(tag: "bic")?.stringValue.trim()
            noSepaPayeeBankName = bancoNoSepa.firstChild(tag: "nombreBanco")?.stringValue.trim()
            noSepaPayeeBankCountryCode = bancoNoSepa.firstChild(tag: "pais")?.stringValue.trim()
            
            //ÑAPA OBLIGATORIA
            let bankTown = bancoNoSepa.firstChild(tag: "localidad")?.stringValue.trim() ?? ""
            noSepaPayeeBankTown = bankTown == "@" ? "": bankTown
            
            let bankAddress = bancoNoSepa.firstChild(tag: "domicilio")?.stringValue.trim() ?? ""
            noSepaPayeeBankAddress = bankAddress == "@" ? "": bankAddress
            
            let bankCountryName = bancoNoSepa.firstChild(tag: "nombrePais")?.stringValue.trim() ?? ""
            noSepaPayeeBankCountryName = bankCountryName == "@" ? "": bankCountryName
        }
        
        if let beneficiaryAccount = result.firstChild(tag: "cuentaBeneficiario") {
            noSepaPayeePaymentDescription = beneficiaryAccount.stringValue.trim()
        }
        
        if let amount = result.firstChild(tag: "importe") {
            noSepaPayeeDetailDTO.amount = AmountDTOParser.parse(amount)
        }
        
        if let alias = result.firstChild(tag: "alias") {
            noSepaPayeeDetailDTO.alias = alias.stringValue.trim()
        }
        
        if let payeeCode = result.firstChild(tag: "codPayee") {
            noSepaPayeeDetailDTO.codPayee = payeeCode.stringValue.trim()
        }
        
        if let accountType = result.firstChild(tag: "tipoCuenta") {
            noSepaPayeeDetailDTO.accountType = NoSepaAccountType.findBy(type: accountType.stringValue.trim())
        }
        
        if let beneficiaryName = result.firstChild(tag: "nombreBeneficiario") {
            noSepaPayeeName = beneficiaryName.stringValue.trim()
        }
        
        if let actuanteBeneficiario = result.firstChild(tag: "actuanteBeneficiario"){
            noSepaPayeeDetailDTO.benefActing = IdActuantePayeeDTOParser.parse(actuanteBeneficiario)
        }
        
        if let actuanteBanco = result.firstChild(tag: "actuanteBanco"){
            noSepaPayeeDetailDTO.bankActing = IdActuantePayeeDTOParser.parse(actuanteBanco)
        }
        
        noSepaPayeeDetailDTO.payee = NoSepaPayeeDTO(
            swiftCode: noSepaPayeeSwiftCode,
            paymentAccountDescription: noSepaPayeePaymentDescription,
            name: noSepaPayeeName,
            town: noSepaPayeeTown,
            address: noSepaPayeeAddress,
            countryName: noSepaPayeeCountryName,
            countryCode: noSepaPayeeCountryCode,
            bankName: noSepaPayeeBankName,
            bankAddress: noSepaPayeeBankAddress,
            bankTown: noSepaPayeeBankTown,
            bankCountryCode: noSepaPayeeBankCountryCode,
            bankCountryName: noSepaPayeeBankCountryName)
    }
}

