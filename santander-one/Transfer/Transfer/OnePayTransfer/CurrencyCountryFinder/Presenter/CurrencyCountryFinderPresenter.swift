//
//  CurrencyCountryFinderPresenter.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 25/05/2020.
//

import Foundation
import CoreFoundationLib

public enum SepaSearchOperation {
    case currency
    case countries
}

public protocol CurrencyCountryFinderPresenterProtocol: AnyObject {
    var operationType: SepaSearchOperation {get}
    func didSelectDismiss()
    func viewDidLoad()
    func prepareItemsForOperation(_ operation: SepaSearchOperation)
    func searchFor(_ text: String)
    func resetSearch()
}

class CurrencyCountryFinderPresenter {
    weak var view: CurrencyCountryFinderViewControllerProtocol?
    private var sepaInfoList: SepaInfoListEntity
    private var itemSelected: CountryCurrencyItemConformable
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    var operationType: SepaSearchOperation
 
    init(operation: SepaSearchOperation, sepaInfoList: SepaInfoListEntity, itemSelected: CountryCurrencyItemConformable, pullOfferCandidates: [PullOfferLocation: OfferEntity]) {
        self.operationType = operation
        self.sepaInfoList = sepaInfoList
        self.itemSelected = itemSelected
        self.pullOfferCandidates = pullOfferCandidates
    }
}

private extension CurrencyCountryFinderPresenter {
    func showLocation() {
        guard
            self.pullOfferCandidates?.contains(location: TransferPullOffers.fxPayCurrencyCountry) == true,
            self.operationType == .countries,
            let location = self.pullOfferCandidates?.first(where: { $0.key.stringTag == TransferPullOffers.fxPayCurrencyCountry }),
            let banner = location.value.banner
        else {
            return
        }
        self.view?.setOfferBannerWithUrl(banner.url, offerId: location.value.id)
    }
}

extension CurrencyCountryFinderPresenter: CurrencyCountryFinderPresenterProtocol {    
    func resetSearch() {
        let viewModel = CountryCurrencyViewModel(entity: self.sepaInfoList, operation: self.operationType, itemSelected: self.itemSelected)
        self.view?.didUpdateViewModel(viewModel)
    }
    
    func searchFor(_ text: String) {
        var result: SepaInfoListEntity?
        if self.operationType == .currency {
            let filteredCurrencies = self.sepaInfoList.allCurrencies
                .filter({$0.isIncludedFilteredBy(text.lowercased())})
            result = SepaInfoListEntity(allCurrencies: filteredCurrencies, allCountries: [])
        } else if self.operationType == .countries {
            let filteredCountries = self.sepaInfoList.allCountries
                .filter({$0.isIncludedFilteredBy(text.lowercased())})
            result = SepaInfoListEntity(allCurrencies: self.sepaInfoList.allCurrencies, allCountries: filteredCountries)
        }
        guard let searchResult = result else {
            return
        }
        let viewModel = CountryCurrencyViewModel(entity: searchResult, operation: self.operationType, itemSelected: self.itemSelected)
        self.view?.didUpdateViewModel(viewModel)
    }
    
    func prepareItemsForOperation(_ operation: SepaSearchOperation) {
        let viewModel = CountryCurrencyViewModel(entity: self.sepaInfoList, operation: operation, itemSelected: self.itemSelected)
        self.view?.didUpdateViewModel(viewModel)
    }
    
    func didSelectDismiss() {}
    
    func viewDidLoad() {
        prepareItemsForOperation(self.operationType)
        showLocation()
    }
}
