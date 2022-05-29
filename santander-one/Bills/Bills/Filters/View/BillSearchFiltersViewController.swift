//
//  BillSearchFiltersViewController.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/17/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol BillSearchFilterViewProtocol: AnyObject {
    func setAccountFilter(_ viewModel: FilterViewModel)
    func setDateFilter(_ viewModel: FilterViewModel)
    func setBillStatusFilter(_ viewModel: FilterViewModel)
}

class BillSearchFiltersViewController: UIViewController {
    private let defaultCustomRangeIndex = 2
    private let undefiniedSelectionRangeIndex = -1
    private let presenter: BillSearchFiltersPresenterProtocol!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var applyButton: WhiteLisboaButton!
    @IBOutlet weak var applyViewContainer: UIView!
    private let scrollableStackView = ScrollableStackView()
    private let nameFilterView = NameFilterView()
    private let dateFilterView = DateFilterView()
    private let operativeFilterView = OperativeFilterView()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: BillSearchFiltersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

private extension BillSearchFiltersViewController {
    func setupViews() {
        self.addFilterViews()
        self.setAppearance()
        self.nameFilterView.setup()
        self.operativeFilterView.setAlwaysExpanded()
        self.nameFilterView.disableTextFieldEditing()
        self.nameFilterView.setRightView(EditAccountView())
        self.nameFilterView.addAction(didSelectChangeAccount)
        self.nameFilterView.addRightViewAction({ [weak self] in self?.didSelectChangeAccount() })
        self.dateFilterView.delegate = self
        self.dateFilterView.configureTextFields()
        self.dateFilterView.addInfoToolTip({[weak self] view in self?.didSelectDateToolTip(view) })
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky, title: .title(key: "toolbar_title_searchReceipts"))
            .setRightActions(.close(action: #selector(dismissViewController)))
            .setLeftAction(.back(action: #selector(dismissViewController)))
        builder.build(on: self, with: self.presenter)
    }
    
    func addFilterViews() {
        self.scrollableStackView.setup(with: viewContainer)
        self.scrollableStackView.addArrangedSubview(nameFilterView)
        self.addViewDividerToScrollView()
        self.scrollableStackView.addArrangedSubview(dateFilterView)
        self.addViewDividerToScrollView()
        self.scrollableStackView.addArrangedSubview(operativeFilterView)
    }
    
    func setAppearance() {
        self.view.backgroundColor = UIColor.skyGray
        self.applyButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.applyButton.setTitle(localized("generic_button_apply"), for: .normal)
        self.applyButton.addSelectorAction(target: self, #selector(didSelectApplyFilters))
        self.applyViewContainer.drawShadow(offset: (x: 0, y: -1), opacity: 1, color: .coolGray, radius: 2)
    }
    
    func addViewDividerToScrollView() {
        let divider = UIView()
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.backgroundColor = .mediumSkyGray
        self.scrollableStackView.addArrangedSubview(divider)
    }
    
    @objc
    func didSelectApplyFilters() {
        let dateRange = dateFilterView.getStartEndDates()
        let dateRangeIndex = self.dateFilterView.getSelectedIndex()
        let statusIndex = self.operativeFilterView.getSelectedIndex() ?? 0
        self.presenter.didSelectDateRange(at: dateRangeIndex)
        self.presenter.didSelectStartDate(dateRange.startDate)
        self.presenter.didSelectEndDate(dateRange.endDate)
        self.presenter.didSelectBillStatus(at: statusIndex)
        self.presenter.didSelectApplyFilters()
    }
    
    @objc
    func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    func didSelectChangeAccount() {
        let dateRange = dateFilterView.getStartEndDates()
        let dateRangeIndex = self.dateFilterView.getSelectedIndex()
        let statusIndex = self.operativeFilterView.getSelectedIndex() ?? 0
        self.presenter.didSelectDateRange(at: dateRangeIndex)
        self.presenter.didSelectStartDate(dateRange.startDate)
        self.presenter.didSelectEndDate(dateRange.endDate)
        self.presenter.didSelectBillStatus(at: statusIndex)
        self.presenter.didSelectChangeAccount()
    }
    
    func didSelectDateToolTip(_ sender: UIView) {
        BubbleLabelView.startWith(
            associated: sender,
            text: localized("search_text_dateRangeMaxMin").text,
            position: .bottom
        )
    }
}

extension BillSearchFiltersViewController: BillSearchFilterViewProtocol {
    func setAccountFilter(_ viewModel: FilterViewModel) {
        self.nameFilterView.setTitle(viewModel.accountFilter.name)
        self.nameFilterView.setText(viewModel.accountFilter.selection)
    }
    
    func setDateFilter(_ viewModel: FilterViewModel) {
        let dateFilter = viewModel.dateFilter
        self.dateFilterView.setCustomDateRange(localizedKey: dateFilter.name, days: dateFilter.value, at: defaultCustomRangeIndex)
        self.dateFilterView.setDateSelected(dateFilter.selection.startDate, dateFilter.selection.endDate)
        self.dateFilterView.setSelectedIndex(dateFilter.selection.index == undefiniedSelectionRangeIndex ? defaultCustomRangeIndex : dateFilter.selection.index)
    }
    
    func setBillStatusFilter(_ viewModel: FilterViewModel) {
        let billStateFilter = viewModel.billStateFilter
        self.operativeFilterView.clear()
        self.operativeFilterView.configure(
            viewTitle: billStateFilter.name,
            textfieldOptions: billStateFilter.value,
            itemSelected: billStateFilter.selection,
            isColapsed: true
        )
    }
}

extension BillSearchFiltersViewController: DateFilterViewDelegate {
    func didOpenSection(view: UIView) {
        self.scrollableStackView.scrollRectToVisible(view.frame, animated: true)
    }
    
    func getLanguage() -> String {
        return self.presenter.getLanguage()

    }
}
