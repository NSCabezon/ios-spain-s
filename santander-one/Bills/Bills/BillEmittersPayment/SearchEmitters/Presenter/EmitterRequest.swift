//
//  EmitterRequest.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/18/20.
//

import Foundation
import CoreFoundationLib

final class EmitterRequest {
    private var isFeching: Bool = false
    private var allowMoreRequest: Bool = true
    private var emitterCode: String = ""
    var pagination: PaginationEntity?
    
    func setCode(_ emitterCode: String) {
        self.emitterCode = emitterCode
    }
    
    func getCode() -> String {
        return self.emitterCode
    }
    
    func addPagination(_ pagination: PaginationEntity?) {
        self.pagination = pagination
    }
    
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
