//
//  NewCustomEventPresenterMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 12/09/2019.
//

import Foundation
import SantanderUIKitLib
@testable import FinantialTimeline

class NewCustomEventPresenterMock: NewCustomEventPresenterProtocol {
    func viewDidLoad() {
        
    }
    
    
    var frequencyIsOK = false
    
    func onBackPressed() {
        
    }
    
    func createCustomEventTapped(_ newEvent: NewCustomEventViewControllerOutput) {
        
    }
    
    func setFrequencyIsOK(_ newCustomEvent: NewCustomEventViewControllerOutput) {
        
    }
    
    func requerimentsAreOK(_ newCustomEvent: NewCustomEventViewControllerOutput) -> Bool {
        
        return false
    }
    
}
