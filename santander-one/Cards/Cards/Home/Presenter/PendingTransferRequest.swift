//
//  PendingTransferRequest.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 7/30/20.
//

import Foundation
import CoreFoundationLib

final class PendingTransferRequest {
    private var activeRequest = false
    private var pagination: PaginationEntity?
    
    func isNotWaitingForResponse() -> Bool {
        return !activeRequest
    }
    
    func allowMoreRequest() -> Bool {
        return pagination?.isEnd == false
    }
    
    func addRequest() {
        self.activeRequest = true
    }
    
    func removeRequest() {
        self.activeRequest = false
    }
    
    func addPagination(_ pagination: PaginationEntity?) {
        self.pagination = pagination
    }
    
    func nextPage() -> PaginationEntity? {
        return self.pagination
    }
}
