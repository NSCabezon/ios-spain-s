import CoreFoundationLib

struct EmmaTrackEventList {
    static let globalPositionEventID: String = "69ab14945990e8331cf19e8a22361fa0"
    static let accountsEventID: String = "9b23acfd694b244edd21dec7f20875a1"
    static let cardsEventID: String = "59f215966bb34782685fa3fa7b27ea9b"
    static let transfersEventID: String = "83a265950fe58020f00dee1138ffb8d7"
    static let billAndTaxesEventID: String = "e4341a09ab8bf1779ad902dc9036a543"
    static let personalAreaEventID: String = "e4744e9e6b9a866a7d042f18260c1603"
    static let managerEventID: String = "e4d77ec3b0f72c2308107a600a74a09e"
    static let customerServiceEventID: String = "37d188dd073c18e390e889bf5da3881d"
}

extension EmmaTrackEventList: EmmaTrackEventListProtocol {
    var globalPositionEventID: String {
        return EmmaTrackEventList.globalPositionEventID
    }
    
    var accountsEventID: String {
        return EmmaTrackEventList.accountsEventID
    }
    
    var cardsEventID: String {
        return EmmaTrackEventList.cardsEventID
    }
    
    var transfersEventID: String {
        return EmmaTrackEventList.transfersEventID
    }
    
    var billAndTaxesEventID: String {
        return EmmaTrackEventList.billAndTaxesEventID
    }
    
    var personalAreaEventID: String {
        return EmmaTrackEventList.personalAreaEventID
    }
    
    var managerEventID: String {
        return EmmaTrackEventList.managerEventID
    }
    
    var customerServiceEventID: String {
        return EmmaTrackEventList.customerServiceEventID
    }
}
