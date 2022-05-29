//

import Foundation

protocol Click2CallDataSourceProtocol: RestDataSource {
    func getClick2Call(_ reason: String?) throws -> BSANResponse<Click2CallDTO>
}
