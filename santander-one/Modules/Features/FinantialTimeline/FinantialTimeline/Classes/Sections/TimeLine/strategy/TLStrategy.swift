//
//  TimeLineStrategy.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 07/01/2020.
//

import Foundation

protocol TLStrategy: class {
    func onFailure(with title: String, error: Error, type: TimeLineEventsErrorType)
    func onLoading()
    func onSucces(with sections: [TimeLineSection], completion: @escaping() -> Void)
    func mapComingResult(_ timeLine: TimeLineEvents) -> TimeLineEvents
    func isList() -> Bool
    func shouldPresentFooter() -> Bool
    func getTopLoaderHeight() -> CGFloat
    func timeLineEventNumberOfLines() -> Int
    func timeLineEventLineHeightMultiplier() -> CGFloat
}
