import Fuzi

class CardPendingTransactionDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> CardPendingTransactionDTO {
        var cardPendingTransactionDTO = CardPendingTransactionDTO()
        
        if let fechaAnota = node.firstChild(css: "fechaAnota"){
            cardPendingTransactionDTO.annotationDate = DateFormats.safeDate(fechaAnota.stringValue)
        }
        
        if let horaAnotacion = node.firstChild(css: "horaAnotacion") {
            cardPendingTransactionDTO.transactionTime = horaAnotacion.stringValue.trim()
        }
        
        if let importeOperacion = node.firstChild(css: "importeOperacion"){
            cardPendingTransactionDTO.amount = AmountDTOParser.parse(importeOperacion)
        }
        
        if let descGrupoCarac = node.firstChild(css: "descGrupoCarac"){
            cardPendingTransactionDTO.description = descGrupoCarac.stringValue.trim()
        }
        
        if let numTarjeta = node.firstChild(css: "numTarjeta"){
            cardPendingTransactionDTO.cardNumber = numTarjeta.stringValue.trim()
        }
        
        return cardPendingTransactionDTO
    }
}
