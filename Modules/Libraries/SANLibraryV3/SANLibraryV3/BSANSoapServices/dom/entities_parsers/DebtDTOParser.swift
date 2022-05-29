import Fuzi

class DebtDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> DebtDTO {
        var debtDTO = DebtDTO()
        
        if let importeTotDeuda = node.firstChild(tag:"importeTotDeuda"){
            debtDTO.totalDebt = AmountDTOParser.parse(importeTotDeuda)
        }
        
        if let fechaOpera = node.firstChild(tag:"fechaOpera"){
            debtDTO.operationDate = DateFormats.safeDate(fechaOpera.stringValue)
        }
        
        return debtDTO
    }
}
