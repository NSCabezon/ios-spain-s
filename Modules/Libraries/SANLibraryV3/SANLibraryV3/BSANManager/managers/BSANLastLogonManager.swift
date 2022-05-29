//

import Foundation
import SANLegacyLibrary

public class BSANLastLogonManagerImplementation: BSANBaseManager, BSANLastLogonManager {
    
    var sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getLastLogonInfo() throws -> BSANResponse<LastLogonDTO> {
        let dataSource = LastLogonDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        
        return try dataSource.getLastLogonDate()
    }
    
    public func insertDateUpdate() throws -> BSANResponse<Void> {
        let dataSource = InsertDateUpdateDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.insertDateUpdate()
    }
}
