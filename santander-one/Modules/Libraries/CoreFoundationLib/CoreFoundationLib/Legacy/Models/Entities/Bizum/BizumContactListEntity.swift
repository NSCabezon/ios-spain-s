import SANLegacyLibrary

public class BizumContactListEntity {
    let dto: BizumGetContactsDTO
    
    public init(_ dto: BizumGetContactsDTO) {
        self.dto = dto
    }
    
    public var contactList: [String] {
        return self.dto.contact.phoneList
    }
}
