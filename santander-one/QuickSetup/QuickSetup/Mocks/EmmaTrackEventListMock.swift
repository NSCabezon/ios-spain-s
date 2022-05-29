import CoreFoundationLib

public final class EmmaTrackEventListMock: EmmaTrackEventListProtocol {
    public var globalPositionEventID: String = ""
    public var accountsEventID: String = ""
    public var cardsEventID: String = ""
    public var transfersEventID: String = ""
    public var billAndTaxesEventID: String = ""
    public var personalAreaEventID: String = ""
    public var managerEventID: String = ""
    public var customerServiceEventID: String = ""
    public init() {}
}
