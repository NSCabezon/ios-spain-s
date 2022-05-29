//
//  ExpensesIncomeCategoriesView.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 9/6/21.
//

import CoreFoundationLib
import UI

protocol ExpensesIncomeCategoriesDelegate: AnyObject {
    func didSelectSegmentType(_ type: ExpensesIncomeCategoriesView.AnalysisCategoryType)
    func expensesIncomeListDidExpand(_ expensesIncomeListView: ExpensesIncomeListView, scrollHeight: CGFloat)
    func expensesIncomeList(_ expensesIncomeListView: ExpensesIncomeListView, didSelectCategory category: ExpensesIncomeCategoryType, chartType: ExpensesIncomeCategoriesChartType)
    func categoryChartsDidSwipeWith(chartType: ExpensesIncomeCategoriesChartType)
}

final class ExpensesIncomeCategoriesView: XibView {
        
    public enum AnalysisCategoryType: Int {
        case expenses = 0
        case income = 1
    }
    
    @IBOutlet private weak var headerTitle: UILabel!
    @IBOutlet private weak var segmentedControlContainer: UIView!
    @IBOutlet private weak var segmentedControl: LisboaSegmentedControl!
    @IBOutlet private weak var chartContainer: ExpensesIncomeCategoriesCharts!
    @IBOutlet private weak var listContainer: ExpensesIncomeListView!
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: ExpensesIncomeCategoriesDelegate?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    @IBAction func segmentedDidChange(_ sender: LisboaSegmentedControl) {
        guard let type = AnalysisCategoryType(rawValue: sender.selectedSegmentIndex) else { return }
        self.delegate?.didSelectSegmentType(type)
        self.chartContainer.didSelectAnalysisCategoryType(type)
    }
}

private extension ExpensesIncomeCategoriesView {
    func setupUI() {
        self.headerTitle.font = .santander(family: .text, type: .regular, size: 22)
        self.headerTitle.configureText(withKey: "analysis_label_categoriesTitle")
        self.segmentedControlContainer.backgroundColor = .skyGray
        self.segmentedControl.setup(
            with: ["analysis_label_expenses", "analysis_label_income"],
            accessibilityIdentifiers: nil,
            withStyle: .financingSegmentedControlStyle
        )
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        self.stackView.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.chartContainer.delegate = self
        self.chartContainer.didUpdateData(ExpensesIncomeCategoriesViewModel())
        self.listContainer.delegate = self
    }
}

extension ExpensesIncomeCategoriesView: ExpensesIncomeListViewDelegate {
    func expensesIncomeListDidExpand(_ expensesIncomeListView: ExpensesIncomeListView, scrollHeight: CGFloat) {
        self.delegate?.expensesIncomeListDidExpand(expensesIncomeListView, scrollHeight: scrollHeight)
    }
    func expensesIncomeList(_ expensesIncomeListView: ExpensesIncomeListView, didSelectCategory category: ExpensesIncomeCategoryType) {
        self.delegate?.expensesIncomeList(expensesIncomeListView, didSelectCategory: category, chartType: self.chartContainer.getCurrentChartType())
    }
}

extension ExpensesIncomeCategoriesView: ExpensesIncomeCategoriesChartsDelegate {
    func didSelectCategory() { }
    
    func didShowChart(with type: AnalysisCategoryType, and viewModel: ExpensesIncomeCategoriesViewModel?, chartType: ExpensesIncomeCategoriesChartType) {
        guard let viewModel = viewModel else { return }
        let items: [ExpenseIncomeCategoriesCellViewModel] = ExpenseIncomeCategoriesCellViewModel.parseExpensesIncomeCategoriesViewModel(viewModel, type: chartType)
        var otherItems: [ExpenseIncomeCategoriesCellViewModel] = []
        for (index, item) in viewModel.getOtherSectorData().enumerated() {
            let isFirst = index == 0
            otherItems.append(
                ExpenseIncomeCategoriesCellViewModel(
                    category: ExpensesIncomeCategoryType(rawValue: item.category)!,
                    percentage: item.value.asFinancialAgregatorPercentText(includePercentSimbol: false),
                    amount: item.rawValue, numberOfMovements: index, type: .otherExpanded, isExpanded: false,
                    isFirstOther: isFirst)
            )
        }
        self.listContainer.set(items: items, otherItems: otherItems)
    }
    
    func categoryChartsDidSwipeWith(chartType: ExpensesIncomeCategoriesChartType) {
        self.delegate?.categoryChartsDidSwipeWith(chartType: chartType)
    }
}
