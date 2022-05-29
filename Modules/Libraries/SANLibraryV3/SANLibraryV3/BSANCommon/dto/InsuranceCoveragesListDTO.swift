import SwiftyJSON

public struct InsuranceCoveragesListDTO: Codable, RestParser {
    public let coverages: [InsuranceCoverageDTO]
    
    public init(json: JSON) {
        self.coverages = json["coverages"].array?.map({ InsuranceCoverageDTO(json: $0) }) ?? []
    }
}
