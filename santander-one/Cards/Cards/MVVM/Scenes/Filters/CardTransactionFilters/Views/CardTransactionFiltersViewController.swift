//
//  CardTransactionFiltersViewController.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

final class CardTransactionFiltersViewController : UIViewController {
    private let viewModel: CardTransactionFiltersViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardTransactionFiltersDependenciesResolver
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    
    @IBOutlet private weak var conceptTextView: NameFilterView!
    @IBOutlet private weak var conceptSeparatorView: UIView!
    @IBOutlet private weak var segmentedControlView: SegmentedControlFilterView!
    @IBOutlet private weak var dateFilterView: DateFilterView!
    @IBOutlet private weak var dateSeparatorView: UIView!
    @IBOutlet private weak var amountRangeView: AmountRangeFilterView!
    @IBOutlet private weak var amountSeparatorView: UIView!
    @IBOutlet private weak var operationTypeView: OperativeFilterView!
    @IBOutlet private weak var applyButton: WhiteLisboaButton!
    @IBOutlet private weak var applyButtonView: UIView!
    @IBOutlet private weak var searchScrollView: UIScrollView!
    
    private var currentLanguage: String
    private var availableFilters = CardAvailableFilters()
    
    init(dependencies: CardTransactionFiltersDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        let stringLoader: StringLoader = dependencies.external.resolve()
        self.currentLanguage = stringLoader.getCurrentLanguage().languageType.rawValue
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: "CardTransactionFiltersViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setupNavigationBar()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

private extension CardTransactionFiltersViewController {
    
    func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }
    
    @objc func hideKeyboard() {
        view?.endEditing(true)
    }
    
    @objc private func back() {
        viewModel.dismiss()
    }
    
    @objc func clickContinueButton(_ gesture: UITapGestureRecognizer) {
        applyFilters(filtersAvailable: availableFilters)
    }
    
    func setAppearance() {
        self.view.backgroundColor = UIColor.skyGray
        applyButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        applyButton.setTitle(localized("generic_button_apply"), for: .normal)
        applyButton.addSelectorAction(target: self, #selector(clickContinueButton))
        applyButtonView.drawShadow(offset: (x: 0, y: -1), opacity: 1, color: .coolGray, radius: 2)
        conceptTextView.isHidden = true
        segmentedControlView.isHidden = true
        amountRangeView.isHidden = true
        operationTypeView.isHidden = true
        dateFilterView.setSceneLanguage(lang: self.currentLanguage)
        dateFilterView.configureTextFields()
        dateFilterView.setSelectedIndex(2)
        setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.applyButton.accessibilityIdentifier = AccessibilityCardsFilter.applyButton
        self.applyButtonView.accessibilityIdentifier = AccessibilityCardsFilter.applyButtonView
        self.conceptTextView.accessibilityIdentifier = AccessibilityCardsFilter.searchConceptView
        self.segmentedControlView.accessibilityIdentifier = AccessibilityCardsFilter.segmentedControlView
        self.dateFilterView.accessibilityIdentifier = AccessibilityCardsFilter.dateFilterView
        self.amountRangeView.accessibilityIdentifier = AccessibilityCardsFilter.dateFilterView
        self.operationTypeView.accessibilityIdentifier = AccessibilityCardsFilter.operationTypeView
    }
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_search"))
            .addLeftAction(.back, selector: #selector(back))
            .addRightAction(.close, selector: #selector(back))
            .build(on: self)
    }
    func bind() {
        self.bindFiltersAvalible()
        self.bindFilters()
        self.bindAmountRangeView()
        self.bindOperationFilterView()
        self.bindDateFilterView()
    }
    
    func bindFiltersAvalible() {
        self.viewModel.state
            .case(CardTransactionFiltersState.availableFiltersLoaded)
            .sink { [unowned self ] filters in
                configureFilters(filters: filters)
            }.store(in: &subscriptions)
    }
    
    func bindFilters() {
        self.viewModel.state
            .case(CardTransactionFiltersState.filtersLoaded)
            .sink { [unowned self ] filters in
                self.setFilters(filters: filters)
            }.store(in: &subscriptions)
    }
    
    func bindAmountRangeView() {
        amountRangeView.onDidOpenSectionSubject
            .sink { [unowned self] view in
                searchScrollView.scrollRectToVisible(view.frame, animated: true)
            }.store(in: &subscriptions)
    }
    
    func bindOperationFilterView() {
        operationTypeView.onDidOpenSectionSubject
            .sink { [unowned self] view in
                searchScrollView.scrollRectToVisible(view.frame, animated: true)
            }.store(in: &subscriptions)
    }
    
    func bindDateFilterView() {
        dateFilterView.onDidOpenSectionSubject
            .sink { [unowned self] view in
                searchScrollView.scrollRectToVisible(view.frame, animated: true)
            }.store(in: &subscriptions)
    }
    
    func configureFilters(filters: CardTransactionAvailableFiltersRepresentable) {
        if filters.byAmount {
            amountRangeView.isHidden = false
            amountSeparatorView.isHidden = false
        }
        if filters.byExpenses {
            segmentedControlView.isHidden = false
            setExpenses(expenses: nil)
            
        }
        if filters.byConcept {
            conceptTextView.isHidden = false
            conceptSeparatorView.isHidden = false
            setConceptView()
        }
        if filters.byTypeOfMovement {
            operationTypeView.isHidden = false
            setOperativeView(movement: nil)
        }
        
        availableFilters.configure(byAmount: filters.byAmount, byExpenses: filters.byExpenses, byTypeOfMovement: filters.byTypeOfMovement, byConcept: filters.byConcept)
    }
    
    func setDateView(date: CardTransactionFilterDate) {
        if date.indexRange == -1 {
            self.dateFilterView.setDateSelected(date.startDate, date.endDate)
        } else {
            self.dateFilterView.setSelectedIndex(date.indexRange)
        }
    }
    
    func setAmountView(amount: CardTransactionFilterType.Amount) {
        var fromAmount: Decimal?
        var toAmount: Decimal?
        switch amount {
        case .from(let amount):
            fromAmount = amount
        case .limit(let amount):
            toAmount = amount
        case .range(from: let from, limit: let limit):
            fromAmount = from
            toAmount = limit
        }
        
        let isColapsed = fromAmount != nil || toAmount != nil
        self.amountRangeView.set(fromAmount: fromAmount?.getStringValue() ?? "0.0",
                                 toAmount: toAmount?.getStringValue() ?? "0.0",
                                 isColapsed: isColapsed)
    }
    
    func setOperativeView(movement: CardOperationType?) {
        let allOperationTypeValues: [String] = CardOperationType.allCases.map {
            localized($0.descriptionKey)
        }
        self.operationTypeView.configure(viewTitle: localized("search_label_operation"), textfieldOptions: allOperationTypeValues, itemSelected: movement?.rawValue ?? 0, isColapsed: false)
        self.operationTypeView.setAlwaysExpanded()
    }
    
    func setConceptView() {
        self.conceptTextView.setupTitles(viewTitle: localized("search_label_movementName"), textfieldTitle: localized("search_hint_textConcept"))
        self.conceptTextView.setAllowedCharacters(.operative)
    }
    
    func setExpenses(expenses: TransactionConceptType?) {
        let allExpensesValues: [String] = TransactionConceptType.allCases.map { $0.descriptionKey }
        segmentedControlView.configure(title: localized("search_label_expenseIncome"), types: allExpensesValues, itemSelected: expenses?.rawValue ?? 0)
    }
    
    func setFilters(filters: [CardTransactionFilterType]) {
        filters.forEach { filter in
            switch filter {
            case .byAmount(let amount):
                setAmountView(amount: amount)
            case .byDate(let date):
                setDateView(date: date)
            case .byTypeOfMovement(let movement):
                setOperativeView(movement: movement)
            case .byConcept(let term):
                self.conceptTextView.setFilterSelected(term)
            case .byExpenses(let expenses):
                setExpenses(expenses: expenses)
            }
        }
    }
    
    func getDateFilter() -> CardTransactionFilterDate {
        let datesSelected = self.dateFilterView.getStartEndDates()
        return CardTransactionFilterDate(startDate: datesSelected.startDate, endDate: datesSelected.endDate, indexRange: self.dateFilterView.getSelectedIndex())
        
    }
    
    func getConceptFilter() -> String? {
        if let conceptText = conceptTextView.text, !conceptText.isEmpty {
            return conceptText
        }
        
        return nil
    }
    
    func getExpensesFilter() -> TransactionConceptType? {
        let indexMovementType = segmentedControlView.getSelectedIndex()
        let transactionTypeFilter = TransactionConceptType(rawValue: indexMovementType)
        if transactionTypeFilter != .all {
            return transactionTypeFilter
        }
        return nil
    }
    
    func getAmountFilter() -> CardTransactionFilterType.Amount? {
        guard let fromAmount = self.amountRangeView.fromAmount,
              let toAmount = self.amountRangeView.toAmount else {
                  return addAmountFilter(fromAmount: self.amountRangeView.fromDecimal, toAmount: self.amountRangeView.toDecimal)
              }
        let isRangeAmountValid = self.validateAmount()
        if !fromAmount.isEmpty && !toAmount.isEmpty, !isRangeAmountValid {
            self.showOldDialog(title: localized("generic_alert_title_errorData"), description: localized("search_alert_amountLimit"), acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil), cancelAction: nil, isCloseOptionAvailable: false)
        } else {
            return addAmountFilter(fromAmount: self.amountRangeView.fromDecimal, toAmount: self.amountRangeView.toDecimal)
        }
        
        return nil
    }
    
    func addAmountFilter(fromAmount: Decimal?, toAmount: Decimal?) -> CardTransactionFilterType.Amount? {
        if let famount = fromAmount, let tamount = toAmount {
            return CardTransactionFilterType.Amount.range(from: famount, limit: tamount)
        } else if let famount = fromAmount {
            return CardTransactionFilterType.Amount.from(famount)
        } else if let tamount = toAmount {
            return CardTransactionFilterType.Amount.limit(tamount)
        } else {
            return nil
        }
    }
    
    func getOperationTypeFilter() -> CardOperationType? {
        if let indexOperationType = operationTypeView.getSelectedIndex(), let cardOperationType = CardOperationType(rawValue: indexOperationType) {
            viewModel.trackEvent(.apply, parameters: [.searchType: CardFilterOperationType.operationType.rawValue, .operationType: cardOperationType.trackName])
            if cardOperationType != .all {
                return cardOperationType
            }
        }
        return nil
    }
    
    func applyFilters(filtersAvailable: CardTransactionAvailableFiltersRepresentable) {
        var filters: [CardTransactionFilterType] = []
        
        filters.append(CardTransactionFilterType.byDate(getDateFilter()))
        
        if let concept = getConceptFilter(), filtersAvailable.byConcept {
            filters.append(CardTransactionFilterType.byConcept(concept))
        }
        if let amount = getAmountFilter(), filtersAvailable.byAmount {
            filters.append(CardTransactionFilterType.byAmount(amount))
        }
        if let expenses = getExpensesFilter(), filtersAvailable.byExpenses {
            filters.append(CardTransactionFilterType.byExpenses(expenses))
        }
        if let typeMovement = getOperationTypeFilter(), filtersAvailable.byTypeOfMovement {
            filters.append(CardTransactionFilterType.byTypeOfMovement(typeMovement))
        }
        
        viewModel.save(filters: filters)
        
    }
    
    func validateAmount() -> Bool {
        guard let fromDecimal = self.amountRangeView.fromDecimal,
              let toDecimal = self.amountRangeView.toDecimal else {
                  return false
              }
        return fromDecimal <= toDecimal
    }
    
}

extension CardTransactionFiltersViewController: OldDialogViewPresentationCapable { }
