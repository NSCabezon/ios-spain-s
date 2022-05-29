//
//  SiriIntentsManagerProtocol.swift
//  UI
//
//  Created by Juan Carlos López Robles on 12/14/20.
//

import Foundation

public protocol SiriIntentsPresentationDelegate: class {
    var letPerformIntent: Bool { get }
    func intentDidPerform()
}

public protocol SiriIntentsManagerProtocol {
    func setDelegate(_ delegate: SiriIntentsPresentationDelegate)
}
