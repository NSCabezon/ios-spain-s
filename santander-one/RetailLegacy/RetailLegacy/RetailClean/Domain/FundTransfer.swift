import SANLegacyLibrary
import Foundation

class FundTransfer: GenericProduct {
    
    static func create(_ from: FundTransferDTO) -> FundTransfer {
        return FundTransfer(dto: from)
    }
    
    private(set) var fundTransferDTO: FundTransferDTO
    
    var ibanPapel: String {
        guard let ibanDTO = fundTransferDTO.linkedAccount else { return "" }
        
        let iban = IBAN.create(ibanDTO)
        return iban.ibanPapel
    }
    
    var signature: Signature? {
        guard let signature = fundTransferDTO.signature else {
            return nil
        }
        return Signature(dto: signature)
    }
    
    var valueDate: Date? {
        return fundTransferDTO.fundTransferResponseData?.valueDate
    }
    
    internal init(dto: FundTransferDTO) {
        fundTransferDTO = dto
        super.init()
    }
}

extension FundTransfer: OperativeParameter {}
