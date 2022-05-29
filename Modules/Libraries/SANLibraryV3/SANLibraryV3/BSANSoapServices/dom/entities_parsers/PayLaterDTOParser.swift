import Fuzi

class PayLaterDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> PayLaterDTO {
        var payLaterDTO = PayLaterDTO()
        
        if let descSituacion = node.firstChild(css: "descSituacion"){
            payLaterDTO.situationDesc = descSituacion.stringValue.trim()
        }
        
        if let fechaAlta = node.firstChild(css: "fechaAlta"){
            payLaterDTO.enrollmentDate = DateFormats.safeDate(fechaAlta.stringValue)
        }
        
        if let nomProducto = node.firstChild(css: "nomProducto"){
            payLaterDTO.productName = nomProducto.stringValue.trim()
        }
        
        if let descFormaDePago = node.firstChild(css: "descFormaDePago"){
            payLaterDTO.paymentMethodDesc = descFormaDePago.stringValue.trim()
        }
        
        if let nomTitular = node.firstChild(css: "nomTitular"){
            payLaterDTO.holderName = nomTitular.stringValue.trim()
        }
        
        if let lista = node.firstChild(css: "lista"){
            var deudas = [DebtDTO]()
            
            for dato in lista.children {
                deudas.append(DebtDTOParser.parse(dato))
            }
            payLaterDTO.debts = deudas
        }
        
        return payLaterDTO
    }
}
