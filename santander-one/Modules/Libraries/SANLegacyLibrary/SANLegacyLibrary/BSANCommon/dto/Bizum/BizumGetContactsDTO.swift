import Foundation

public struct PhoneListDTO: Codable {
    public let phoneList: [String]

    private enum CodingKeys: String, CodingKey {
        case phoneList = "telefono"
    }
}

public struct BizumGetContactsDTO: Codable {
    public let contact: PhoneListDTO
    
    private enum CodingKeys: String, CodingKey {
        case contact = "contacto"
    }
}
