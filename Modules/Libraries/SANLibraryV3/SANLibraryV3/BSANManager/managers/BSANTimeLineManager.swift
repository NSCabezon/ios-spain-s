//

import Foundation
import SANLegacyLibrary

public class BSANTimeLineManagerImplementation: BSANBaseManager, BSANTimeLineManager {
    private let sanRestServices: SanRestServices
    private var timeLineMovementsData: TimeLineMovementDTO?

    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getMovements(_ input: TimeLineMovementsParameters) throws -> BSANResponse<TimeLineResponseDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        guard let _ = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let datasource = LastMovementsTimeLineDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let response = try datasource.loadMovements(input)
        return response
    }
}

