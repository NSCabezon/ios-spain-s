//

import Foundation
import SANLegacyLibrary

public class BSANBranchLocatorManagerImplementation: BSANBaseManager, BSANBranchLocatorManager {
    private let sanRestServices: SanRestServices
    private var globileServiceResponse: BranchLocatorATMDTO?

    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getNearATMs(_ input: BranchLocatorATMParameters) throws -> BSANResponse<[BranchLocatorATMDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        guard let _ = bsanEnvironment.branchLocatorGlobile else {
            return BSANErrorResponse(nil)
        }
        let datasource = BranchLocatorDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let response = try datasource.getNearATMs(input)
        return response
    }

    public func getEnrichedATM(_ input: BranchLocatorEnrichedATMParameters) throws -> BSANResponse<[BranchLocatorATMEnrichedDTO]>
    {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        guard let _ = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let datasource = BranchLocatorDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let response = try datasource.getEnrichedATM(input)
        return response
    }
}

