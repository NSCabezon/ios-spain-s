//
//  TrusteerRepository.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 04/11/2020.
//

import Foundation

public protocol TrusteerRepositoryProtocol {
    var appSessionId: String? { get }
    func notifyLoginFlow(appSessionId: String, appPUID: String)
    func destroySession()
    func initialize()
}
