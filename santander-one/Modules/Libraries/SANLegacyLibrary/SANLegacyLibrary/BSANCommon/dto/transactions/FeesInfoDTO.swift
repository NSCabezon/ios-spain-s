import SwiftyJSON
import CoreDomain

public struct FeesInfoDTO: Codable {
    public var settlementDate: String?
    public let comission: Int?
    public let interests: Double?
    public let feeImport: Double?
    public let totalImport: Double?
    public let taeImport: Double?
    public let personCode: Int?
    public let personType: String?
    public let currency: String
    public var totalMonths: Int?
    
    public init(json: JSON) {
        self.settlementDate = json["fecliq"].string
        self.comission = json["icomaper"].int
        self.interests = json["iminters"].double
        self.feeImport = json["imprtcuo"].double
        self.totalImport = json["imtocdrv"].double
        self.taeImport = json["interate"].double
        self.personCode = json["numclie"].int
        self.personType = json["tipclien"].string
        self.currency = json["codmone1"].string ?? "EUR"
    }
    
    public init(representable: FeesInfoRepresentable) {
        self.comission = representable.comission
        self.interests = representable.interests
        self.feeImport = representable.feeImport
        self.totalImport = representable.totalImport
        self.taeImport = representable.taeImport
        self.personCode = representable.personCode
        self.personType = representable.personType
        self.currency = representable.currency
    }
}

extension FeesInfoDTO: FeesInfoRepresentable {}
