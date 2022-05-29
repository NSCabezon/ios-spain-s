//
//  GetAllTransfersModifier.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 19/4/21.
//

import CoreFoundationLib
import CoreDomain
import Foundation
import Transfer

struct GetAllTransfersModifier: GetAllTransfersUseCaseModifierProtocol {
    func filterBizumTransfers<Transfer: TransferEntityProtocol>(_ transfers: [AccountEntity: [Transfer]]) -> [AccountEntity: [Transfer]] {
        let filtered = transfers.map {($0.key, $0.value.filter { self.filterBizumConcept(for: $0.concept) })}
        return Dictionary(uniqueKeysWithValues: filtered)
    }
    
    func filterBizumTransfers(_ transfers: [TransferRepresentable]) -> [TransferRepresentable] {
        return transfers.filter { self.filterBizumConcept(for: $0.transferConcept) }
    }
}

private extension GetAllTransfersModifier {
    func filterBizumConcept(for concept: String?) -> Bool {
        guard let concept = concept else { return true }
        return concept.lowercased().hasPrefix("bizum") == false
    }
}
