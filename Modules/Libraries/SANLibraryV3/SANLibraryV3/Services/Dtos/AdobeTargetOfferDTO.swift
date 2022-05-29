import Foundation
import CoreDomain

struct AdobeTargetOfferDTO: Codable {
    let id: String?
    let groupId: String?
    let locationId: String?
    let renderingType: String?
    let renderingDTO: AdobeTargetRenderingDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case groupId
        case locationId
        case renderingType
        case renderingDTO = "rendering"
    }

    init() {
        self.id = nil
        self.groupId = nil
        self.locationId = nil
        self.renderingType = nil
        self.renderingDTO = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decodeIfPresent(String.self, forKey: .id)
        self.groupId = try? container.decodeIfPresent(String.self, forKey: .groupId)
        self.locationId = try? container.decodeIfPresent(String.self, forKey: .locationId)
        self.renderingType = try? container.decodeIfPresent(String.self, forKey: .renderingType)
        self.renderingDTO = try? container.decodeIfPresent(AdobeTargetRenderingDTO.self, forKey: .renderingDTO)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(groupId, forKey: .groupId)
        try container.encode(locationId, forKey: .locationId)
        try container.encode(renderingType, forKey: .renderingType)
        try container.encode(renderingDTO, forKey: .renderingDTO)
    }
}

struct AdobeTargetRenderingDTO: Codable {
    let url: String?
    let width: Int?
    let height: Int?
    let actionDTO: AdobeTargetActionDTO?

    enum CodingKeys: String, CodingKey {
        case url
        case width
        case height
        case actionDTO = "action"
    }
}

struct AdobeTargetActionDTO: Codable {
    let type: String?
    let dataDTO: AdobeTargetActionDataDTO?

    enum CodingKeys: String, CodingKey {
        case type
        case dataDTO = "data"
    }
}

struct AdobeTargetActionDataDTO: Codable {
    let topTitle: String?
    let title: String?
    let openURL: String?
    let closeURL: String?
    let pdfName: String?
    let parametersDTO: AdobeTargetActionDataParametersDTO?

    enum CodingKeys: String, CodingKey {
        case topTitle
        case title
        case openURL
        case closeURL
        case pdfName
        case parametersDTO = "parameters"
    }
}

struct AdobeTargetActionDataParametersDTO: Codable {
    let token: String?
    let operativa: String?
    let canal: String?
}

extension AdobeTargetOfferDTO: AdobeTargetOfferRepresentable {
    var rendering: AdobeTargetRenderingRepresentable? {
        return renderingDTO
    }
}

extension AdobeTargetRenderingDTO: AdobeTargetRenderingRepresentable {
    var action: AdobeTargetActionRepresentable? {
        return actionDTO
    }
}

extension AdobeTargetActionDTO: AdobeTargetActionRepresentable {
    var data: AdobeTargetActionDataRepresentable? {
        return dataDTO
    }
}

extension AdobeTargetActionDataDTO: AdobeTargetActionDataRepresentable {
    var parameters: AdobeTargetActionDataParametersRepresentable? {
        return parametersDTO
    }
}

extension AdobeTargetActionDataParametersDTO: AdobeTargetActionDataParametersRepresentable {}
