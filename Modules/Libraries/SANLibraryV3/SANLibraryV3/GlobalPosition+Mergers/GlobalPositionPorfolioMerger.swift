//
//  UpdateGlobalPositionPorfolio.swift
//  SANLibraryV3
//
//  Created by Juan Carlos López Robles on 3/30/22.
//

import Foundation
import SANLegacyLibrary

struct GlobalPositionPorfolioMerger {
    private let bsanDataProvider: BSANDataProvider
    private let globalPosition: GlobalPositionDTO
    private let portfolioInfo: PortfolioInfo
    
    init(bsanDataProvider: BSANDataProvider) throws {
        self.bsanDataProvider = bsanDataProvider
        self.globalPosition = try bsanDataProvider.get(\.globalPositionDTO)
        self.portfolioInfo = try bsanDataProvider.get(\.portfolioInfo)
        updateGlobalPositionWithCardInfo()
    }
    
    private func updateGlobalPositionWithCardInfo() {
        let isPB = try? bsanDataProvider.isPB()
        var globalPositionWithUpdate = self.globalPosition
        globalPositionWithUpdate.notManagedPortfolios = portfolioInfo.portfolioNotManagedList
        globalPositionWithUpdate.managedPortfolios = portfolioInfo.portfolioManagedList
        globalPositionWithUpdate.notManagedRVStockAccounts = portfolioInfo.getRVNotManagedStockAccountList()
        globalPositionWithUpdate.managedRVStockAccounts = portfolioInfo.getRVManagedStockAccountList()
        bsanDataProvider.updateSessionData(globalPositionWithUpdate, isPB ?? false)
    }
}
