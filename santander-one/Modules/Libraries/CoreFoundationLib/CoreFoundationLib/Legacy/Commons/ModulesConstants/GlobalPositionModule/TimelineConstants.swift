//
//  TimelineConstants.swift
//  Commons
//
//  Created by Francisco del Real Escudero on 29/6/21.
//

public struct TimeLinePage: PageWithActionTrackable {
    public let page: String = "timeline"
    
    public enum ActionType: String {
        case openDetail = "open_detail"
        case link = "click_link"
    }
    
    public init() {}
}

public struct TimeLineRecordDetailPage: PageWithActionTrackable {
    public let page: String = "timeline_detail"
    
    public enum ActionType: String {
        case link = "click_link_detail"
    }
    
    public init() {}
}
