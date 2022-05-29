//
//  TransferEmittedRequestGroup.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/22/19.
//

import Foundation
import CoreFoundationLib

class TransferEmittedRequestGroup {
    private var requestPage: ThreadSafeProperty<[AccountEntity: Int]> = ThreadSafeProperty([:])
    private var result: ThreadSafeProperty<[AccountEntity: [TransferEmittedEntity]]> = ThreadSafeProperty([:])
    private var maxNumberOfPages: Int = 1
    private var pendingRequests: Int = -1
    private let appConfigRepository: AppConfigRepositoryProtocol
    private var response: GetEmittedTransfersUseCaseOutput?
    public  var dateFilter = DateFilterEntity.createSubtractingMonths(months: 1)
    public  var notify: (([AccountEntity: [TransferEmittedEntity]]) -> Void)?
    
    init(dependenciesResolver: DependenciesResolver, accounts: [AccountEntity]) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.pendingRequests = accounts.count
        self.setMaxNumberOfPages()
        self.setMaxMonth()
    }
    
    private func setMaxNumberOfPages() {
        if let maxPageParam = appConfigRepository
            .getString(TransferConstant.appConfigEmittedTransfersMaxPagination) {
            self.maxNumberOfPages = Int(maxPageParam) ?? 1
        }
    }
    
    private func setMaxMonth() {
        if let months = appConfigRepository
            .getString(TransferConstant.appConfigEmittedTransfersSearchMonths) {
            self.dateFilter = DateFilterEntity.createSubtractingMonths(months: Int(months) ?? 1)
        }
    }
    
    func setRequested(for account: AccountEntity) {
        let currentPage = self.requestPage.value[account] ?? 0
        self.requestPage.value[account] = currentPage + 1
    }
    
    func addResponse(_ response: GetEmittedTransfersUseCaseOutput) {
        self.response = response
    }
    
    func leave() {
        self.decreasePendingRequest()
        guard let account = response?.account else { return }
        self.result.value[account] = response?.transfers
        if self.pendingRequests == 0 {
            self.notify?(result.value)
        }
    }
    
    private func decreasePendingRequest() {
        self.pendingRequests -= 1
    }
    
    public func isEnd() -> Bool {
        guard let account = response?.account else { return true }
        let requestPage = self.requestPage.value[account] ?? 0
        let isLastPage = response?.nextPage?.isEnd == true
        if isLastPage || requestPage > self.maxNumberOfPages {
            return true
        } else {
            return false
        }
    }
    
    public func nextPage() -> PaginationEntity? {
        return self.response?.nextPage
    }
}
