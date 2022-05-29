import Fuzi

class NoSepaPayeeDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> NoSepaPayeeDTO {
        var noSepaPayeeMessageSwiftCenter: MessageSwiftCenterNoSepaPayeeDTO?
        
        if let messageSwiftCenterNode = node.firstChild(tag:"centroMensajeSwift"){
            var messageSwiftCenter = MessageSwiftCenterNoSepaPayeeDTO()
            messageSwiftCenter.company = messageSwiftCenterNode.firstChild(tag:"EMPRESA")?.stringValue.trim()
            messageSwiftCenter.center = messageSwiftCenterNode.firstChild(tag:"CENTRO")?.stringValue.trim()
            noSepaPayeeMessageSwiftCenter = messageSwiftCenter
        }
        //ÑAPA OBLIGATORIA
        let bankTown = node.firstChild(tag:"localidadBanco")?.stringValue.trim() ?? ""
        let noSepaPayeeBankTown = bankTown == "@" ? "": bankTown
        
        let bankAddress = node.firstChild(tag:"domicilioBanco")?.stringValue.trim() ?? ""
        let noSepaPayeeBankAddress = bankAddress == "@" ? "": bankAddress
        
        let bankCountryName = node.firstChild(tag:"paisBanco")?.stringValue.trim() ?? ""
        let noSepaPayeeBankCountryName = bankCountryName == "@" ? "": bankCountryName
        
        return NoSepaPayeeDTO(
            swiftCode: node.firstChild(tag:"codigoSwift")?.stringValue.trim(),
            messageSwiftCenter: noSepaPayeeMessageSwiftCenter,
            paymentAccountDescription: node.firstChild(tag:"descripcionCuentaAbono")?.stringValue.trim(),
            name: node.firstChild(tag:"nombre")?.stringValue.trim(),
            town: node.firstChild(tag:"localidad")?.stringValue.trim(),
            address: node.firstChild(tag:"domicilio")?.stringValue.trim(),
            residentIndicator: node.firstChild(tag:"indicadorResidente")?.stringValue.trim(),
            bankName: node.firstChild(tag: "banco")?.stringValue.trim(),
            bankAddress: noSepaPayeeBankAddress,
            bankTown: noSepaPayeeBankTown,
            bankCountryName: noSepaPayeeBankCountryName,
            residentDescription: node.firstChild(tag:"descResidente")?.stringValue.trim())
    }
}
