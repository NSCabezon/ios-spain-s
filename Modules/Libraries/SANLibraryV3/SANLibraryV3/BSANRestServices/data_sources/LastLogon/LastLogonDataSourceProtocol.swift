//

import Foundation

protocol LastLogonDataSourceProtocol: RestDataSource {
    func getLastLogonDate() throws -> BSANResponse<LastLogonDTO>
}
