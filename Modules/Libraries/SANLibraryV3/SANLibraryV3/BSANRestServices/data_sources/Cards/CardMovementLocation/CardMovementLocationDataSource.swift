class CardMovementLocationDataSource {
    let sanRestServices: SanRestServices
    private let bsanEnvironment: BSANEnvironmentDTO
    private let basePath = "/api/v1/envioPagos/geolocalizacion/"
    private let oneLocationServiceName = "oneTransaction"
    private let multipleLocationServiceName = "nTransaction"
    private let dateLocationServiceName = "dateTransaction"
    private let headers = ["X-Santander-Channel" : "RML"]

    init(sanRestServices: SanRestServices, bsanEnvironment: BSANEnvironmentDTO) {
        self.sanRestServices = sanRestServices
        self.bsanEnvironment = bsanEnvironment
    }
}

extension CardMovementLocationDataSource: CardMovementLocationDataSourceProtocol {
    func loadCardMovementLocation(params: CardMovementLocationParams) throws -> BSANResponse<CardMovementLocationDTO> {
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(Meta.createKO())
        }
        let url = source + self.basePath + self.oneLocationServiceName
        return try self.executeRestCall(
            serviceName: self.oneLocationServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
    
    func loadCardMovementListLocations(params: CardMovementListLocationsParams) throws -> BSANResponse<CardMovementLocationListDTO> {
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(Meta.createKO())
        }
        let url = source + self.basePath + self.multipleLocationServiceName
        return try self.executeRestCall(
            serviceName: self.multipleLocationServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
    
    func loadCardMovementLocationsByDate(params: CardMovementLocationsByDateParams) throws -> BSANResponse<CardMovementLocationListDTO> {
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(Meta.createKO())
        }
        let url = source + self.basePath + self.dateLocationServiceName
        return try self.executeRestCall(
            serviceName: self.dateLocationServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
}
