//
//  OnePayPGViewModel.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 05/10/2020.
//

import CoreFoundationLib
import Foundation
import CoreDomain

final class OnePayPGViewModel {
    private let favorites: [PayeeRepresentable]
    private let baseUrl: String?
    private let colorsEngine: ColorsByNameEngine
    private let maxElements = 25
    
    init(_ favorites: [PayeeRepresentable], baseUrl: String?, colorsEngine: ColorsByNameEngine) {
        self.favorites = favorites
        self.baseUrl = baseUrl
        self.colorsEngine = colorsEngine
    }
    
    func loadDataInFavouriteCarousel(_ contactEntityList: [PayeeRepresentable]) -> [OnePayCollectionInfo] {
        var favouriteContactsList: [OnePayCollectionInfo] = self.getFavouriteContacts(contactEntityList)
        let keep25results: [OnePayCollectionInfo] = Array(favouriteContactsList.prefix(self.maxElements))
        favouriteContactsList = keep25results
        let onePaySearchableItem = OnePayCollectionInfo(cellClass: "NewShippmentCollectionViewCell", info: nil)
        favouriteContactsList.insert(onePaySearchableItem, at: 0)
        let newHistoricItem = OnePayCollectionInfo(cellClass: "HistoricSendMoneyCell", info: nil)
        favouriteContactsList.append(newHistoricItem)
        let newContactItem = OnePayCollectionInfo(cellClass: "NewFavContactCollectionViewCell", info: nil)
        favouriteContactsList.append(newContactItem)
        return favouriteContactsList
    }
}

private extension OnePayPGViewModel {
    func getFavouriteContacts(_ favoriteList: [PayeeRepresentable]) -> [OnePayCollectionInfo] {
        guard !favoriteList.isEmpty else {
            return []
        }
        let favouriteContactsList: [OnePayCollectionInfo] = favoriteList.map { favorite in
            let name = favorite.payeeDisplayName
            let colorType = self.colorsEngine.get(name ?? "")
            let colorsByNameViewModel = ColorsByNameViewModel(colorType)
            let favContactViewModel = FavouriteContact(
                contact: favorite,
                baseUrl: self.baseUrl,
                colorsByNameViewModel: colorsByNameViewModel
            )
            return OnePayCollectionInfo(cellClass: "FavouriteContactCell", info: favContactViewModel)
        }
        return favouriteContactsList
    }
}

struct OnePayPGConfiguration {
    static let loadingPills = [OnePayCollectionInfo(cellClass: "NewShippmentCollectionViewCell", info: nil),
                               OnePayCollectionInfo(cellClass: "FutureLoadingCollectionViewCell", info: nil)]
    static let defaultPills = [OnePayCollectionInfo(cellClass: "NewShippmentCollectionViewCell", info: nil),
                               OnePayCollectionInfo(cellClass: "HistoricSendMoneyCell", info: nil),
                               OnePayCollectionInfo(cellClass: "NewFavContactCollectionViewCell", info: nil)]
}
