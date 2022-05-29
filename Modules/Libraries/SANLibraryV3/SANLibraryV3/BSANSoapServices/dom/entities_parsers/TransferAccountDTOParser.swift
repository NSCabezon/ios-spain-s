//

import Foundation
import Fuzi

class TransferAccountDTOParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> TransferAccountDTO {
        
        var transferAccountDTO = TransferAccountDTO()
        
        let basicDataAndSignatureNode = node.firstChild(tag: "datosBasicosYFirma")
        let basicDataNode = basicDataAndSignatureNode?.firstChild(tag: "datosBasicos")
        let signatureNode = basicDataAndSignatureNode?.firstChild(tag: "datosFirma")
        
        if let dateNode = basicDataNode?.firstChild(tag: "fechaEmisionTransf") {
            transferAccountDTO.issueDate = DateFormats.safeDate(dateNode.stringValue)
        }
        if let transferAmountNode = basicDataNode?.firstChild(tag: "impTransferencia") {
            transferAccountDTO.transferAmount = AmountDTOParser.parse(transferAmountNode)
        }
        if let bankChargeAmountNode = basicDataNode?.firstChild(tag: "impComision") {
            transferAccountDTO.bankChargeAmount = AmountDTOParser.parse(bankChargeAmountNode)
        }
        if let netNode = basicDataNode?.firstChild(tag: "impLiquido") {
            transferAccountDTO.netAmount = AmountDTOParser.parse(netNode)
        }
        if let expensesNode = basicDataNode?.firstChild(tag: "impGastos") {
            transferAccountDTO.expensesAmount = AmountDTOParser.parse(expensesNode)
        }
        if let signatureNode = signatureNode {
            transferAccountDTO.scaRepresentable = SignatureDTOParser.parse(signatureNode)
        }
        
        transferAccountDTO.beneficiaryName = node.firstChild(tag: "nombreBeneficiario")?.stringValue
        transferAccountDTO.destinationAccountDescription = basicDataNode?.firstChild(tag: "descCuentaAbono")?.stringValue
        transferAccountDTO.originAccountDescription = basicDataNode?.firstChild(tag: "descCuentaCargo")?.stringValue
        transferAccountDTO.payerName = basicDataNode?.firstChild(tag: "nombreOrdenante")?.stringValue
        
        return transferAccountDTO
    }
}
