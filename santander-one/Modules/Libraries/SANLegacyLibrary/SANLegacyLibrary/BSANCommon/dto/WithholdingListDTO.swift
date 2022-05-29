public struct WithholdingListDTO: Codable {
    public let withholdingDTO: [WithholdingDTO]
    
    private enum CodingKeys: String, CodingKey {
        case withholdingDTO = "retenciones"
    }
    
    public init(withholdingDTO: [WithholdingDTO]) {
        self.withholdingDTO = withholdingDTO
    }
}
