//
//  MockEngineInterface.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreFoundationLib

final class MockEngineInterface: EngineInterface {
    func isValid(expression: Any) -> Bool {
        return false
    }
    
    func resetEngine() {}
    
    func addRule(identifier: String, value: Any) {}
    
    func addRules(rules: [String : Any]) {}
}
