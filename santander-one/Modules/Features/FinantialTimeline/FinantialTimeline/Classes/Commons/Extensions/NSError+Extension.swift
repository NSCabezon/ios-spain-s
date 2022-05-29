//
//  NSError+Extensions.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 01/07/2019.
//

import Foundation

enum TimeLineError: LocalizedError {
    
    case unknown
    case noMorePreviousEvents
    case noMoreComingEvents
    case noEvents
    case oneActivity

    var errorDescription: String? {
        switch self {
        case .unknown: return GeneralString().errorUnknow
        case .noMoreComingEvents: return TimeLineString().noMoreComingEvents
        case .noMorePreviousEvents: return TimeLineString().noMorePreviousEvents
        case .noEvents: return TimeLineString().emptyStateSubtitle
        case .oneActivity: return GeneralString().errorUnknow
        }
    }
}
