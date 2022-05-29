//
//  SendMoneyCurrencyHelper.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 1/2/22.
//

import CoreDomain
import UIOneComponents
import Operative
import UIKit
import CoreFoundationLib

protocol SendMoneyCurrencyHelperPresenterProtocol: AnyObject {
    var operativeData: SendMoneyOperativeData { get }
    var currenciesList: [CurrencyInfoRepresentable] { get }
    var viewCurrencyHelper: SendMoneyCurrencyHelperViewProtocol? { get }
    var maxCarouselItems: Int { get }
    var container: OperativeContainerProtocol? { get }
    var sendMoneyUseCaseProvider: SendMoneyUseCaseProviderProtocol { get }
    var dependenciesResolver: DependenciesResolver { get }
    var trackerPage: SendMoneyAmountAndDatePage { get }
    var trackerManager: TrackerManager { get }
    func setFilteredCurrenciesSelectionList(_ currencySearch: String)
    func getCarouselCurrencies() -> [CurrencyInfoRepresentable]
    func mapToSelectionListViewModel(_ currencyInfoRepresentable: CurrencyInfoRepresentable, highlightedText: String?) -> OneSmallSelectorListViewModel
    func didSearchCurrency(_ searchItem: String)
    func didSelectCurrency(_ currency: String)
    func checkTransferType()
    func getDestinationTypeInput() -> DestinationTypeSendMoneyTransferUseCaseInput?
    func shouldRebuildSteps(newTransferType: OnePayTransferType) -> Bool
}

extension SendMoneyCurrencyHelperPresenterProtocol {
    var currenciesList: [CurrencyInfoRepresentable] {
        return self.operativeData.sepaList?.allCurrenciesRepresentable ?? []
    }
    
    var maxCarouselItems: Int { 6 }
    
    func setFilteredCurrenciesSelectionList(_ currencySearch: String) {
        let formattedCurrencySearch = currencySearch.lowercased().deleteAccent()
        let filteredCurrencies = currencySearch.isEmpty ? self.currenciesList : self.currenciesList.filter { $0.name.lowercased().deleteAccent().contains(formattedCurrencySearch) || $0.code.lowercased().deleteAccent().contains(formattedCurrencySearch) }
        let sortedCurrencies: [CurrencyInfoRepresentable] = filteredCurrencies.sorted { $0.name < $1.name }
        self.viewCurrencyHelper?.setCurrencies(listItems: sortedCurrencies.map { self.mapToSelectionListViewModel($0, highlightedText: formattedCurrencySearch) }, carouselItems: self.getCarouselCurrencies().map { self.mapToSelectionListViewModel($0) })
    }
    
    func getCarouselCurrencies() -> [CurrencyInfoRepresentable] {
        var carouselCurrencies = Array(self.currenciesList.prefix(self.maxCarouselItems))
        guard let currencyCode = self.operativeData.currency?.code,
              let selectedIndex = carouselCurrencies.firstIndex(where: { $0.code == currencyCode }) else { return carouselCurrencies }
        let selectedItem = carouselCurrencies[selectedIndex]
        carouselCurrencies.remove(at: selectedIndex)
        carouselCurrencies.insert(selectedItem, at: .zero)
        return carouselCurrencies
    }
    
    func mapToSelectionListViewModel(_ currencyInfoRepresentable: CurrencyInfoRepresentable, highlightedText: String? = nil) -> OneSmallSelectorListViewModel {
        return OneSmallSelectorListViewModel(leftTextKey: currencyInfoRepresentable.name,
                                             rightAccessory: .text(textKey: currencyInfoRepresentable.code),
                                             status: self.operativeData.currency?.code == currencyInfoRepresentable.code ? .activated : .inactive,
                                             highlightedText: highlightedText,
                                             accessibilitySuffix: nil)
    }
    
    func loadCurrenciesSelectionItems() {
        let sortedCurrencies = self.currenciesList.sorted { $0.name < $1.name }
        self.viewCurrencyHelper?.loadAllCurrencies(listItems: sortedCurrencies.map { self.mapToSelectionListViewModel($0) },
                                     carouselItems: self.getCarouselCurrencies().map { self.mapToSelectionListViewModel($0) })
    }
    
    func didSearchCurrency(_ searchItem: String) {
        self.setFilteredCurrenciesSelectionList(searchItem)
    }
    
    func didSelectCurrency(_ currency: String) {
        self.trackDidChangeCurrency()
        self.viewCurrencyHelper?.closeBottomSheet()
        guard let currency = self.currenciesList.first(where: { $0.name == currency }) else {
            return
        }
        guard let currentCurrency = self.operativeData.currency,
              currency.equalsTo(other: currentCurrency)
        else {
            self.viewCurrencyHelper?.showOpaqueLoading()
            self.operativeData.currency = currency
            self.operativeData.amount = AmountRepresented(value: self.operativeData.amount?.value ?? 0, currencyRepresentable: CurrencyRepresented(currencyName: currency.code, currencyCode: currency.code))
            self.container?.save(self.operativeData)
            self.checkTransferType()
            return
        }
        self.operativeData.currency = currency
        self.container?.save(self.operativeData)
        self.viewCurrencyHelper?.closeBottomSheet()
        self.loadCurrenciesSelectionItems()
    }
    
    func checkTransferType() {
        guard let input = self.getDestinationTypeInput() else { return }
        let useCase = self.sendMoneyUseCaseProvider.getTransferTypeUseCase(input: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                let shouldRebuildSteps = self?.shouldRebuildSteps(newTransferType: output.type)
                self?.operativeData.type = output.type
                self?.container?.save(self?.operativeData)
                guard let shouldRebuildSteps = shouldRebuildSteps,
                      shouldRebuildSteps
                else {
                    self?.viewCurrencyHelper?.reloadCurrency(currencyCode: self?.operativeData.currency?.code)
                    self?.loadCurrenciesSelectionItems()
                    self?.viewCurrencyHelper?.hideOpaqueLoading()
                    return
                }
                self?.operativeData.didSwapCurrentStep = true
                self?.container?.save(self?.operativeData)
                self?.container?.rebuildSteps()
            }
            .onError { [weak self] _ in
                self?.container?.showGenericError()
            }
    }
    
    func getDestinationTypeInput() -> DestinationTypeSendMoneyTransferUseCaseInput? {
        guard let currencyInfo = self.operativeData.currency,
              let countryInfo = self.operativeData.country,
              let account = self.operativeData.selectedAccount
        else { return nil }
        return DestinationTypeSendMoneyTransferUseCaseInput(amount: self.operativeData.amount, currencyInfo: currencyInfo, countryInfo: countryInfo, account: account)
    }
    
    func shouldRebuildSteps(newTransferType: OnePayTransferType) -> Bool {
        var shouldRebuild = false
        if (self.operativeData.type == .national || self.operativeData.type == .sepa) {
            shouldRebuild = newTransferType == .noSepa
        } else if self.operativeData.type == .noSepa {
            shouldRebuild = newTransferType == .sepa || newTransferType == .national
        }
        return shouldRebuild
    }
    
    func trackDidChangeCurrency() {
        guard self.operativeData.type != .national else { return }
        self.trackerManager.trackEvent(screenId: self.trackerPage.page, eventId: SendMoneyAmountAndDatePage.Action.changeCurrency.rawValue, extraParameters: [:])
    }
}

protocol SendMoneyCurrencyHelperViewProtocol {
    var currenciesSelectionView: SelectionListView { get }
    var loadingContainerView: UIView! { get }
    var loadingImageView: UIImageView! { get }
    func setCurrencies(listItems: [OneSmallSelectorListViewModel], carouselItems: [OneSmallSelectorListViewModel])
    func loadAllCurrencies(listItems: [OneSmallSelectorListViewModel], carouselItems: [OneSmallSelectorListViewModel])
    func closeBottomSheet()
    func showOpaqueLoading()
    func hideOpaqueLoading()
    func configureLoadingView()
    func reloadCurrency(currencyCode: String?)
    var amountAndDescriptionView: SendMoneyAmountAndDescriptionViewProtocol { get }
}

extension SendMoneyCurrencyHelperViewProtocol {
    func setCurrencies(listItems: [OneSmallSelectorListViewModel],
                       carouselItems: [OneSmallSelectorListViewModel]) {
        self.currenciesSelectionView.setItems(listItems: listItems, carouselItems: carouselItems)
    }
    
    func loadAllCurrencies(listItems: [OneSmallSelectorListViewModel], carouselItems: [OneSmallSelectorListViewModel]) {
        self.currenciesSelectionView.clearInput()
        self.setCurrencies(listItems: listItems, carouselItems: carouselItems)
    }
    
    func showOpaqueLoading() {
        self.loadingContainerView.isHidden = false
    }
    
    func hideOpaqueLoading() {
        self.loadingContainerView.isHidden = true
    }
    
    func configureLoadingView() {
        self.loadingImageView.setNewJumpingLoader()
        self.loadingImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.AllFavorites.emptyLoader
        self.loadingContainerView.isHidden = true
    }
    
    func reloadCurrency(currencyCode: String?) {
        self.amountAndDescriptionView.updateCurrency(currencyCode: currencyCode)
    }
}

extension SendMoneyCurrencyHelperViewProtocol where Self: UIViewController {
    func closeBottomSheet() {
        self.presentedViewController?.dismiss(animated: true)
    }
}
