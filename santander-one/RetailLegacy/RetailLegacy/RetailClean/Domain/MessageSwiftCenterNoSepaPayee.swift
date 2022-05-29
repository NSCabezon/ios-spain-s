import SANLegacyLibrary
import Foundation

class MessageSwiftCenterNoSepaPayee {
    static func create(_ from: MessageSwiftCenterNoSepaPayeeDTO) -> MessageSwiftCenterNoSepaPayee {
        return MessageSwiftCenterNoSepaPayee(dto: from)
    }
    
    private(set) var messageSwiftCenterNoSepaPayeeDTO: MessageSwiftCenterNoSepaPayeeDTO
    init(dto: MessageSwiftCenterNoSepaPayeeDTO) {
        messageSwiftCenterNoSepaPayeeDTO = dto
    }
    
    var company: String? {
        return messageSwiftCenterNoSepaPayeeDTO.company
    }
    
    var center: String? {
        return messageSwiftCenterNoSepaPayeeDTO.center
    }
}
