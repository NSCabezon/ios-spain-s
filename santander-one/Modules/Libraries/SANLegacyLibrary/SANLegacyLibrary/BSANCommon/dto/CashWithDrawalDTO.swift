public struct CashWithDrawalDTO: Codable {
    public var descListaActivadorClave: String?
    public var amountDisp: String?
    public var monedaDisp: String?
    public var expirationDate: String?
    public var decryptedDataDTO: DecryptedDataDTO?
    
    public init() {}
}
