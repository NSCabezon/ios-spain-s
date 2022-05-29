//
//  BillRequest.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/19/20.
//

import Foundation

final class BillRequest {
    private var isFeching: Bool = false
    private var allowMoreRequest: Bool = true
    
    func addRequest() {
        self.isFeching = true
    }
    
    func removeRequest() {
        self.isFeching = false
    }
    
    func isNotWaitingForResponse() -> Bool {
        return !self.isFeching
    }
    
    func allowMoreRequests() -> Bool {
        return self.allowMoreRequest
    }
    
    func setAllowMoreRequest(_ allow: Bool) {
        self.allowMoreRequest = allow
    }
}
