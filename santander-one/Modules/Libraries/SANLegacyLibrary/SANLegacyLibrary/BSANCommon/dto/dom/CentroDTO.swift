public struct CentroDTO: Codable {
    public var empresa: String = ""
    public var centro: String = ""
    
    public init() {}
    
    public init(empresa: String, centro: String) {
        self.empresa = empresa
        self.centro = centro
    }
}

extension CentroDTO: Equatable {
    public static func == (lhs: CentroDTO, rhs: CentroDTO) -> Bool {
        return lhs.empresa == rhs.empresa && lhs.centro == rhs.centro
    }
}
