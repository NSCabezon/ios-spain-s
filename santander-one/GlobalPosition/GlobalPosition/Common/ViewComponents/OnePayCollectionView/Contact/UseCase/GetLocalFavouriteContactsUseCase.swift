//
//  GetLocalFavouriteContactsUseCase.swift
//  GlobalPosition
//
//  Created by Tania Castellano Brasero on 22/10/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetLocalFavouriteContactsUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let favouriteTransfersManager = self.provider.getBsanFavouriteTransfersManager()
        let responseLocalUsualTransfer = try favouriteTransfersManager.getLocalFavourites()
        guard
            responseLocalUsualTransfer.isSuccess(),
            let dataUsualTransfer = try responseLocalUsualTransfer.getResponseData(),
            !dataUsualTransfer.isEmpty else {
            return .error(StringErrorOutput(nil))
        }
        return .ok()
    }
}

private extension GetLocalFavouriteContactsUseCase {
    var provider: BSANManagersProvider {
         return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
}
