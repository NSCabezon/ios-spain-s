import CoreFoundationLib

public struct PTScheduledTransfersInput {
    public var maxRecords: Int
}

public struct PTScheduledTransfersOKOutput {
    public var standingOrderList: [StandingOrderEntity]
    public init(standingOrderList: [StandingOrderEntity]) {
        self.standingOrderList = standingOrderList
    }
}
