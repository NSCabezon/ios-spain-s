public struct HistoricalWithdrawalDTO: Codable {
    public var dispensationList: [DispensationDTO]?
    public var numHayMasDisp: Int?
    public var descListaActivadorClave: String?
    public var codResp: Int?
    
    public init() {}
}
