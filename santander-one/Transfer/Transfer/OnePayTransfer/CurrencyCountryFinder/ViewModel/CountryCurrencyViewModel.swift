//
//  CountryCurrencyViewModel.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 25/05/2020.
//

import Foundation
import CoreFoundationLib

public struct CurrencyItemViewModel: CountryCurrencyItemConformable {
   public var name: String
   public var code: String
}

public struct CountryItemViewModel: CountryCurrencyItemConformable {
   public var name: String
   public var code: String
}

public class CountryCurrencyViewModel {
    private let entity: SepaInfoListEntity
    private let operation: SepaSearchOperation
    private var itemSelected: CountryCurrencyItemConformable
    private lazy var sortedCurrencies: [SepaCurrencyInfoEntity] = {
        return entity.allCurrencies.sorted(by: {$0.name < $1.name})
    }()
    private lazy var sortedCountries: [SepaCountryInfoEntity] = {
        return entity.allCountries.sorted(by: {$0.name < $1.name})
    }()
    public var selectedItemCode: String {
        itemSelected.code
    }
    public var numberOfItems: Int {
        switch operation {
        case .countries:
            return entity.allCountries.count
        case .currency:
            return entity.allCurrencies.count
        }
    }
    
    public var dataType: SepaSearchOperation {
        return operation
    }
    
    init(entity: SepaInfoListEntity, operation: SepaSearchOperation, itemSelected: CountryCurrencyItemConformable) {
        self.entity = entity
        self.operation = operation
        self.itemSelected = itemSelected
    }
    
    public func currencyItemAtIndex(_ index: Int) -> SepaCurrencyInfoEntity? {
        return sortedCurrencies[index]
    }
    
    public func countryItemAtIndex(_ index: Int) -> SepaCountryInfoEntity? {
        return sortedCountries[index]
    }
    
    public func currencyModelItemAtIndex(_ index: Int) -> CurrencyItemViewModel? {
        let currency = sortedCurrencies[index]
        return CurrencyItemViewModel(name: currency.name, code: currency.code)
    }
    
    public func countryModelItemAtIndex(_ index: Int) -> CountryItemViewModel? {
        let country = sortedCountries[index]
        return CountryItemViewModel(name: country.name, code: country.code)
    }
           
    public func countryItemWithCode(_ code: String) -> SepaCountryInfoEntity? {
        return sortedCountries.filter({$0.code == code}).first
    }
    
    public func currencyItemWithCode(_ code: String) -> SepaCurrencyInfoEntity {
        return sortedCurrencies.filter({$0.code == code}).first ?? SepaCurrencyInfoEntity.createEuro()
    }
    
    public func getFirstSixsForOperationType(_ operation: SepaSearchOperation) -> [CountryCurrencyItemConformable] {
        guard numberOfItems > 0 else { return [CountryCurrencyItemConformable]() }
        switch operation {
        case .countries:
            return entity.allCountries.prefix(6).compactMap({SepaCountryInfoEntity($0.dto)})
        case .currency:
            return entity.allCurrencies.prefix(6).compactMap({SepaCurrencyInfoEntity($0.dto)})
        }
    }

    public func getSelectedItemIndex() -> Int {
        switch operation {
        case .countries:
            let index = self.sortedCountries.firstIndex(where: {$0.code == itemSelected.code})
            return index ?? -1
        case .currency:
            let index = self.sortedCurrencies.firstIndex(where: {$0.code == itemSelected.code})
            return index ?? -1
        }
    }
}
