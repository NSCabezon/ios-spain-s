//
//  RemoveSavedPendingSolicitudes.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/23/20.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class RemoveSavedPendingSolicitudesUseCase: UseCase<Void, Void, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        self.provider.getBsanPendingSolicitudesManager().removePendingSolicitudes()
        return .ok()
    }
}
