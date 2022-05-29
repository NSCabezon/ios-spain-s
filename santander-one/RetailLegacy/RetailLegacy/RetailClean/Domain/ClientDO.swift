import SANLegacyLibrary

struct ClientDO {
    private(set) var dto: ClientDTO?
    
    init?(dto: ClientDTO?) {
        self.dto = dto
    }
    
    var personType: String? {
        return dto?.personType
    }
    var personCode: String? {
        return dto?.personCode
    }
    
}
