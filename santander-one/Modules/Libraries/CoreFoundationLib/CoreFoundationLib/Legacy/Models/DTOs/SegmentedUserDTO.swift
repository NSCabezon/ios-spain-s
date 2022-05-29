import Foundation

// MARK: - SegmentedUserDTO
public struct SegmentedUserDTO: Codable {
    // Spb User
    public let spb: [SegmentedUserTypeDTO]
    // Generic User
    public let generic: [SegmentedUserTypeDTO]
}

// MARK: - Spb User
public struct SegmentedUserTypeDTO: Codable {
    public let bdpType: String
    public let commercialSegments: [CommercialSegmentsDTO]
}

// MARK: - Commercial Segment
public struct CommercialSegmentsDTO: Codable {
    public let commercialType: String
    public let semanticSegmentType: SemanticSegmentTypeDTO?
    public let contact: ContactSegmentDTO
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.commercialType = try values.decode(String.self, forKey: .commercialType)
        self.contact = try values.decode(ContactSegmentDTO.self, forKey: .contact)
        self.semanticSegmentType = try? values.decodeIfPresent(SemanticSegmentTypeDTO.self, forKey: .semanticSegmentType)
    }
}

public enum SemanticSegmentTypeDTO: String, Codable, CodingKey {
    case select, universitarios, retail
}

// MARK: - Contact
public struct ContactSegmentDTO: Codable {
    public let superlinea: ContactPhoneDTO?
    public let cardBlock: ContactPhoneDTO?
    public let fraudFeedback: ContactPhoneDTO?
    public let contactTwitter: ContactSocialNetworkDTO?
    public let contactFacebook: ContactSocialNetworkDTO?
    public let contactWhatsapp: ContactSocialNetworkDTO?
    public let contactMail: ContactSocialNetworkDTO?
}

// MARK: - Contact Phone
public struct ContactPhoneDTO: Codable {
    public let title: String
    public let desc: String?
    public let numbers: [String]
}

// MARK: - Contact Social Network
public struct ContactSocialNetworkDTO: Codable {
    public let active: ActiveDTO
    public let url: String?
    public let appUrl: String?
    public let mail: String?
    public let phone: String?
    public let hint: String?
}

public enum ActiveDTO: String, Codable {
    case yes = "Y"
    case dont = "N"
}
