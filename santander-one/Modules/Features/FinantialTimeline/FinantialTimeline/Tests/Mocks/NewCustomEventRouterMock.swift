//
//  NewCustomEventRouterMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 13/09/2019.
//

import Foundation
import XCTest
@testable import FinantialTimeline

class NewCustomEventRouterMock: NewCustomEventWireframeProtocol {
    func loadTimeLine() {
        
    }
    
    
    var expectation: XCTestExpectation?
    
    func dismiss() {
        
    }
    
    func loadTimeLineEventDetail(_ event: TimeLineEvent) {        
        expectation?.fulfill()
    }
    
    func showAlert(error: Error) {
        
    }
}
