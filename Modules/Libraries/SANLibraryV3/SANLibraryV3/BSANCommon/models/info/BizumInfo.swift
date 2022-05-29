import Foundation
import SANLegacyLibrary

public struct BizumInfo: Codable {
    public var historicOperationsDictionary: [String : BizumOperationListDTO] = [:]
    public var historicMultipleOperationsDictionary: [String : BizumOperationMultiListDTO] = [:]
    public var bizumGetContactsDictionary: [String : BizumGetContactsDTO] = [:]
    public var bizumCheckPayment: BizumCheckPaymentDTO?
    public var bizumOrganizationsDictionary: [String : BizumOrganizationsListDTO] = [:]
    public var redsysDocument: BizumRedsysDocumentDTO?
}
