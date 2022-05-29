public struct ImpositionsListDTO: Codable {
    public var impositionsDTOs: [ImpositionDTO] = []
    public var pagination: PaginationDTO?
    
    public init() {}
    
    public init(impositionsDTOs: [ImpositionDTO], pagination: PaginationDTO?) {
        self.impositionsDTOs = impositionsDTOs
        self.pagination = pagination
    }
}
