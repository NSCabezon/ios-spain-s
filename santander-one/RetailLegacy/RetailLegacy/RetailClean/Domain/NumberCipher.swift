import SANLegacyLibrary
import CoreFoundationLib

struct NumberCipher {
    let dto: NumberCipherDTO
    
    init(_ dto: NumberCipherDTO) {
        self.dto = dto
    }
    
    var numberDecrypted: String? {
        return self.dto.numDecrypted
    }
    
    var numberCipher: String? {
        return self.dto.numCipher
    }
}

extension NumberCipher: OperativeParameter {}
extension NumberCipher: DTOInstantiable {}
