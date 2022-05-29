import CoreDomain

public struct DocumentDTO: Codable {
    public var document: String?
    
    public init() {}
}

extension DocumentDTO: LoanPdfRepresentable {}
