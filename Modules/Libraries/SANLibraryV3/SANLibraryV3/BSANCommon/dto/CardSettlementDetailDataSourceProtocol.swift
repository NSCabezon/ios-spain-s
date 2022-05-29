//

import Foundation

protocol CardSettlementDetailDataSourceProtocol: RestDataSource {
    func getCardSettlementDetail(params: CardSettlementDetailRequestParams) throws -> BSANResponse<CardSettlementDetailDTO>
}
