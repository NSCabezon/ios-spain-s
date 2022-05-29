//

import Foundation

public struct ConsultTaxCollectionRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let language: String
    public let dialect: String
    public let accountDTO: AccountDTO
    public var emitterCode: String?
    public var productIdentifier: String?
    public var collectionTypeCode: String?
    public var collectionCode: String?
}
