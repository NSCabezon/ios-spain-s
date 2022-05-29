//

import Foundation

protocol AccountFutureBillListDataSourceProtocol: RestDataSource {
    func loadAccountFutureBillList(params: AccountFutureBillParams) throws -> BSANResponse<AccountFutureBillListDTO>
}
