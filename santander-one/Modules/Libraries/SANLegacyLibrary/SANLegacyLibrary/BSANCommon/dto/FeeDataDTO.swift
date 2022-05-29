import CoreDomain

public struct FeeDataDTO: Codable {
    public var minPeriodCount: Int?
    public var maxPeriodCount: Int?
    public var periodInc: Int?
    public var minFeeAmount: String?
    public var JPORCEA1: String?
    public var JTIPOLI: String?
    public var JTIPRAN: String?
    public var LIMITPO1: String?
    public var MLFORPA1: String?

    public init() {}
}

extension FeeDataDTO: FeeDataRepresentable {}
