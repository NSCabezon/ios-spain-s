//

import Foundation

public class CardSettlementMovementsDataSource: CardSettlementMovementsDataSourceProtocol {
    
    let sanRestServices: SanRestServices
    private let bsanEnvironment: BSANEnvironmentDTO
    private let serviceName = "getMovLiquidacion"
    private let baseUrl = "/api/v1/tarjetasliq/"
    private let headers = ["X-Santander-Channel": "RML"]
    
    init(sanRestServices: SanRestServices, bsanEnvironment: BSANEnvironmentDTO) {
        self.sanRestServices = sanRestServices
        self.bsanEnvironment = bsanEnvironment
    }
    
    func getCardSettlementListMovements(params: CardSettlementMovementsRequestParams) throws -> BSANResponse<[CardSettlementMovementDTO]> {
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(Meta.createKO())
        }
        return try self.executeRestCall(
            serviceName: self.serviceName,
            serviceUrl: source + baseUrl + self.serviceName,
            params: params,
            contentType: .json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
    
    func getCardSettlementListMovementsByContract(params: CardSettlementMovementsRequestParams) throws -> BSANResponse<[CardSettlementMovementWithPANDTO]> {
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(Meta.createKO())
        }
        return try self.executeRestCall(
            serviceName: self.serviceName,
            serviceUrl: source + baseUrl + self.serviceName,
            params: params,
            contentType: .json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
}

public struct CardSettlementMovementsRequestParams: Codable {
    let contractNumber: String
    let cmc: String
    let extractNumber: Int
    let pan: String

    enum CodingKeys: String, CodingKey {
        case contractNumber = "contratoTarjeta"
        case cmc = "cmc"
        case extractNumber = "numExtracto"
        case pan = "pan"
    }
}
