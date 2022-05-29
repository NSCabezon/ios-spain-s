import Foundation
import CoreFoundationLib
import SANLegacyLibrary

struct PensionInfoOperation {
    private(set) var pensionInfoOperationDTO: PensionInfoOperationDTO
    
    init(_ dto: PensionInfoOperationDTO) {
        self.pensionInfoOperationDTO = dto
    }
    
    var date: Date? {
        return pensionInfoOperationDTO.valueDate
    }
    
    var description: String? {
        return pensionInfoOperationDTO.descPension?.trim()
    }
    
    var holder: String? {
        return pensionInfoOperationDTO.holder
    }
    
    var associatedAccount: String? {
        guard let pensionAccountAssociated = pensionInfoOperationDTO.pensionAccountAssociated else { return nil }
        let ibanAssociatedAccount = IBAN.create(pensionAccountAssociated)
        return ibanAssociatedAccount.ibanPapel
    }

    var ccc: String {
        guard let ibanDTO = pensionInfoOperationDTO.pensionAccountAssociated else { return "" }
        let iban = IBAN.create(ibanDTO)
        return iban.ccc
    }
    
    var associatedAccountIban: IBAN {
        guard let ibanDTO = pensionInfoOperationDTO.pensionAccountAssociated else { return IBAN.createEmpty() }
        return IBAN.create(ibanDTO)
    }

}

extension PensionInfoOperation: OperativeParameter {}
