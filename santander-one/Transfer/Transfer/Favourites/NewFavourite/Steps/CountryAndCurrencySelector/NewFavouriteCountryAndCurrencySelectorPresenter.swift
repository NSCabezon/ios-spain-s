//
//  CountryAndCurrencySelectorPresenter.swift
//  Transfer
//
//  Created by Luis Escámez Sánchez on 27/5/21.
//

import Operative
import Foundation
import CoreFoundationLib
import UI

protocol NewFavouriteCountryAndCurrencySelectorPresenterProtocol: OperativeStepPresenterProtocol {
    var view: NewFavouriteCountryAndCurrencySelectorViewProtocol? { get set }
    func viewWillAppear()
    func didSelectContinue()
    func updateCountryAndCurrency(_ country: SepaCountryInfoEntity, _ currency: SepaCurrencyInfoEntity)
}

final class NewFavouriteCountryAndCurrencySelectorPresenter {
    weak var view: NewFavouriteCountryAndCurrencySelectorViewProtocol?
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var fields: [ValidatableField] = []
    private let dependenciesResolver: DependenciesResolver
    lazy var operativeData: NewFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NewFavouriteCountryAndCurrencySelectorPresenter: NewFavouriteCountryAndCurrencySelectorPresenterProtocol {
    
    func viewWillAppear() {
        self.setData()
    }
    
    func didSelectContinue() {
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
    }
    
    func updateCountryAndCurrency(_ country: SepaCountryInfoEntity, _ currency: SepaCurrencyInfoEntity) {
        self.operativeData.country = country
        self.operativeData.currency = currency
    }
}

private extension NewFavouriteCountryAndCurrencySelectorPresenter {
    
    func setData() {
        guard let sepaList = operativeData.sepaList,
              let country = operativeData.country,
              let currency = operativeData.currency else { return }
        self.view?.setCountryAndCurrencyInfo(sepaList, countrySelected: country, currencySelected: currency)
    }
}
