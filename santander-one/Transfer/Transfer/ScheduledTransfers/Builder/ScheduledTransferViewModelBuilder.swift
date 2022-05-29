//
//  ScheduledTransferViewModelBuilder.swift
//  UI
//
//  Created by Juan Carlos López Robles on 2/12/20.
//

import Foundation
import CoreFoundationLib

final class ScheduledTransferViewModelBuilder {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func scheduledTransferViewModels(for scheduledTransfers: [AccountEntity: [ScheduledTransferEntity]]) -> [ScheduledTransferViewModel] {
        var scheduledTransferViewModels: [ScheduledTransferViewModel] = scheduledTransfers.reduce([]) { (result, next) in
             let account = next.key
             let viewModels = next.value.map { transfer in
                 return ScheduledTransferViewModel(
                     transfer,
                     account: account,
                     dependenciesResolver: self.dependenciesResolver)
             }
             return result + viewModels
         }
         
         scheduledTransferViewModels =
             scheduledTransferViewModels.sorted { (lhs, rhs) -> Bool in
                 lhs.dateStartValidity < rhs.dateStartValidity
         }
        
        return scheduledTransferViewModels
    }
    
    func periodicTransferViewModels(for scheduledTransfers: [AccountEntity: [ScheduledTransferEntity]]) -> [PeriodicTransferViewModel] {
        var periodicTranferViewModel: [PeriodicTransferViewModel] = scheduledTransfers.reduce([]) { (result, next) in
              let account = next.key
              let viewModels = next.value.map { transfer in
                  return PeriodicTransferViewModel(
                      transfer,
                      account: account,
                      dependenciesResolver: self.dependenciesResolver)
              }
              return result + viewModels
          }
          
          periodicTranferViewModel =
              periodicTranferViewModel.sorted { (lhs, rhs) -> Bool in
                  lhs.dateStartValidity < rhs.dateStartValidity
          }
          return periodicTranferViewModel
    }
}
