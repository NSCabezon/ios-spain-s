struct CardMovementLocationParams: Encodable {
    let pan: String
    let amount: String
    let date: String
    let concept: String
    
    enum CodingKeys: String, CodingKey {
        case pan
        case amount = "importe"
        case date = "fecha"
        case concept = "concepto"
    }
}

struct CardMovementListLocationsParams: Encodable {
    let pan: String
    let transactions: String
}

struct CardMovementLocationsByDateParams: Encodable {
    let pan: String
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case pan
        case startDate = "fechaDesde"
        case endDate = "fechaHasta"
    }
}

protocol CardMovementLocationDataSourceProtocol: RestDataSource {
    func loadCardMovementLocation(params: CardMovementLocationParams) throws -> BSANResponse<CardMovementLocationDTO>
    func loadCardMovementListLocations(params: CardMovementListLocationsParams) throws -> BSANResponse<CardMovementLocationListDTO>
    func loadCardMovementLocationsByDate(params: CardMovementLocationsByDateParams) throws -> BSANResponse<CardMovementLocationListDTO>
}
