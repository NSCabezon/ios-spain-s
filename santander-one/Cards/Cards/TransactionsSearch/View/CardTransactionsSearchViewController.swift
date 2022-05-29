//
//  CardTransactionsSearchViewController.swift
//  Cards
//
//  Created by Tania Castellano Brasero on 13/02/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol CardTransactionsSearchViewProtocol: AnyObject {
    func addConcept(title: String, textFieldTitle: String, textSelected: String?)
    func addSegmentedControl(title: String, types: [String], itemSelected: Int)
    func getTextConcept() -> String?
    func getFromAmount() -> String?
    func getToAmount() -> String?
    func getFromToRange() -> (from: Decimal?, to: Decimal?)
    func getStartEndDates() -> (startDate: Date, endDate: Date)
    func addDateFilter(startDateSelected: Date?, endDateSelected: Date?)
    func setRangeAmountFilter(fromAmount: String, toAmount: String, isColapsed: Bool)
    func getDateRangeSegmentIndex() -> Int
    func setDateRangeSegmentIndex(_ index: Int)
    func getIndexMovementType() -> Int?
    func getIndexOperationType() -> Int?
    func addOperationTypeFilter(title: String, types: [String], itemSelected: Int, isColapsed: Bool)
}

final class CardTransactionsSearchViewController: UIViewController {
    var presenter: CardTransactionsSearchPresenterProtocol
    lazy var scrollableStackView = ScrollableStackView(frame: .zero)
    
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
    
    init(nibName: String?, bundle: Bundle?, presenter: CardTransactionsSearchPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setDelegates()
        self.dateFilterView.configureTextFields()
        self.presenter.viewDidLoad()
        self.setAccessibilityIdentifiers()
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
    
    @objc func clickContinueButton(_ gesture: UITapGestureRecognizer) {
        self.presenter.applyFilters()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

// MARK: - Private

private extension CardTransactionsSearchViewController {
    func setDelegates() {
        operationTypeView.delegate = self
        dateFilterView.delegate = self
    }
    
    func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.skyGray
        applyButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        applyButton.setTitle(localized("generic_button_apply"), for: .normal)
        applyButton.addSelectorAction(target: self, #selector(clickContinueButton))
        applyButtonView.drawShadow(offset: (x: 0, y: -1), opacity: 1, color: .coolGray, radius: 2)
        conceptTextView.isHidden = true
        segmentedControlView.isHidden = true
        amountRangeView.isHidden = true
        operationTypeView.isHidden = true
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_search")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: self.presenter)
    }
    
    func setAccessibilityIdentifiers() {
        self.conceptTextView.accessibilityIdentifier = "cardsInputSearch"
        self.operationTypeView.accessibilityIdentifier = "cardsDropdownOperationType"
        self.applyButton.accessibilityIdentifier = "cardsButtonApply"
    }
}

// MARK: - ViewProtocol

extension CardTransactionsSearchViewController: CardTransactionsSearchViewProtocol {
    func addConcept(title: String, textFieldTitle: String, textSelected: String?) {
        self.conceptTextView.isHidden = false
        self.conceptTextView.setupTitles(viewTitle: title, textfieldTitle: textFieldTitle)
        self.conceptTextView.setAllowedCharacters(.operative)
        self.conceptTextView.setFilterSelected(textSelected)
    }
    
    func addSegmentedControl(title: String, types: [String], itemSelected: Int) {
        segmentedControlView.isHidden = false
        self.segmentedControlView.configure(title: title, types: types, itemSelected: itemSelected)
    }
    
    func setRangeAmountFilter(fromAmount: String, toAmount: String, isColapsed: Bool) {
        amountRangeView.isHidden = false
        self.amountRangeView.set(fromAmount: fromAmount, toAmount: toAmount, isColapsed: isColapsed)
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
    
    func getFromToRange() -> (from: Decimal?, to: Decimal?) {
        return (self.amountRangeView?.fromDecimal, self.amountRangeView?.toDecimal)
    }
    
    func addDateFilter(startDateSelected: Date?, endDateSelected: Date?) {
        guard let startDateSelected = startDateSelected, let endDateSelected = endDateSelected else { return }
        self.dateFilterView.setDateSelected(startDateSelected, endDateSelected)
    }
    
    func getStartEndDates() -> (startDate: Date, endDate: Date) {
        return dateFilterView.getStartEndDates()
    }

    func getDateRangeSegmentIndex() -> Int {
        return self.dateFilterView.getSelectedIndex()
    }
    
    func setDateRangeSegmentIndex(_ index: Int) {
        self.dateFilterView.setSelectedIndex(index)
    }
    
    func getIndexMovementType() -> Int? {
        return self.segmentedControlView.getSelectedIndex()
    }
    
    func getIndexOperationType() -> Int? {
        return self.operationTypeView.getSelectedIndex()
    }
    
    func addOperationTypeFilter(title: String, types: [String], itemSelected: Int, isColapsed: Bool) {
        self.operationTypeView.isHidden = false
        self.operationTypeView.configure(viewTitle: title, textfieldOptions: types, itemSelected: itemSelected, isColapsed: isColapsed)
    }
}

extension CardTransactionsSearchViewController: DialogViewPresentationCapable {
    var associatedDialogView: UIViewController {
        return self
    }
}

extension CardTransactionsSearchViewController: OperativeFilterViewDelegate, DateFilterViewDelegate {
    func getLanguage() -> String {
        return self.presenter.getLanguage()
    }
    
    func didOpenSection(view: UIView) {
        searchScrollView.scrollRectToVisible(view.frame, animated: true)
    }
}
