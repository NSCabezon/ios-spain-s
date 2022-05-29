public struct SignatureDataDTO: Codable {
    public var signatureActivityStatusInd: String?
    public var signaturePhaseStatusInd: String?
    public var list: [SignatureUserItemDTO]?
    public var signatureDTO: SignatureDTO?
    
    public init () {}
}
