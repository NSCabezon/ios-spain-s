//

import Foundation

public struct MultimediaCapacityDTO: Codable {
    public let phone: String
    public let capacity: Bool

    private enum CodingKeys: String, CodingKey {
        case phone = "telefono"
        case capacity = "capacidadMultimedia"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        phone = try values.decode(String.self, forKey: .phone)
        let capacityInt = try values.decode(String.self, forKey: .capacity)
        capacity = (capacityInt == "1")
    }
}

public struct BizumGetMultimediaContactsDTO: Codable {
    public let info: BizumTransferInfoDTO
    public let contacts: [MultimediaCapacityDTO]
    
    private enum CodingKeys: String, CodingKey {
        case info = "info"
        case contacts = "contactos"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        info = try values.decode(BizumTransferInfoDTO.self, forKey: .info)
        // dict -> array
        let contactsDict = try values.decode([String: [MultimediaCapacityDTO]].self, forKey: .contacts)
        contacts = contactsDict["contacto"] ?? [MultimediaCapacityDTO]()
    }
}
