//
//  LoanTransactionsSearchPresenter.swift
//  Loans
//
//  Created by Rodrigo Jurado on 5/10/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol OldLoanSearchPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: OldLoanSearchViewProtocol? {get set}
    func viewDidLoad()
    func didSelectDismiss()
    func applyFilters()
    func getLanguage() -> String
}

final class OldLoanSearchPresenter {
    weak var view: OldLoanSearchViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var filters: TransactionFiltersEntity = TransactionFiltersEntity()

    private var loanTransactionsSearchCoordinator: OldDefaultLoanSearchCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: OldDefaultLoanSearchCoordinatorProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension OldLoanSearchPresenter: OldLoanSearchPresenterProtocol {
    func viewDidLoad() {
        trackScreen()
        let filters = self.loanTransactionsSearchCoordinator.getFilters()
        self.view?.addDateFilter(startDateSelected: filters?.getDateRange()?.fromDate, endDateSelected: filters?.getDateRange()?.toDate)
        self.view?.setDateRangeSegmentIndex(filters?.getSelectedDateRangeGroupIndex() ?? 2)
        let isColapsed = filters?.fromAmountDecimal != nil || filters?.toAmountDecimal != nil
        let fromAmount = AmountEntity(value: filters?.fromAmountDecimal ?? Decimal())
        let toAmount = AmountEntity(value: filters?.toAmountDecimal ?? Decimal())
        self.view?.setRangeAmountFilter(fromAmount: fromAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        toAmount: toAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        isColapsed: isColapsed)
        if let filtersConfig = self.dependenciesResolver.resolve(forOptionalType: OldLoanSearchModifier.self) {
            self.view?.hideFiltersViewsIfNeeded(filtersConfig)
        }
    }

    func didSelectDismiss() {
        self.loanTransactionsSearchCoordinator.dismiss()
    }
    
    func applyFilters() {
        self.applyByCharacteristics()
    }

    func getLanguage() -> String {
        return dependenciesResolver.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.rawValue ?? "en"
    }
}

private extension OldLoanSearchPresenter {
    private func validateAmount(fromAmount: String, toAmount: String) -> Bool {
        guard let fdecimal = self.view?.getFromToRange().from else {
            return false
        }

        guard let tdecimal = self.view?.getFromToRange().to else {
                   return false
        }

        return fdecimal <= tdecimal
    }

    private func applyByCharacteristics() {
        self.filters = TransactionFiltersEntity()
        if let startEndDates = self.view?.getStartEndDates() {
            self.filters.addDateFilter(startEndDates.startDate, toDate: startEndDates.endDate)
            self.filters.addDateRangeGroupIndex(self.view?.getDateRangeSegmentIndex() ?? -1)
        }

        guard let fromAmount = self.view?.getFromAmount(),
            let toAmount = self.view?.getToAmount(),
            let view = self.view as? OldDialogViewPresentationCapable
        else {
            self.addAmountFilter(filters: self.filters, fromAmount: self.view?.getFromToRange().from, toAmount: self.view?.getFromToRange().to)
            self.goToCharacteristics()
            return
        }

        // is range amount not valid shows dialog
        let isRangeAmountValid = self.validateAmount(fromAmount: fromAmount, toAmount: toAmount)

        if !fromAmount.isEmpty && !toAmount.isEmpty, !isRangeAmountValid {
            view.showOldDialog(title: localized("generic_alert_title_errorData"), description: localized("search_alert_amountLimit"), acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil), cancelAction: nil, isCloseOptionAvailable: false)
        } else {
            self.addAmountFilter(filters: self.filters, fromAmount: self.view?.getFromToRange().from, toAmount: self.view?.getFromToRange().to)
            self.goToCharacteristics()
        }
    }

    private func addAmountFilter(filters: TransactionFiltersEntity, fromAmount: Decimal?, toAmount: Decimal?) {
        filters.fromAmount = fromAmount
        filters.toAmount = toAmount
        if filters.fromAmount == nil && filters.toAmount == nil {
            return
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
    }

    private func addDateFilter() {
        guard let startEndDates = self.view?.getStartEndDates() else { return }
        self.filters.addDateFilter(startEndDates.startDate, toDate: startEndDates.endDate)
        self.filters.addDateRangeGroupIndex(self.view?.getDateRangeSegmentIndex() ?? -1)
    }

    private func goToCharacteristics() {
        self.loanTransactionsSearchCoordinator.dismiss()
        self.loanTransactionsSearchCoordinator
            .didApplyFilter(self.filters, criteria: .byCharacteristics)
    }
}

extension OldLoanSearchPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }

    var trackerPage: LoanSearchPage {
        return LoanSearchPage()
    }
}
