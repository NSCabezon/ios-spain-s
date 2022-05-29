//
//  AnalyticsRepositoryMock.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 20/9/21.
//

import Foundation
import CoreFoundationLib

public struct AnalyticsRepositoryMock: TealiumRepository, NetInsightRepository, MetricsRepository {
    
    public var baseUrl: String?
    
    public init() {
        
    }
    
    public func setSegment(comercial: String?, bdp: String?) {
        
    }
    
    public func setUser(personCode: String, personType: String) {
        
    }
    
    public func deleteUser() {
        
    }
    
    public func trackScreen(screenId: String, extraParameters: [String : String], language: String) {
        
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String : String], language: String) {
        
    }
}
