//

import Foundation

public struct BillCollectionListRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let language: String
    public let dialect: String
    public let paginationDTO: PaginationDTO?
    public let accountDTO: AccountDTO
    public let transmitterCode: String
}
 
