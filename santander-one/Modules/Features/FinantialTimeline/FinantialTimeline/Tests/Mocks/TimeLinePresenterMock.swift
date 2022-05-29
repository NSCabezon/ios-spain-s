//
//  TimeLinePresenterMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 02/08/2019.
//

import Foundation
@testable import FinantialTimeline

class TimeLinePresenterMock: TimeLinePresenterProtocol {
    func setFirstLoad() {
        
    }
    
    
    var spyViewDidLoadCalled = false
    var spyTimeLineLoadedCalled = false
    
    var isLoadMoreComingEventsAvailable: Bool
    var isLoadMorePreviousEventsAvailable: Bool
    
    init(isLoadMoreComingEventsAvailable: Bool, isLoadMorePreviousEventsAvailable: Bool) {
        self.isLoadMoreComingEventsAvailable = isLoadMoreComingEventsAvailable
        self.isLoadMorePreviousEventsAvailable = isLoadMorePreviousEventsAvailable
    }
    
    func loadTimeLine() {
        
    }
    
    func loadMoreComingTimeLineEvents() {
        
    }
    
    func loadMorePreviousTimeLineEvents() {
        
    }
    
    func didSelectMonth(_ month: Date) {
        
    }
    
    func viewDidLoad() {
        spyViewDidLoadCalled = true
    }
    
    func didSelectTimeLineEvent(_ event: TimeLineEvent) {
        
    }
    
    func didSelectBack() {
        
    }
    
    func timeLineLoaded() {
        spyTimeLineLoadedCalled = true
    }
    
    func exportEventsToCalendar() {
        
    }
    
    func goToSettings() {
        
    }
}
