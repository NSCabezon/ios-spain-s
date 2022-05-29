//

import Foundation
protocol BranchLocatorDataSourceProtocol: RestDataSource {
 func getNearATMs(_ input: BranchLocatorATMParameters) throws -> BSANResponse<[BranchLocatorATMDTO]>
 func getEnrichedATM(_ input: BranchLocatorEnrichedATMParameters) throws -> BSANResponse<[BranchLocatorATMEnrichedDTO]>
}

