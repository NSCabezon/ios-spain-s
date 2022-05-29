//
//  FavouriteContactsUseCase.swift
//  Menu
//
//  Created by Ignacio González Miró on 23/09/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class FavouriteContactsUseCase: UseCase<Void, GetFavouriteContactsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFavouriteContactsUseCaseOkOutput, StringErrorOutput> {
        let favouriteTransfersManager = self.provider.getBsanFavouriteTransfersManager()
        let response = try favouriteTransfersManager.getFavourites()
        guard response.isSuccess(), let responseFavouritesData = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let contactEntityListSorted = self.getContactsOrdered(responseFavouritesData)
        return .ok(GetFavouriteContactsUseCaseOkOutput(contactEntityList: contactEntityListSorted))
    }
}

struct GetFavouriteContactsUseCaseOkOutput {
    let contactEntityList: [PayeeRepresentable]
}

private extension FavouriteContactsUseCase {
    var provider: BSANManagersProvider {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var globalPositionWithUserPref: GlobalPositionWithUserPrefsRepresentable {
        return self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
    }
    
    func getFavoritesSorted(favorites: [PayeeRepresentable], favoriteContacts: [String]?) -> [PayeeRepresentable] {
        guard let favoriteContacts = favoriteContacts else { return favorites }
        let sortedHandler: ContactsSortedHandlerProtocol = self.dependenciesResolver.resolve(firstTypeOf: ContactsSortedHandlerProtocol.self)
        let favoriteContactsNotEmpty = favoriteContacts.filter {!$0.isEmpty}
        let sortedByAlias: [PayeeRepresentable] = sortedHandler.sortContacts(favorites)
        let sortedFavorites = favoriteContactsNotEmpty.compactMap { (contact) -> PayeeRepresentable? in
            return favorites.first { contact == $0.payeeAlias }
        }
        let restFavorites = sortedByAlias.filter { favorite in
            return !sortedFavorites.contains {
                favorite.payeeAlias == $0.payeeAlias
            }
        }
        return sortedFavorites + restFavorites
    }
    
    func getContactsOrdered(_ responseData: [PayeeDTO]) -> [PayeeRepresentable] {
        guard let userId = globalPositionWithUserPref.userId else { return responseData }
        let appRepository: AppRepositoryProtocol = dependenciesResolver.resolve()
        let userPrefEntity = appRepository.getUserPreferences(userId: userId)
        let favoriteContacts = userPrefEntity.pgUserPrefDTO.favoriteContacts
        let contactEntityListSorted = self.getFavoritesSorted(
            favorites: responseData,
            favoriteContacts: favoriteContacts
        )
        return contactEntityListSorted
    }
}
