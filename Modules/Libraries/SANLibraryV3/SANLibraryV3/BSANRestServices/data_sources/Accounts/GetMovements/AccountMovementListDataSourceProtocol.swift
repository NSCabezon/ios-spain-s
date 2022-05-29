//

import Foundation

protocol AccountMovementListDataSourceProtocol: RestDataSource {
    func loadAccountMovementsList(params: AccountMovementListParams, account: String) throws -> BSANResponse<AccountMovementListDTO>
}
