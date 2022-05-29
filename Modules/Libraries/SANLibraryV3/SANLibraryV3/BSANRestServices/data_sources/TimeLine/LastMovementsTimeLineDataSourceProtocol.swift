//

import Foundation

protocol LastMovementsTimeLineDataSourceProtocol: RestDataSource {
    func loadMovements(_ parameters: TimeLineMovementsParameters) throws -> BSANResponse<TimeLineResponseDTO> 
}
