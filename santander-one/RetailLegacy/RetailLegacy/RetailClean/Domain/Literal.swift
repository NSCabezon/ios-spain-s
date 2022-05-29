import SANLegacyLibrary

struct Literal {
    
    var concept: String? {
        return literalDTO?.concept
    }
    
    var literal: String? {
        return literalDTO?.literal
    }
    
    private var literalDTO: LiteralDTO?
    
    init(_ dto: LiteralDTO) {
        literalDTO = dto
    }
    
    func createFomDTO(_ dto: LiteralDTO) -> Literal {
        return Literal(dto)
    }
    
}
