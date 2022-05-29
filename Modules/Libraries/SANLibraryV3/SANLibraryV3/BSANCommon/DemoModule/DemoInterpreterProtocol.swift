//
//  DemoInterpreterProtocol.swift
//  DomainCommon
//
//  Created by Juan Carlos López Robles on 11/16/20.
//

public protocol DemoInterpreterProtocol {
    func isDemoUser(userName: String) -> Bool
    func getDemoUser() -> String?
    func getDefaultDemoUser() -> String
    func getAnswerNumber(serviceName: String) -> Int
}
