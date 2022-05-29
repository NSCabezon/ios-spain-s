//
//  AccountTransactionsSearchPresenter.swift
//  Account
//
//  Created by Tania Castellano Brasero on 30/01/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol AccountTransactionsSearchPresenterProtocol: OtpScaAccountPresenterDelegate, MenuTextWrapperProtocol {
    var view: AccountTransactionsSearchViewProtocol? {get set}
    func viewDidLoad()
    func didSelectDismiss()
    func applyFilters()
    func getLanguage() -> String
}

final class AccountTransactionsSearchPresenter {
    weak var view: AccountTransactionsSearchViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var filters: TransactionFiltersEntity = TransactionFiltersEntity()
    private var scaState: ScaState?

    private weak var delegate: AccountTransactionsSearchDelegate? {
        return dependenciesResolver.resolve(for: AccountTransactionsSearchDelegate.self)
    }
    
    private weak var homeCoordinatorDelegate: AccountsHomeCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: AccountsHomeCoordinatorDelegate.self)
    }
    
    private var accountTransactionsSearchCoordinator: AccountTransactionsSearchCoordinator {
        self.dependenciesResolver.resolve(for: AccountTransactionsSearchCoordinator.self)
    }
    
    private var scaStateUseCase: GetScaStateUseCase {
        dependenciesResolver.resolve(for: GetScaStateUseCase.self)
    }
    
    // MARK: - Public
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
        
    func didSelectDismiss() {
        self.accountTransactionsSearchCoordinator.dismiss()
    }
    
    func loadScaState(typeStateInput: GetScaStateUseCaseInput = .normal, completion: @escaping () -> Void) {
        switch self.scaState {
        case .none, .temporaryLock?, .error?:
            break
        case .notApply?, .requestOtp?:
            completion()
            return
        }
        
        UseCaseWrapper(
            with: scaStateUseCase.setRequestValues(requestValues: typeStateInput),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] response in
                self?.scaState = response.scaState
                completion()
            },
            onError: { [weak self] _ in
                self?.scaState = nil
                completion()
            }
        )
    }
}

extension AccountTransactionsSearchPresenter: AccountTransactionsSearchPresenterProtocol {
    
    func getLanguage() -> String {
        return dependenciesResolver.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.rawValue ?? "en"
    }
    
    func otpDidFinishSuccessfully() {
        self.scaState = .notApply
        self.accountTransactionsSearchCoordinator.goToHome()
        self.delegate?.finishOTPSuccess(self.filters)
    }
    
    func viewDidLoad() {
        trackScreen()
        let filters = self.delegate?.getFilters()
        self.view?.addConcept(title: localized("search_label_movementName"), textFieldTitle: localized("search_hint_textConcept"), textSelected: filters?.getTransactionDescription())
        let allExpensesValues: [String] = TransactionConceptType.allCases.map { $0.descriptionKey }
        self.view?.addSegmentedControl(title: localized("search_label_expenseIncome"), types: allExpensesValues, itemSelected: filters?.getMovementType().rawValue ?? 0)
        self.view?.addDateFilter(startDateSelected: filters?.getDateRange()?.fromDate, endDateSelected: filters?.getDateRange()?.toDate)
        self.view?.setDateRangeSegmentIndex(filters?.getSelectedDateRangeGroupIndex() ?? 2)
        let fromAmount = AmountEntity(value: filters?.fromAmountDecimal ?? Decimal())
        let toAmount = AmountEntity(value: filters?.toAmountDecimal ?? Decimal())
        self.view?.setRangeAmountFilter(fromAmount: fromAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        toAmount: toAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        isColapsed: true)
        let allOperationTypeValues: [String] = TransactionOperationTypeEntity.allCases.map { localized($0.descriptionKey) }
        let itemSelected = filters?.getTransactionOperationType().rawValue
        self.view?.addOperationTypeFilter(title: localized("search_label_operation"), types: allOperationTypeValues, itemSelected: itemSelected ?? 0, isColapsed: true)
        if let filtersConfig = self.dependenciesResolver.resolve(forOptionalType: AccountTransactionProtocol.self) {
            self.view?.hideFiltersViewsIfNeeded(filtersConfig)
        }
    }
    
    func applyFilters() {
        let filtersAlertEnabled = dependenciesResolver.resolve(forOptionalType: FiltersAlertModifier.self)?.shouldShowFiltersAlert ?? true
        if let conceptText = self.view?.getTextConcept(),
            let view = (self.view as? UIViewController)?.navigationController?.visibleViewController,
            filtersAlertEnabled,
            shouldShowAlert(conceptText: conceptText) {
            self.showMadridAlert(view: view, conceptText: conceptText)
        } else {
            self.applyByCharacteristics(othersFiltersActive: false)
        }
    }
    
    private func showMadridAlert(view: UIViewController, conceptText: String) {
        let conceptFilterAction: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.trackEvent(.apply, parameters: [.textSearch: conceptText])
            strongSelf.filters.removeAllFilters()
            strongSelf.filters.addDescriptionFilter(conceptText)
            if !strongSelf.isOverSCALimit() {
                strongSelf.addDateFilter()
            }
            strongSelf.accountTransactionsSearchCoordinator.dismiss()
            strongSelf.delegate?.didApplyFilter(strongSelf.filters, CriteriaFilter.byTerm)
        }
        let othersFilterAction: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.applyByCharacteristics(othersFiltersActive: true)
        }
        self.homeCoordinatorDelegate?.showDialog(acceptTitle: localized("search_alertButton_applyFilters"), cancelTitle: localized("search_alertButton_searchName"), title: localized("search_alertTitle_filter"), body: localized("search_alertText_filter"), showsCloseButton: true, source: view, acceptAction: othersFilterAction, cancelAction: conceptFilterAction)
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
    
    private func applyByCharacteristics(othersFiltersActive: Bool) {
        self.filters = TransactionFiltersEntity()
        if !othersFiltersActive, let conceptText = self.view?.getTextConcept(), !conceptText.isEmpty {
            self.filters.addDescriptionFilter(conceptText)
            trackEvent(.apply, parameters: [.textSearch: conceptText])
        }
        
        if let startEndDates = self.view?.getStartEndDates() {
            self.filters.addDateFilter(startEndDates.startDate, toDate: startEndDates.endDate)
            self.filters.addDateRangeGroupIndex(self.view?.getDateRangeSegmentIndex() ?? -1)
            trackEvent(.apply, parameters: [.searchType: AccountFilterOperationType.dates.rawValue])
        }
        
        if let indexMovementType = self.view?.getIndexMovementType(), let accountTransactionTypeFilter = TransactionConceptType(rawValue: indexMovementType) {
            trackEvent(.apply, parameters: [.transactionType: accountTransactionTypeFilter.trackName])
            if accountTransactionTypeFilter != .all {
                self.filters.addMovementFilter(accountTransactionTypeFilter)
            }
        }
        
        if let indexOperationType = self.view?.getIndexOperationType(), let accountOperativeActionType = TransactionOperationTypeEntity(rawValue: indexOperationType) {
            trackEvent(.apply, parameters: [.searchType: AccountFilterOperationType.operationType.rawValue, .operationType: accountOperativeActionType.trackName])
            if accountOperativeActionType != .all {
                self.filters.addTransactionTypeFilter(accountOperativeActionType)
            }
        }
        
        guard let fromAmount = self.view?.getFromAmount(),
            let toAmount = self.view?.getToAmount(),
            let view = (self.view as? UIViewController)?.navigationController?.visibleViewController
        else {
            _ = self.addAmountFilter(filters: self.filters, self.view?.getFromToRange().from, toAmount: self.view?.getFromToRange().to)
            trackEvent(.apply, parameters: [.searchType: AccountFilterOperationType.amounts.rawValue])
            self.goToCharacteristics()
            return
        }
        
        // is range amount not valid shows dialog
        let isRangeAmountValid = self.validateAmount(fromAmount: fromAmount, toAmount: toAmount)
        
        if !fromAmount.isEmpty && !toAmount.isEmpty, !isRangeAmountValid {
            self.homeCoordinatorDelegate?.showDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: localized("generic_alert_title_errorData"), body: localized("search_alert_amountLimit"), showsCloseButton: false, source: view, acceptAction: nil, cancelAction: nil)
        } else {
            _ = self.addAmountFilter(filters: self.filters, self.view?.getFromToRange().from, toAmount: self.view?.getFromToRange().to)
            trackEvent(.apply, parameters: [.searchType: AccountFilterOperationType.amounts.rawValue])
            self.goToCharacteristics()
        }
    }
    
    private func addAmountFilter(filters: TransactionFiltersEntity, _ fromAmount: Decimal?, toAmount: Decimal?) -> TransactionFiltersEntity {
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
    
    private func goToCharacteristics() {
        self.loadScaState {
            switch self.scaState {
            case .notApply?, .none:
                self.accountTransactionsSearchCoordinator.dismiss()
                let concept = self.filters.getTransactionDescription()
                let typeSearch = concept?.isEmpty != false ? CriteriaFilter.byCharacteristics : CriteriaFilter.byTerm
                self.delegate?.didApplyFilter(self.filters, typeSearch)
            case .temporaryLock(let date)?:
                self.searchSca(date: date)
            case .requestOtp(let date)?:
                self.searchSca(date: date)
            case .error(let date)?:
                self.searchSca(date: date)
            }
        }
    }
    
    private func searchSca(date: Date) {
        if let targetDate: Date = filters.getDateRange()?.fromDate, targetDate < date {
            self.loadScaState(typeStateInput: .force, completion: { [weak self] in
                guard let strongSelf = self else { return }
                switch strongSelf.scaState {
                case .notApply?, .none:
                    break
                case .temporaryLock?:
                    if let view = (strongSelf.view as? UIViewController)?.navigationController?.visibleViewController {
                        strongSelf.homeCoordinatorDelegate?.showDialog(acceptTitle: localized("generic_button_understand"), cancelTitle: nil, title: localized("otpSCA_alert_title_blocked"), body: localized("otpSCA_alert_text_blocked"), showsCloseButton: false, source: view, acceptAction: nil, cancelAction: nil)
                    }
                case .requestOtp?:
                    if let view = (strongSelf.view as? UIViewController)?.navigationController?.visibleViewController {
                        let acceptAction: () -> Void = { [weak self] in
                            self?.getTextMessageFilteredMovements()
                        }
                        strongSelf.homeCoordinatorDelegate?.showDialog(acceptTitle: localized("generic_button_continue"), cancelTitle: localized("generic_button_cancel"), title: localized("otpSCA_alert_title_safety"), body: localized("otpSCA_alert_text_safety"), showsCloseButton: false, source: view, acceptAction: acceptAction, cancelAction: nil)
                    }
                case .error?:
                    if let view = (strongSelf.view as? UIViewController)?.navigationController?.visibleViewController {
                        strongSelf.homeCoordinatorDelegate?.showDialog(acceptTitle: nil, cancelTitle: nil, title: nil, body: nil, showsCloseButton: false, source: view, acceptAction: nil, cancelAction: nil)
                    }
                }
            })
        } else {
            self.accountTransactionsSearchCoordinator.dismiss()
            let concept = self.filters.getTransactionDescription()
            let typeSearch = concept?.isEmpty != false ? CriteriaFilter.byCharacteristics : CriteriaFilter.byTerm
            self.delegate?.didApplyFilter(self.filters, typeSearch)
        }
    }
}

private extension AccountTransactionsSearchPresenter {
    func isOverSCALimit() -> Bool {
        guard let startEndDates = view?.getStartEndDates() else {
            return false
        }
        let numberOfDays: Int = Date().days(from: startEndDates.startDate) ?? 0
        return numberOfDays >= 90
    }
    
    func shouldShowAlert(conceptText: String) -> Bool {
        guard !conceptText.isEmpty else { return false }
        if isOverSCALimit() {
            return true
        }
        if self.view?.getFromAmount() != nil {
            return true
        }
        if self.view?.getToAmount() != nil {
            return true
        }
        if let indexMovementType = self.view?.getIndexMovementType(),
            let accountTransactionTypeFilter = TransactionConceptType(rawValue: indexMovementType),
            accountTransactionTypeFilter != .all {
            return true
        }
        if let indexOperationType = self.view?.getIndexOperationType(),
            let accountOperativeActionType = TransactionOperationTypeEntity(rawValue: indexOperationType),
            accountOperativeActionType != .all {
            return true
        }
        return false
    }
    
    func addDateFilter() {
        guard let startEndDates = self.view?.getStartEndDates() else { return }
        self.filters.addDateFilter(startEndDates.startDate, toDate: startEndDates.endDate)
        self.filters.addDateRangeGroupIndex(self.view?.getDateRangeSegmentIndex() ?? -1)
        trackEvent(.apply, parameters: [.searchType: AccountFilterOperationType.dates.rawValue])
    }
    
    private func getTextMessageFilteredMovements() {
        if let accountSelectd = self.delegate?.getSelectedAccount() {
            self.homeCoordinatorDelegate?.goToAccountsOTP(delegate: self, scaTransactionParams: SCATransactionParams(account: accountSelectd,
                                                                                                                     pagination: nil,
                                                                                                                     scaState: self.scaState,
                                                                                                                     filters: self.filters,
                                                                                                                     filtersIsShown: false))
        }
    }
}

extension AccountTransactionsSearchPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: AccountFilterPage {
        return AccountFilterPage()
    }
}
