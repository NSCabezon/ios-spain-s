//
//  CardTransactionsSearchPresenter.swift
//  Cards
//
//  Created by Tania Castellano Brasero on 13/02/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol CardTransactionsSearchPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: CardTransactionsSearchViewProtocol? {get set}
    func viewDidLoad()
    func didSelectDismiss()
    func applyFilters()
    func getLanguage() -> String
}

final class CardTransactionsSearchPresenter {
    weak var view: CardTransactionsSearchViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var filters: TransactionFiltersEntity = TransactionFiltersEntity()
    private let localAppConfig: LocalAppConfig
    
    private var delegate: CardTransactionsSearchDelegate? {
        return dependenciesResolver.resolve(for: CardTransactionsSearchDelegate.self)
    }
    
    private weak var homeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    private var cardTransactionsSearchCoordinator: CardTransactionsSearchCoordinator {
        self.dependenciesResolver.resolve(for: CardTransactionsSearchCoordinator.self)
    }
    
    private lazy var cardTransactionsSearchModifier: CardTransactionsSearchModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: CardTransactionsSearchModifierProtocol.self)
    }()
    
    private var isSearchLimitedBySCA: Bool {
        guard let isSearchLimitedBySCA = cardTransactionsSearchModifier?.isSearchLimitedBySCA else {
            return true
        }
        return isSearchLimitedBySCA
    }
    
    private var isTransactionNameFilterEnabled: Bool {
        guard let isTransactionNameFilterEnabled = cardTransactionsSearchModifier?.isTransactionNameFilterEnabled else {
            return false
        }
        return isTransactionNameFilterEnabled
    }
    
    private var isIncomeExpensesFilterEnabled: Bool {
        guard let isIncomeExpensesFilterEnabled = cardTransactionsSearchModifier?.isIncomeExpensesFilterEnabled else {
            return false
        }
        return isIncomeExpensesFilterEnabled
    }
    
    private var isAmountsRangeFilterEnabled: Bool {
        guard let isAmountsRangeFilterEnabled = cardTransactionsSearchModifier?.isAmountsRangeFilterEnabled else {
            return false
        }
        return isAmountsRangeFilterEnabled
    }
    
    private var isOperationTypeFilterEnabled: Bool {
        guard let isOperationTypeFilterEnabled = cardTransactionsSearchModifier?.isOperationTypeFilterEnabled else {
            return false
        }
        return isOperationTypeFilterEnabled
    }
    
    // MARK: - Public
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
                
    func didSelectDismiss() {
        self.cardTransactionsSearchCoordinator.dismiss()
    }
}

// MARK: - Private

private extension CardTransactionsSearchPresenter {
    func showMadridAlert(view: UIViewController, conceptText: String) {
        let conceptFilterAction: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.filters.removeAllFilters()
            strongSelf.filters.addDescriptionFilter(conceptText)
            strongSelf.cardTransactionsSearchCoordinator.dismiss()
            guard let trackId = strongSelf.delegate?.didApplyFilter(strongSelf.filters, CriteriaFilter.byTerm) else {
                return
            }
            strongSelf.trackEvent(.apply, parameters: [.cardType: trackId, .searchType: conceptText])
            
        }
        let othersFilterAction: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.applyByCharacteristics(othersFiltersActive: true)
        }
        self.homeCoordinatorDelegate?.showDialog(acceptTitle: localized("search_alertButton_applyFilters"), cancelTitle: localized("search_alertButton_searchName"), title: localized("search_alertTitle_filter"), body: localized("search_alertText_filter"), showsCloseButton: true, source: view, acceptAction: othersFilterAction, cancelAction: conceptFilterAction)
    }
    
    func applyByCharacteristics(othersFiltersActive: Bool) {
        // Concept filter
        if isTransactionNameFilterEnabled {
            if !othersFiltersActive, let conceptText = self.view?.getTextConcept(), !conceptText.isEmpty {
                self.filters.addDescriptionFilter(conceptText)
            }
        }
        // Dates filter (default)
        if let startEndDates = self.view?.getStartEndDates() {
            filters.addDateFilter(startEndDates.startDate, toDate: startEndDates.endDate)
        }
        filters.addDateRangeGroupIndex(self.view?.getDateRangeSegmentIndex() ?? -1)
        // Expenses filter
        if isIncomeExpensesFilterEnabled {
            if let indexMovementType = self.view?.getIndexMovementType(), let accountTransactionTypeFilter = TransactionConceptType(rawValue: indexMovementType) {
                if accountTransactionTypeFilter != .all {
                    self.filters.addMovementFilter(accountTransactionTypeFilter)
                }
            }
        }
        // Operation type filter
        if isOperationTypeFilterEnabled {
            if let indexOperationType = self.view?.getIndexOperationType(), let cardOperationType = CardOperationType(rawValue: indexOperationType) {
                trackEvent(.apply, parameters: [.searchType: CardFilterOperationType.operationType.rawValue, .operationType: cardOperationType.trackName])
                if cardOperationType != .all {
                    self.filters.addCardOperationFilter(cardOperationType)
                }
            }
        }
        // Amounts range filter
        if isAmountsRangeFilterEnabled {
            guard let fromAmount = self.view?.getFromAmount(),
                let toAmount = self.view?.getToAmount(),
                let view = (self.view as? UIViewController)?.navigationController?.visibleViewController
            else {
                self.addAmountFilter(filters: self.filters, self.view?.getFromToRange().from, toAmount: self.view?.getFromToRange().to)
                self.goToCharacteristics()
                return
            }
            // if range amount is not valid, show dialog
            let isRangeAmountValid = self.validateAmount(fromAmount: fromAmount, toAmount: toAmount)
            if !fromAmount.isEmpty && !toAmount.isEmpty, !isRangeAmountValid {
                self.homeCoordinatorDelegate?.showDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: localized("generic_alert_title_errorData"), body: localized("search_alert_amountLimit"), showsCloseButton: false, source: view, acceptAction: nil, cancelAction: nil)
            } else {
                self.addAmountFilter(filters: self.filters, self.view?.getFromToRange().from, toAmount: self.view?.getFromToRange().to)
                self.goToCharacteristics()
            }
        } else {
            self.goToCharacteristics()
        }
    }
    
    func isOverSCALimit() -> Bool {
        guard let startEndDates = view?.getStartEndDates() else {
            return false
        }
        let numberOfDays: Int = Date().days(from: startEndDates.startDate) ?? 0
        return numberOfDays >= 90
    }
    
    func goToCharacteristics() {
        self.cardTransactionsSearchCoordinator.dismiss()
        if isTransactionNameFilterEnabled {
            let concept = self.filters.getTransactionDescription()
            let typeSearch = (concept != nil && concept?.isEmpty != false) ? CriteriaFilter.byCharacteristics : CriteriaFilter.byTerm
            self.delegate?.didApplyFilter(self.filters, typeSearch)
        } else {
            self.delegate?.didApplyFilter(self.filters, .none)
        }
    }
    
    @discardableResult private func addAmountFilter(filters: TransactionFiltersEntity, _ fromAmount: Decimal?, toAmount: Decimal?) -> TransactionFiltersEntity {
        filters.fromAmount = fromAmount
        filters.toAmount = toAmount
        if filters.fromAmount == nil && filters.toAmount == nil {
            return filters
        }
        var fromAmountString: String?
        var toAmountString: String?
        if let famount = filters.fromAmount, let fromAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: famount)) {
            fromAmountString = fromAmountStr
        }
        if let tamount = filters.toAmount, let toAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: tamount)) {
            toAmountString = toAmountStr
        }
        filters.filters.append(.byAmount(from: fromAmountString, limit: toAmountString))
        return filters
    }
    
    private func validateAmount(fromAmount: String, toAmount: String) -> Bool {
        guard let fdecimal = self.view?.getFromToRange().from else {
            return false
        }
        
        guard let tdecimal = self.view?.getFromToRange().to else {
                   return false
        }
        return fdecimal <= tdecimal
    }
    
}

// MARK: - PresenterProtocol

extension CardTransactionsSearchPresenter: CardTransactionsSearchPresenterProtocol {
    func getLanguage() -> String {
        return dependenciesResolver.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.rawValue ?? "en"
    }
    
    func viewDidLoad() {
        self.trackScreen()
        let filters = self.delegate?.getFilters()
        if let dateRange = filters?.getDateRange() {
            self.view?.addDateFilter(startDateSelected: dateRange.fromDate, endDateSelected: dateRange.toDate)
        }
        self.view?.setDateRangeSegmentIndex(filters?.getSelectedDateRangeGroupIndex() ?? 2)
        
        // Concept filter
        if isTransactionNameFilterEnabled {
            self.view?.addConcept(title: localized("search_label_movementName"), textFieldTitle: localized("search_hint_textConcept"), textSelected: filters?.getTransactionDescription())
        }
        
        // Expenses filter
        if isIncomeExpensesFilterEnabled {
            let allExpensesValues: [String] = TransactionConceptType.allCases.map { $0.descriptionKey }
            self.view?.addSegmentedControl(title: localized("search_label_expenseIncome"), types: allExpensesValues, itemSelected: filters?.getMovementType().rawValue ?? 0)
        }
        
        // Amounts range filter
        if isAmountsRangeFilterEnabled {
            let isColapsed = filters?.fromAmountDecimal != nil || filters?.toAmountDecimal != nil
            let fromAmount = AmountEntity(value: filters?.fromAmountDecimal ?? Decimal())
            let toAmount = AmountEntity(value: filters?.toAmountDecimal ?? Decimal())
            self.view?.setRangeAmountFilter(fromAmount: fromAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                            toAmount: toAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                            isColapsed: isColapsed)
        }
        
        // Operation type filter
        if isOperationTypeFilterEnabled {
            let allOperationTypeValues: [String] = CardOperationType.allCases.map {
                localized($0.descriptionKey)
            }
            let itemSelected = filters?.getCardOperationType().rawValue
            self.view?.addOperationTypeFilter(title: localized("search_label_operation"), types: allOperationTypeValues, itemSelected: itemSelected ?? 0, isColapsed: false)
        }
    }
    
    func applyFilters() {
        if isSearchLimitedBySCA {
            if let conceptText = self.view?.getTextConcept(), !conceptText.isEmpty, isOverSCALimit(), let view = (self.view as? UIViewController)?.navigationController?.visibleViewController {
                self.showMadridAlert(view: view, conceptText: conceptText)
            } else {
                self.applyByCharacteristics(othersFiltersActive: false)
            }
        } else {
            self.applyByCharacteristics(othersFiltersActive: false)
        }
    }
}

extension CardTransactionsSearchPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: CardsSearchPage {
        return CardsSearchPage()
    }
}
