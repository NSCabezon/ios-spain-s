import Foundation

public struct BizumGetMultimediaContentDTO: Codable {
    public let info: BizumTransferInfoDTO
    public let additionalContentList: [AdditionalContentList]
    public let orderingUserId: String
    public let beneficiaryUserId: String

    private enum CodingKeys: String, CodingKey {
        case info
        case additionalContentList = "listaContenidoAdicional"
        case orderingUserId = "idUsuarioOrdenante"
        case beneficiaryUserId = "idUsuarioBeneficiario"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        info = try values.decode(BizumTransferInfoDTO.self, forKey: .info)
        let additionalContentDict = try values.decodeIfPresent([String: [AdditionalContentList]].self, forKey: .additionalContentList)
        additionalContentList = additionalContentDict?["contenidoAdicional"] ?? [AdditionalContentList]()
        orderingUserId = try values.decode(String.self, forKey: .orderingUserId)
        beneficiaryUserId = try values.decode(String.self, forKey: .beneficiaryUserId)
    }
}

public struct AdditionalContentList: Codable {
    public let requestType: String
    public let emitterUserId: String
    public let image: String?
    public let imageFormat: String?
    public let text: String?

    private enum CodingKeys: String, CodingKey {
        case requestType = "tipoPeticion"
        case emitterUserId = "idUsuarioEmisor"
        case image = "imagen"
        case imageFormat = "formatoImagen"
        case text = "texto"
    }
}
