import CoreDomain

public class ContactPhoneEntity {
    public let dto: ContactPhoneDTO?
    
    public init(dto: ContactPhoneDTO) {
        self.dto = dto
    }
    
    public var title: String? {
        return dto?.title
    }
    
    public var desc: String? {
        return dto?.desc
    }
    
    public var numbers: [String]? {
        return dto?.numbers
    }
}

extension ContactPhoneEntity: ContactPhoneRepresentable { }
