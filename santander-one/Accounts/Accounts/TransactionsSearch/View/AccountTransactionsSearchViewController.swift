//
//  AccountTransactionsSearchViewController.swift
//  Account
//
//  Created by Tania Castellano Brasero on 30/01/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol AccountTransactionsSearchViewProtocol: AnyObject {
    func addConcept(title: String, textFieldTitle: String, textSelected: String?)
    func addSegmentedControl(title: String, types: [String], itemSelected: Int)
    func getTextConcept() -> String?
    func getFromAmount() -> String?
    func getToAmount() -> String?
    func getStartEndDates() -> (startDate: Date, endDate: Date)
    func addOperationTypeFilter(title: String, types: [String], itemSelected: Int, isColapsed: Bool)
    func addDateFilter(startDateSelected: Date?, endDateSelected: Date?)
    func setRangeAmountFilter(fromAmount: String, toAmount: String, isColapsed: Bool)
    func getIndexMovementType() -> Int?
    func getIndexOperationType() -> Int?
    func getFromToRange() -> (from: Decimal?, to: Decimal?)
    func getDateRangeSegmentIndex() -> Int
    func setDateRangeSegmentIndex(_ index: Int)
    func hideFiltersViewsIfNeeded(_ filtersConfig: AccountTransactionProtocol)
}

final class AccountTransactionsSearchViewController: UIViewController {
    var presenter: AccountTransactionsSearchPresenterProtocol
    lazy var scrollableStackView = ScrollableStackView(frame: .zero)
    @IBOutlet private weak var conceptTextView: NameFilterView!
    @IBOutlet private weak var conceptSeparatorView: UIView!
    @IBOutlet private weak var dateSeparatorView: UIView!
    @IBOutlet private weak var conceptView: NameFilterView!
    @IBOutlet private weak var segmentedControlView: SegmentedControlFilterView!
    @IBOutlet private weak var operationTypeView: OperativeFilterView!
    @IBOutlet private weak var applyButton: WhiteLisboaButton!
    @IBOutlet private weak var amountSeparatorView: UIView!
    @IBOutlet private weak var amountRangeView: AmountRangeFilterView!
    @IBOutlet private weak var dateFilterView: DateFilterView!
    @IBOutlet private weak var searchScrollView: UIScrollView!
    @IBOutlet private weak var applyButtonView: UIView!
    
    init(nibName: String?, bundle: Bundle?, presenter: AccountTransactionsSearchPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setDelegates()
        self.dateFilterView.configureTextFields()
        self.setAccessibilityIdentifiers()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        hideKeyboardWhenTappedAround()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func hideKeyboard() {
        view?.endEditing(true)
    }
    
    private func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.skyGray
        applyButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        applyButton.setTitle(localized("generic_button_apply"), for: .normal)
        applyButton.addSelectorAction(target: self, #selector(clickContinueButton))
        applyButtonView.drawShadow(offset: (x: 0, y: -1), opacity: 1, color: .coolGray, radius: 2)
    }
    
    private func setDelegates() {
        amountRangeView.delegate = self
        operationTypeView.delegate = self
        dateFilterView.delegate = self
    }
        
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_search")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: self.presenter)
    }
    
    public func setAccessibilityIdentifiers() {
        self.applyButton.accessibilityIdentifier = AccessibilityAccountFilter.applyButton
        self.applyButtonView.accessibilityIdentifier = AccessibilityAccountFilter.applyButtonView
        self.conceptTextView.accessibilityIdentifier = AccessibilityAccountFilter.searchConceptView
        self.segmentedControlView.accessibilityIdentifier = AccessibilityAccountFilter.segmentedControlView
        self.dateFilterView.accessibilityIdentifier = AccessibilityAccountFilter.dateFilterView
        self.amountRangeView.accessibilityIdentifier = AccessibilityAccountFilter.dateFilterView
        self.operationTypeView.accessibilityIdentifier = AccessibilityAccountFilter.operationTypeView
    }

    @objc func clickContinueButton(_ gesture: UITapGestureRecognizer) {
        self.presenter.applyFilters()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

extension AccountTransactionsSearchViewController: AccountTransactionsSearchViewProtocol {
    func hideFiltersViewsIfNeeded(_ filtersConfig: AccountTransactionProtocol) {
        self.conceptView.isHidden = !filtersConfig.isEnabledConceptFilter
        self.operationTypeView.isHidden = !filtersConfig.isEnabledOperationTypeFilter
        self.amountRangeView.isHidden = !filtersConfig.isEnabledAmountRangeFilter
        self.amountSeparatorView.isHidden = !filtersConfig.isEnabledAmountRangeFilter
        self.dateSeparatorView.isHidden = !filtersConfig.isEnabledDateFilter
    }
 
    func addConcept(title: String, textFieldTitle: String, textSelected: String?) {
        self.conceptTextView.setupTitles(viewTitle: title, textfieldTitle: textFieldTitle)
        self.conceptTextView.setAllowedCharacters(.operative)
        self.conceptTextView.setFilterSelected(textSelected)
    }
    
    func addSegmentedControl(title: String, types: [String], itemSelected: Int) {
        self.segmentedControlView.configure(title: title, types: types, itemSelected: itemSelected)
    }
    
    func addDateFilter(startDateSelected: Date?, endDateSelected: Date?) {
        guard let startDateSelected = startDateSelected, let endDateSelected = endDateSelected else { return }
        self.dateFilterView.setDateSelected(startDateSelected, endDateSelected)
    }
    
    func setRangeAmountFilter(fromAmount: String, toAmount: String, isColapsed: Bool) {
        self.amountRangeView.set(fromAmount: fromAmount, toAmount: toAmount, isColapsed: isColapsed)
    }
    
    func setDateRangeSegmentIndex(_ index: Int) {
        self.dateFilterView.setSelectedIndex(index)
    }
    
    func getTextConcept() -> String? {
        return self.conceptTextView.text
    }
    
    func getFromAmount() -> String? {
        return self.amountRangeView.fromAmount
    }
    
    func getToAmount() -> String? {
        return self.amountRangeView.toAmount
    }
    
    func getStartEndDates() -> (startDate: Date, endDate: Date) {
        return dateFilterView.getStartEndDates()
    }
    
    func getIndexMovementType() -> Int? {
        return self.segmentedControlView.getSelectedIndex()
    }
    
    func getIndexOperationType() -> Int? {
        return self.operationTypeView.getSelectedIndex()
    }
    
    func addOperationTypeFilter(title: String, types: [String], itemSelected: Int, isColapsed: Bool) {
        self.operationTypeView.configure(viewTitle: title, textfieldOptions: types, itemSelected: itemSelected, isColapsed: isColapsed)
    }
    
    func getFromToRange() -> (from: Decimal?, to: Decimal?) {
        return (self.amountRangeView?.fromDecimal, self.amountRangeView?.toDecimal)
    }
    
    func getDateRangeSegmentIndex() -> Int {
        return self.dateFilterView.getSelectedIndex()
    }
}

extension AccountTransactionsSearchViewController: DialogViewPresentationCapable {
    var associatedDialogView: UIViewController {
        return self
    }
}

extension AccountTransactionsSearchViewController: OperativeFilterViewDelegate, AmountRangeFilterViewDelegate, DateFilterViewDelegate {
    func didOpenSection(view: UIView) {
        searchScrollView.scrollRectToVisible(view.frame, animated: true)
    }
    
    func getLanguage() -> String {
        return self.presenter.getLanguage()
    }
}
