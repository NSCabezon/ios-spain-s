//
//  MetricsRepository.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 16/9/21.
//

import Foundation

public protocol MetricsRepository {
    func setUser(personCode: String, personType: String)
    func deleteUser()
    func trackScreen(screenId: String, extraParameters: [String: String], language: String)
    func trackEvent(screenId: String, eventId: String, extraParameters: [String: String], language: String)
}

public protocol TealiumRepository: MetricsRepository {
    func setSegment(comercial: String?, bdp: String?)
}

public protocol NetInsightRepository: MetricsRepository {
    var baseUrl: String? { get set }
}
