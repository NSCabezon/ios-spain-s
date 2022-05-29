//
//  ExpensesIncomeFilterPresenter.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 5/7/21.
//
import CoreFoundationLib
import CoreDomain

protocol ExpensesIncomeFilterPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: ExpensesIncomeFilterView? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectApply()
}

final class ExpensesIncomeFilterPresenter: ExpensesIncomeFilterPresenterProtocol {
    let dependenciesResolver: DependenciesResolver
    weak var view: ExpensesIncomeFilterView?
    private var filters: DetailFilter = DetailFilter()
    private let coordinator: ExpensesIncomeFilterCoordinatorProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.coordinator = dependenciesResolver.resolve()
    }
}

private extension ExpensesIncomeFilterPresenter {
    weak var delegate: ExpensesIncomeFilterDelegate? {
        return dependenciesResolver.resolve(for: ExpensesIncomeFilterDelegate.self)
    }
    
    func isRangeAmountValid(fromAmount: Decimal, toAmount: Decimal) -> Bool {
        return fromAmount <= toAmount
    }
    
    func addConceptFilter() {
        if let conceptText = self.view?.getConceptText(), !conceptText.isEmpty {
            self.filters.addDescriptionFilter(conceptText)
        }
    }
    
    func addMovementFilter() {
        guard let indexMovementType = self.view?.getIndexMovementType(),
              let movementTypeFilter = DetailFilterConceptType(rawValue: indexMovementType)
        else { return }
        if movementTypeFilter != .all {
            self.filters.addMovementFilter(movementTypeFilter)
        }
    }
    
    func addAmountFilter(areFiltersValid: inout Bool) {
        if let fromAmount = self.view?.getFromAmount(),
           let toAmount = self.view?.getToAmount() {
            if self.isRangeAmountValid(fromAmount: fromAmount, toAmount: toAmount) {
                self.filters.addAmountFilter(fromAmount, toAmount: toAmount)
            } else {
                areFiltersValid = false
                self.view?.showDialog(titleKey: "generic_alert_title_errorData", descriptionKey: "search_alert_amountLimit", acceptAction: "generic_button_accept")
            }
        } else if self.view?.getFromAmount() != nil || self.view?.getToAmount() != nil {
            self.filters.addAmountFilter(self.view?.getFromAmount(), toAmount: self.view?.getToAmount())
        }
    }
    
    func retrieveExistingFilters() {
        let filters = delegate?.getFilters()
        self.view?.addConcept(title: localized("search_label_movementName"), textFieldTitle: localized("search_hint_textConcept"), textSelected: filters?.getTransactionDescription())
        let allExpensesValues: [String] = TransactionConceptType.allCases.map { $0.descriptionKey }
        self.view?.addSegmentedControl(title: localized("search_label_expenseIncome"), types: allExpensesValues, itemSelected: filters?.getMovementType().rawValue ?? 0)
        let fromAmount = AmountEntity(value: filters?.fromAmountDecimal ?? Decimal())
        let toAmount = AmountEntity(value: filters?.toAmountDecimal ?? Decimal())
        self.view?.setRangeAmountFilter(fromAmount: fromAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        toAmount: toAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        isColapsed: true)
    }
}

extension ExpensesIncomeFilterPresenter {
    func viewDidLoad() {
        self.retrieveExistingFilters()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectApply() {
        var areFiltersValid: Bool = true
        self.filters = DetailFilter()
        self.filters.setSubcategory(self.delegate?.getFilters().getSubcategory())
        self.addConceptFilter()
        self.addMovementFilter()
        self.addAmountFilter(areFiltersValid: &areFiltersValid)
        if areFiltersValid {
            self.coordinator.dismiss()
            self.delegate?.didApplyFilters(filters)
        }
    }
}
