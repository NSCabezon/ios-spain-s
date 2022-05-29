//
//  AllTransfersRetrieverProtocol.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 15/11/21.
//

import CoreFoundationLib
import Transfer
import SANLegacyLibrary

protocol AllTransfersRetrieverProtocol: AnyObject {
    var dependencies: DependenciesResolver { get }
    var receivedTransferUseCaseGroup: GetReceivedTransfersUseCaseGroup<AllTransfersRetriever> { get }
    var emittedTransferUseCaseGroup: GetEmittedTransferUseCaseGroup<AllTransfersRetriever> { get }
    var emittedTransfers: EmittedResult? { get set }
    var receivedTransfers: ReceivedResult? { get set }
    func retrieveAllTransfers(requestValues: GetAllTransfersUseCaseInput) -> (emitted: EmittedResult, received: ReceivedResult)
    func evaluateIsOver()
    func markAsCompleted()
}

extension AllTransfersRetrieverProtocol {
    var receivedTransferUseCaseGroup: GetReceivedTransfersUseCaseGroup<AllTransfersRetriever> {
        return self.dependencies.resolve(for: GetReceivedTransfersUseCaseGroup.self)
    }
    
    var emittedTransferUseCaseGroup: GetEmittedTransferUseCaseGroup<AllTransfersRetriever> {
        return self.dependencies.resolve(for: GetEmittedTransferUseCaseGroup.self)
    }
    
    func retrieveAllTransfers(requestValues: GetAllTransfersUseCaseInput) -> (emitted: EmittedResult, received: ReceivedResult) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        emittedTransferUseCaseGroup.execute(requestValue: GetEmittedTransferUseCaseGroupInput(accounts: requestValues.accounts)) { [weak self] in
            self?.emittedTransfers = $0
            self?.evaluateIsOver()
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        receivedTransferUseCaseGroup.execute(requestValue: GetEmittedTransferUseCaseGroupInput(accounts: requestValues.accounts)) { [weak self] in
            self?.receivedTransfers = $0
            self?.evaluateIsOver()
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return (emittedTransfers!, receivedTransfers!)
    }
    
    func evaluateIsOver() {
        guard let emitted = emittedTransfers, let received = receivedTransfers else { return }
        markAsCompleted()
        if let getAllTransfersUseCaseModifier: GetAllTransfersUseCaseModifierProtocol = self.dependencies.resolve(forOptionalType: GetAllTransfersUseCaseModifierProtocol.self) {
            emittedTransfers = getAllTransfersUseCaseModifier.filterBizumTransfers(emitted)
            receivedTransfers = getAllTransfersUseCaseModifier.filterBizumTransfers(received)
        }
    }
    
    func markAsCompleted() {
        let bsanProvider = dependencies.resolve(for: BSANManagersProvider.self)
        try? bsanProvider.getBsanTransfersManager().storeGetHistoricalTransferCompleted(true)
    }
}

class AllTransfersRetriever: SuperUseCaseDelegate {
    func onSuccess() { }
    func onError(error: String?) { }
}
