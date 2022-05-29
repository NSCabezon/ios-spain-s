import Foundation
import Fuzi

class ImpositionTransactionsListDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement, pagination: PaginationDTO?) -> ImpositionTransactionsListDTO {
        var impositionTransactionsListDTO = ImpositionTransactionsListDTO()
        
        if node.children(tag: "dato").count == 0{
            return impositionTransactionsListDTO
        }
        
        var transactionDTOs: [ImpositionTransactionDTO] = []
        
        for childElement in node.children(tag: "dato"){
            var newImpositionTransaction = ImpositionTransactionDTO()
            newImpositionTransaction.transactionNumber = UUID().uuidString
            if let fechaOperacion = childElement.firstChild(tag: "fechaOperacion"){
                newImpositionTransaction.operationDate = DateFormats.safeDate(fechaOperacion.stringValue)
            }
            if let descripcionMov = childElement.firstChild(tag: "descripcionMov"){
                newImpositionTransaction.description = descripcionMov.stringValue
            }
            if let fechaValor = childElement.firstChild(tag: "fechaValor"){
                newImpositionTransaction.valueDate = DateFormats.safeDate(fechaValor.stringValue)
            }
            if let impMovimiento = childElement.firstChild(tag: "impMovimiento"){
                newImpositionTransaction.amount = AmountDTOParser.parse(impMovimiento)
            }
            
            transactionDTOs.append(newImpositionTransaction)
        }
        impositionTransactionsListDTO.transactionDTOs = transactionDTOs

        if let pagination = pagination{
            impositionTransactionsListDTO.pagination = pagination
        }
        
        return impositionTransactionsListDTO
    }
}
