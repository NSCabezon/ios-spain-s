//
//  TransferReceivedRequestGroup.swift
//  Transfer
//
//  Created by alvola on 18/05/2020.
//

import CoreFoundationLib

final class TransferReceivedRequestGroup {
    private var requestPage: [AccountEntity: Int] = [:]
    private var result: [AccountEntity: [TransferReceivedEntity]] = [:]
    private var maxNumberOfPages: Int = 1
    private var pendingRequests: Int = -1
    private let appConfigRepository: AppConfigRepositoryProtocol
    private var response: GetReceivedTransfersUseCaseOutput?
    public  var dateFilter = DateFilterEntity.createSubtractingMonths(months: 1)
    public  var notify: (([AccountEntity: [TransferReceivedEntity]]) -> Void)?
    
    init(dependenciesResolver: DependenciesResolver, accounts: [AccountEntity]) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.pendingRequests = accounts.count
        self.setMaxNumberOfPages()
        self.setMaxMonth()
    }
    
    private func setMaxNumberOfPages() {
        if let maxPageParam = appConfigRepository
            .getString(TransferConstant.appConfigReceivedTransfersMaxPagination) {
            self.maxNumberOfPages = Int(maxPageParam) ?? 1
        }
    }
    
    private func setMaxMonth() {
        if let months = appConfigRepository
            .getString(TransferConstant.appReceivedTransfersSearchMonths) {
            self.dateFilter = DateFilterEntity.createSubtractingMonths(months: Int(months) ?? 1)
        }
    }
    
    func setRequested(for account: AccountEntity) {
        let currentPage = self.requestPage[account] ?? 0
        self.requestPage[account] = currentPage + 1
    }
    
    func addResponse(_ response: GetReceivedTransfersUseCaseOutput) {
        self.result[response.account] = (self.result[response.account] ?? []) + response.transfers
    }
    
    func leave() {
        self.decreasePendingRequest()
        if self.pendingRequests == 0 {
            self.notify?(result)
        }
    }
    
    private func decreasePendingRequest() {
        self.pendingRequests -= 1
    }
}
