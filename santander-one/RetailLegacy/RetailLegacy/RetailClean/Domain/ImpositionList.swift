import SANLegacyLibrary

struct ImpositionsList {
    
    let impositions: [Imposition]?
    let pagination: PaginationDO?
    
    init(_ dto: ImpositionsListDTO? = nil) {
        self.impositions = dto?.impositionsDTOs.map { Imposition($0) }
        self.pagination = PaginationDO(dto: dto?.pagination)
    }
}
