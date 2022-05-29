public struct CustomerContractListDTO: Codable {
    public let customerContractListDto: [CustomerContractDTO]
    
    enum CodingKeys: String, CodingKey {
        case customerContractListDto = "customerContractList"
    }
}
