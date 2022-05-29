//
//  LoanTransactionsSearchViewController.swift
//  Loans
//
//  Created by Juan Jose Acosta on 10/3/21.
//

import UIKit
import CoreFoundationLib
import UI
import OpenCombine
import CoreDomain

final class LoanTransactionSearchViewController: UIViewController {
    lazy var scrollableStackView = ScrollableStackView(frame: .zero)
    @IBOutlet private weak var conceptTextView: NameFilterView!
    @IBOutlet private weak var conceptSeparatorView: UIView!
    @IBOutlet private weak var dateSeparatorView: UIView!
    @IBOutlet private weak var segmentedControlView: SegmentedControlFilterView!
    @IBOutlet private weak var operationTypeView: OperativeFilterView!
    @IBOutlet private weak var applyButton: WhiteLisboaButton!
    @IBOutlet private weak var amountSeparatorView: UIView!
    @IBOutlet private weak var amountRangeView: AmountRangeFilterView!
    @IBOutlet private weak var dateFilterView: DateFilterView!
    @IBOutlet private weak var searchScrollView: UIScrollView!
    @IBOutlet private weak var applyButtonView: UIView!
    private let dependencies: LoanTransactionSearchDependenciesResolver
    private let viewModel: LoanTransactionSearchViewModel
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    private var subscriptions: Set<AnyCancellable> = []
    var newFilters = TransactionFiltersEntity()
    var currentLanguage: String
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(dependencies: LoanTransactionSearchDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        let stringLoader: StringLoader = dependencies.external.resolve()
        self.currentLanguage = stringLoader.getCurrentLanguage().languageType.rawValue
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: "LoanTransactionSearch", bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setAccessibilityIdentifiers()
        self.dateFilterView.setSceneLanguage(lang: self.currentLanguage)
        self.dateFilterView.configureTextFields()
        self.bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.hideKeyboardWhenTappedAround()
    }
}

private extension LoanTransactionSearchViewController {
    func setupView() {
        self.view.backgroundColor = UIColor.skyGray
        applyButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        applyButton.setTitle(localized("generic_button_apply"), for: .normal)
        applyButton.addSelectorAction(target: self, #selector(clickContinueButton))
        applyButtonView.drawShadow(offset: (x: 0, y: -1), opacity: 1, color: .coolGray, radius: 2)
    }
    
    @objc func clickContinueButton(_ gesture: UITapGestureRecognizer) {
        self.applyFilters()
    }
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_search"))
            .setLeftAction(.back, associatedAction: .closure { [weak self] in
                self?.viewModel.close()
            })
            .addRightAction(.close, associatedAction: .closure({ [weak self] in
                self?.viewModel.close()
            }))
            .build(on: self)
    }
    
    func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }
    
    @objc func hideKeyboard() {
        view?.endEditing(true)
    }
    
    func bind() {
        self.bindInitialFilters()
        self.bindConfiguration()
        self.bindAmountRangeViewOpenSection()
        self.bindOperationFilterViewOpenSection()
        self.bindDateFilterViewOpenSection()
    }
    
    func bindInitialFilters() {
        self.viewModel.state
            .case(LoanTransactionSearchState.initialFilters)
            .sink { [unowned self ] filters in
                self.setFilters(filters: filters)
            }.store(in: &subscriptions)
    }
    
    func bindConfiguration() {
        self.viewModel.state
            .case(LoanTransactionSearchState.configurationLoaded)
            .sink { [unowned self ] config in
                self.hideFiltersViewsIfNeeded(config)
            }.store(in: &subscriptions)
    }
    
    func bindAmountRangeViewOpenSection() {
        amountRangeView.onDidOpenSectionSubject
            .sink { [unowned self] view in
                searchScrollView.scrollRectToVisible(view.frame, animated: true)
            }.store(in: &subscriptions)
    }
    
    func bindOperationFilterViewOpenSection() {
        operationTypeView.onDidOpenSectionSubject
            .sink { [unowned self] view in
                searchScrollView.scrollRectToVisible(view.frame, animated: true)
            }.store(in: &subscriptions)
    }
    
    func bindDateFilterViewOpenSection() {
        dateFilterView.onDidOpenSectionSubject
            .sink { [unowned self] view in
                searchScrollView.scrollRectToVisible(view.frame, animated: true)
            }.store(in: &subscriptions)
    }
    
    func setFilters(filters: TransactionFiltersEntity) {
        var hasDateSelected = false
        if let startDateSelected = filters.getDateRange()?.fromDate,
            let endDateSelected = filters.getDateRange()?.toDate {
            self.dateFilterView.setDateSelected(startDateSelected, endDateSelected)
            hasDateSelected = true
        }
        let filterRangeIndex = filters.getSelectedDateRangeGroupIndex()
        var selectedDateRangeIndex = -1
        if filterRangeIndex < 0 && !hasDateSelected {
            selectedDateRangeIndex = 2
        } else {
            selectedDateRangeIndex = filterRangeIndex
        }
        self.dateFilterView.setSelectedIndex(selectedDateRangeIndex)
        let isColapsed = filters.fromAmountDecimal != nil || filters.toAmountDecimal != nil
        let fromAmount = AmountEntity(value: filters.fromAmountDecimal ?? Decimal())
        let toAmount = AmountEntity(value: filters.toAmountDecimal ?? Decimal())
        self.amountRangeView.set(fromAmount: fromAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        toAmount: toAmount.getFormattedValueOrEmpty(truncateDecimalIfZero: true),
                                        isColapsed: isColapsed)
    }
    
    func hideFiltersViewsIfNeeded(_ config: LoanTransactionSearchConfigRepresentable) {
        self.conceptTextView.isHidden = !config.isEnabledConceptFilter
        self.operationTypeView.isHidden = !config.isEnabledOperationTypeFilter
        self.amountRangeView.isHidden = !config.isEnabledAmountRangeFilter
        self.amountSeparatorView.isHidden = !config.isEnabledAmountRangeFilter
        self.dateSeparatorView.isHidden = !config.isEnabledDateFilter
        self.conceptSeparatorView.isHidden = !config.isEnabledConceptFilter
        self.segmentedControlView.isHidden = !config.isEnabledConceptFilter
    }
    
    func setAccessibilityIdentifiers() {
        self.applyButton.accessibilityIdentifier = AccessibilityLoansFilter.applyButton
        self.applyButtonView.accessibilityIdentifier = AccessibilityLoansFilter.applyButtonView
        self.conceptTextView.accessibilityIdentifier = AccessibilityLoansFilter.searchConceptView
        self.segmentedControlView.accessibilityIdentifier = AccessibilityLoansFilter.segmentedControlView
        self.dateFilterView.accessibilityIdentifier = AccessibilityLoansFilter.dateFilterView
        self.amountRangeView.accessibilityIdentifier = AccessibilityLoansFilter.dateFilterView
        self.operationTypeView.accessibilityIdentifier = AccessibilityLoansFilter.operationTypeView
    }
    
    func applyFilters() {
        self.newFilters = TransactionFiltersEntity()
        let startEndDates = self.dateFilterView.getStartEndDates()
        self.newFilters.addDateFilter(startEndDates.startDate, toDate: startEndDates.endDate)
        self.newFilters.addDateRangeGroupIndex(self.dateFilterView.getSelectedIndex())
        guard let fromAmount = self.amountRangeView.fromAmount,
            let toAmount = self.amountRangeView.toAmount else {
                self.viewModel.trackEvent(.apply_days, parameters: [:])
            self.addAmountFilter(fromAmount: self.amountRangeView.fromDecimal, toAmount: self.amountRangeView.toDecimal)
            self.viewModel.returnWithFilters(filters: newFilters)
            return
        }
        let isRangeAmountValid = self.validateAmount()
        if !fromAmount.isEmpty && !toAmount.isEmpty, !isRangeAmountValid {
            self.showOldDialog(title: localized("generic_alert_title_errorData"), description: localized("search_alert_amountLimit"), acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil), cancelAction: nil, isCloseOptionAvailable: false)
        } else {
            self.viewModel.trackEvent(.apply_days_amount, parameters: [:])
            self.addAmountFilter(fromAmount: self.amountRangeView.fromDecimal, toAmount: self.amountRangeView.toDecimal)
            self.viewModel.returnWithFilters(filters: newFilters)
        }
    }
    
    func addAmountFilter(fromAmount: Decimal?, toAmount: Decimal?) {
        self.newFilters.fromAmount = fromAmount
        self.newFilters.toAmount = toAmount
        if self.newFilters.fromAmount == nil && self.newFilters.toAmount == nil {
            return
        }
        var fromAmountString: String?
        var toAmountString: String?
        if let famount = self.newFilters.fromAmount, let fromAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: famount)) {
            fromAmountString = fromAmountStr
        }
        if let tamount = self.newFilters.toAmount, let toAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: tamount)) {
            toAmountString = toAmountStr
        }
        self.newFilters.filters.append(.byAmount(from: fromAmountString, limit: toAmountString))
    }
    
    func validateAmount() -> Bool {
        guard let fromDecimal = self.amountRangeView.fromDecimal,
              let toDecimal = self.amountRangeView.toDecimal else {
            return false
        }
        return fromDecimal <= toDecimal
    }
}

extension LoanTransactionSearchViewController: OldDialogViewPresentationCapable { }
