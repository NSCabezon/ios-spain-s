//
//  ExpensesIncomeFilterViewController.swift
//  Alamofire
//
//  Created by José María Jiménez Pérez on 5/7/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol ExpensesIncomeFilterView: AnyObject {
    func addConcept(title: String, textFieldTitle: String, textSelected: String?)
    func addSegmentedControl(title: String, types: [String], itemSelected: Int)
    func setRangeAmountFilter(fromAmount: String, toAmount: String, isColapsed: Bool)
    func getConceptText() -> String?
    func getIndexMovementType() -> Int?
    func getFromAmount() -> Decimal?
    func getToAmount() -> Decimal?
    func showDialog(titleKey: String, descriptionKey: String, acceptAction: String)
}

class ExpensesIncomeFilterViewController: UIViewController {

    let presenter: ExpensesIncomeFilterPresenterProtocol
    @IBOutlet private weak var conceptTextView: NameFilterView!
    @IBOutlet private weak var segmentedControlView: SegmentedControlFilterView!
    @IBOutlet private weak var amountRangeView: AmountRangeFilterView!
    @IBOutlet private weak var applyButton: WhiteLisboaButton!
    
    init(presenter: ExpensesIncomeFilterPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "ExpensesIncomeFilterViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.hideKeyboardWhenTappedAround()
    }
}

private extension ExpensesIncomeFilterViewController {
    func setupUI() {
        applyButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        applyButton.setTitle(localized("generic_button_apply"), for: .normal)
        applyButton.addSelectorAction(target: self, #selector(didTapApply))
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
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func didTapApply() {
        self.presenter.didSelectApply()
    }
    
    @objc func hideKeyboard() {
        view?.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }
}

extension ExpensesIncomeFilterViewController: ExpensesIncomeFilterView {
    func addConcept(title: String, textFieldTitle: String, textSelected: String?) {
        self.conceptTextView.setupTitles(viewTitle: title, textfieldTitle: textFieldTitle)
        self.conceptTextView.setFilterSelected(textSelected)
    }
    
    func addSegmentedControl(title: String, types: [String], itemSelected: Int) {
        self.segmentedControlView.configure(title: title, types: types, itemSelected: itemSelected)
    }
    
    func setRangeAmountFilter(fromAmount: String, toAmount: String, isColapsed: Bool) {
        self.amountRangeView.set(fromAmount: fromAmount, toAmount: toAmount, isColapsed: isColapsed)
    }
    
    func getConceptText() -> String? {
        return conceptTextView.text
    }
    
    func getIndexMovementType() -> Int? {
        return segmentedControlView.getSelectedIndex()
    }
    
    func getFromAmount() -> Decimal? {
        return self.amountRangeView.fromDecimal
    }
    
    func getToAmount() -> Decimal? {
        return self.amountRangeView.toDecimal
    }
    
    func showDialog(titleKey: String, descriptionKey: String, acceptAction: String) {
        self.showOldDialog(title: localized(titleKey), description: localized(descriptionKey), acceptAction: DialogButtonComponents(titled: localized(acceptAction), does: nil), cancelAction: nil, isCloseOptionAvailable: false)
    }
}

extension ExpensesIncomeFilterViewController: OldDialogViewPresentationCapable { }
