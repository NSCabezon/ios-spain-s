import CoreFoundationLib

struct EmmaTrackEventList {
    static let globalPositionEventID: String = "647159b57913e7c536791ba336e9385f"
    static let accountsEventID: String = "414e89bcd575e0de086de5522da3cf43"
    static let cardsEventID: String = "25586b0c23d1bdaedbc55f9b3965fa59"
    static let transfersEventID: String = "763872e80b9556d199b5e5e5899fcb1d"
    static let billAndTaxesEventID: String = "9522d9ffe4ab595dc56287b146c84835"
    static let personalAreaEventID: String = "f60ba4d800362a0b9b465a867ce8af47"
    static let managerEventID: String = "179d8a08e199ff27b55622a0b464a208"
    static let customerServiceEventID: String = "9a3a23dbcdfa168c101e8d73ea1d81c8"
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
