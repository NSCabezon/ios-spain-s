//
//  TimeLineViewMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 05/07/2019.
//

import Foundation
@testable import FinantialTimeline

class TimeLineViewMock: TimeLineViewProtocol {
    var strategy: TLStrategy?
    func showAlert(message: String) {
        
    }
    var presenter: TimeLinePresenterProtocol?
    var spyTimeLineError: Error?
    var spyTimeLineSections: [TimeLineSection] = []
    
    func timeLineDidFail(title: String, error: Error, type: TimeLineEventsErrorType) {
        spyTimeLineError = error
    }
    
    func comingTimeLineLoaded(withSections sections: [TimeLineSection]) {
        spyTimeLineSections = sections
    }
    
    func previousTimeLineLoaded(withSections sections: [TimeLineSection]) {
        spyTimeLineSections = sections
    }
    
    func showMonthSelector(months: [Date]) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func move(to event: TimeLineEvent) {
        
    }
    
    func showMenuOptions(_ items: [MenuItem]) {
        
    }
    
    func scrollToToday() {
        
    }
}
