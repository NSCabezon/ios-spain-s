import CoreFoundationLib

struct EmmaTrackEventList {
    static let globalPositionEventID: String = "4a55b7f57367a361dcbeb8d0d90f362a"
    static let accountsEventID: String = "30825fc2d6e84b62e33d7443dbbcc58a"
    static let cardsEventID: String = "0f1b3a641ded50fe42a024e3063566b6"
    static let transfersEventID: String = "1c5ecb2df88413dd86e1b710000971cf"
    static let billAndTaxesEventID: String = "71006057ab62c4c7d267dd5efd2aeb0a"
    static let personalAreaEventID: String = "ae05d4fe4c38385e7d74351b2865fa4c"
    static let managerEventID: String = "870b09f53c50ad7e682d4d5ca05c8e6a"
    static let customerServiceEventID: String = "2008d3f5dda2f0a72035b2808902d283"
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
