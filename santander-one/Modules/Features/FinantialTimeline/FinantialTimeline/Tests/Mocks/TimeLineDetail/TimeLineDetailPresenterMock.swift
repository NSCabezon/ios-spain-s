//
//  TimeLineDetailPresenterMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/09/2019.
//

import Foundation
import XCTest
@testable import FinantialTimeline

class TimeLineDetailPresenterMock: TimeLineDetailPresenterProtocol {
    func getPeriodicEvent() -> PeriodicEvent? {
     return nil
    }
    
    func getMasterPersonalEvent(code: String) {
        
    }
    
    func deleteEvent() {
        
    }
    
    func deleteEventConfirmed() {
        
    }
    
    func onAxisFromChartSelected(_ axis: Double) {
    }
    
    func createAlert() {
        
    }
    
    func deleteAlert() {
        
    }
    
    func alertSelected(type: AlertType) {
        
    }
    
    func getDetail() -> TimeLineEvent? {
        let decoder = JSONDecoder()
        let detail = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_detail", type: "json"))
        return detail
    }
    
    func deleteAlertConfirmed() {
        
    }
    
    
    var expectation: XCTestExpectation?
    
    func viewDidLoad() {
        expectation?.fulfill()
    }
    
    func didSelectBack() {
        
    }
    
}
