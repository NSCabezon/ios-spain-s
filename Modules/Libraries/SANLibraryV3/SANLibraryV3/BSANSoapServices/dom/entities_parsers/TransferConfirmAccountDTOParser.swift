import Foundation
import Fuzi

class TransferConfirmAccountDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TransferConfirmAccountDTO {
        
        var transferConfirmAccountDTO = TransferConfirmAccountDTO()
        
        let basicDataNode = findChild(node: node, childName: "datosBasicos")
        if let dateNode = findChild(node: basicDataNode, childName: "fechaEmisionTransf") {
            transferConfirmAccountDTO.issueDate = DateFormats.safeDate(dateNode.stringValue)
        }
        if let transferAmountNode = findChild(node: basicDataNode, childName: "impTransferencia") {
            transferConfirmAccountDTO.transferAmount = AmountDTOParser.parse(transferAmountNode)
        }
        if let bankChargeAmountNode = findChild(node: basicDataNode, childName: "impComision") {
            transferConfirmAccountDTO.bankChargeAmount = AmountDTOParser.parse(bankChargeAmountNode)
        }
        if let netNode = findChild(node: basicDataNode, childName: "impLiquido") {
            transferConfirmAccountDTO.netAmount = AmountDTOParser.parse(netNode)
        }
        if let expensesNode = findChild(node: basicDataNode, childName: "impGastos") {
            transferConfirmAccountDTO.expensesAmount = AmountDTOParser.parse(expensesNode)
        }
        
        transferConfirmAccountDTO.destinationAccountDescription = findChild(node: basicDataNode, childName: "descCuentaAbono")?.stringValue
        transferConfirmAccountDTO.originAccountDescription = findChild(node: basicDataNode, childName: "descCuentaCargo")?.stringValue
        transferConfirmAccountDTO.payerName = findChild(node: basicDataNode, childName: "nombreOrdenante")?.stringValue
        if let referenceNode = findChild(node: basicDataNode, childName: "referencia") {
            var refernceDTO = ReferenceDTO()
            refernceDTO.reference = referenceNode.stringValue.trim()
            transferConfirmAccountDTO.reference = refernceDTO
        }
        
        return transferConfirmAccountDTO
    }
    
    private static func findChild(node: XMLElement?, childName: String) -> XMLElement?{
        guard let node = node else {
            return nil
        }
        if let child = node.firstChild(tag: childName){
            return child
        } else {
            for childNode in node.children{
                if let foundChild = findChild(node: childNode, childName: childName){
                    return foundChild
                }
            }
            return nil
        }
    }
}
