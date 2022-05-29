//
//  TimeLineDetailViewMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 23/07/2019.
//

import Foundation
import SantanderUIKitLib
@testable import FinantialTimeline

class TimeLineDetailViewMock: TimeLineDetailViewProtocol {
    func blockCTAButtons() {
        
    }
    
    func unblockCTAButtons() {
        
    }
    
    func showDeleteEventAlert() {
        
    }
    
    func showAmount(_ amount: Amount?, issueDate: Date, calculation: String?) {
        spyShowAmountCalled = amount != nil
    }
    
    func configViewForPeriodicEvent(event: PeriodicEvent) {
        
    }
    
    func showCTAsForPeriodicEvent(ctaEngine: CTAEngine) {
        
    }
    
    var presenter: TimeLineDetailPresenterProtocol?
    var spyShowEventProductCalled = false
    var spyShowEventLogoCalled = false
    var spyShowEventNameCalled = false
    var spyShowDescriptionCalled = false
    var spyShowAmountCalled = false
    var spyShowActivityCalled: Bool?
    var spyShowDate = false
    var spyShowIssueDate = false
    var spyShowDeferredDetails = false
    var spyShowDeferredDetailsSchedule = false
    var spyShowCTAs = false
    
    func showEventLogo(_ logo: String?, type: TimeLineEvent.TransactionType) {
        spyShowEventLogoCalled = true
    }
    
    func showEventName(_ name: String) {
        spyShowEventNameCalled = true
    }
    
    func showDescription(_ description: String) {
        spyShowDescriptionCalled = true
    }
    
    func showActivity(_ activity: [TimeLineEvent.Activity], event: TimeLineEvent, hasGroupedMonths: Bool) {
        spyShowActivityCalled = true
    }
    
    func showEventDate(_ date: Date) {
        spyShowDate = true
    }
    
    func showIssueDate(_ date: Date) {
        spyShowIssueDate = true
    }
    
    func hideActivityLoadingIndicator() { }
    
    func showProduct(_ product: String, type: String?) {
        spyShowEventProductCalled = true
    }
    
    func showDetails(_ deferred: TimeLineEvent.DeferredDetails?) {
        guard let deferredDetails = deferred else {
            spyShowDeferredDetails = false
            spyShowDeferredDetailsSchedule = false
            return
        }
        spyShowDeferredDetails = true
        
        guard let _ = deferredDetails.schedulingDate else {
            spyShowDeferredDetailsSchedule = false
            return
        }
        spyShowDeferredDetailsSchedule = true
    }
    
    func showActivityLoadingIndicator() {
        
    }
    
    func activityDidFail(with error: Error) {
        spyShowActivityCalled = false
    }
    
    func showCTAs(_ CTAs: [CTAAction]?, for event: TimeLineEvent, ctaEngine: CTAEngine) {
        guard ctaEngine.getCTAs(for: event.type.rawValue) != nil else {
            spyShowCTAs = false
            return
        }
        spyShowCTAs = true
    }
    
    func showIcon(event: TimeLineEvent) {
        
    }
    
    func showHideAlertDropdown(alertType: String?) {
        
    }
    
    func showAlert(message: String, isAlertCreated: Bool) {
        
    }
    
    func showDeleteAlert() {
        
    }
}
