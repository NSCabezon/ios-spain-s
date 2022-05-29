//
//  OneTransferModule.swift
//  Commons
//
//  Created by Cristobal Ramos Laina on 30/12/21.
//

import CoreFoundationLib

public struct OneTransferPage: PageWithActionTrackable, EmmaTrackable {
    public typealias ActionType = Action
    public let page = "send_money"
    public let emmaToken: String
    public enum Action: String {
        case switches = "click_switch"
        case history = "see_history"
        case newSend = "create_new"
        case newContact = "new_contact"
        case tooltip = "click_tooltip"
        case transfer = "click_transfer"
        case swipeFavorites = "swipe_favourite_carrousel"
        case swipeRecentAndScheduled = "swipe_recent_schedule"
        case seeFavorites = "see_favourite"
        case favouriteDetail = "view_favourite_detail"
        case emmited = "view_issued"
        case received = "view_received"
        case virtualAssistant = "click_different_query"
        case scheduled = "click_scheduled_transfer"
        case international = "click_send_money"
    }
    
    public init() {
        self.emmaToken = ""
    }
    
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}
