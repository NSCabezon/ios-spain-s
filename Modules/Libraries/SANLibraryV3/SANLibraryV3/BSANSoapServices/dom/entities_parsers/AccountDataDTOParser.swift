import Foundation
import Fuzi

class AccountDataDTOParser: DTOParser  {
    public static func parse(_ node: XMLElement) -> AccountDataDTO {
        let checkDigits = node.firstChild(tag:"DIGITO_DE_CONTROL")?.stringValue.trim()
		let accountNumber = node.firstChild(tag:"NUMERO_DE_CUENTA")?.stringValue.trim()
		let bankNode = node.firstChild(tag:"OFICINA")
		let bankCode = bankNode?.firstChild(tag:"ENTIDAD")?.stringValue.trim()
		let branchCode = bankNode?.firstChild(tag:"OFICINA")?.stringValue.trim()
		let accountDataDTO = AccountDataDTO(bankCode: bankCode ?? "", branchCode: branchCode ?? "", checkDigits: checkDigits ?? "", accountNumber: accountNumber ?? "")
        return accountDataDTO
    }
}
