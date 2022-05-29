//

import Foundation

public class CardSettlementDetailDataSource: CardSettlementDetailDataSourceProtocol {
    
    let sanRestServices: SanRestServices
    private let bsanEnvironment: BSANEnvironmentDTO
    private let serviceName = "getDetalleLiquidacion"
    private let baseUrl = "/api/v1/tarjetasliq/"
    private let headers = ["X-Santander-Channel": "RML"]
    
    init(sanRestServices: SanRestServices, bsanEnvironment: BSANEnvironmentDTO) {
        self.sanRestServices = sanRestServices
        self.bsanEnvironment = bsanEnvironment
    }
    
    func getCardSettlementDetail(params: CardSettlementDetailRequestParams) throws -> BSANResponse<CardSettlementDetailDTO> {
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(Meta.createKO())
        }
        let response: BSANResponse<CardSettlementDetailResponseDTO> = try self.executeRestCall(
            serviceName: self.serviceName,
            serviceUrl: source + baseUrl + self.serviceName,
            params: params,
            contentType: .json,
            requestType: .post,
            headers: headers)
        guard let data = try response.getResponseData()?.settlementDetails?.first else {
            if let errorCode = try response.getResponseData()?.statusCode {
                return BSANOkResponse(CardSettlementDetailDTO(errorCode: errorCode))
            }
            return BSANErrorResponse(Meta.createKO())
        }
        
        return BSANOkResponse(data)
    }
}

public struct CardSettlementDetailRequestParams: Codable {
    let contractNumber: String
    let cmc: String
    let date: String

    enum CodingKeys: String, CodingKey {
        case contractNumber = "contratoTarjeta"
        case cmc = "cmc"
        case date = "fechaLiquidacion"
    }
}
