struct EcommerceConfirmationError: Codable {
    let status: String
    let descError: [EcommerceConfirmationSpecificError]
    enum CodingKeys: String, CodingKey {
        case status = "estado"
        case descError
    }
}

struct EcommerceConfirmationSpecificError: Codable {
    let language: String
    let value: String
}
