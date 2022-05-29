public struct DocumentEntityAuthPaymentDTO: Codable {
    public var type: String?
    public var code: String?

    public init() {}
}

public struct EntityAuthPaymentDTO: Codable {
    public var document: DocumentEntityAuthPaymentDTO?
    public var address: String?
    public var town: String?
    public var typeDocumentDescription: String?

    public init() {}
}
