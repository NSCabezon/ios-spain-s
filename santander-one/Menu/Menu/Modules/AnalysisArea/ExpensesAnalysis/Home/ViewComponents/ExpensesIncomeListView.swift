//
//  ExpensesIncomeListView.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 29/6/21.
//

import UIKit

protocol ExpensesIncomeListViewDelegate: AnyObject {
    func expensesIncomeListDidExpand(_ expensesIncomeListView: ExpensesIncomeListView, scrollHeight: CGFloat)
    func expensesIncomeList(_ expensesIncomeListView: ExpensesIncomeListView, didSelectCategory category: ExpensesIncomeCategoryType)
}

final class ExpensesIncomeListView: UIView {
    
    private var tableView: UITableView!
    private let cellHeight: CGFloat = 69
    private var items: [ExpenseIncomeCategoriesCellViewModel] = []
    private var otherItems: [ExpenseIncomeCategoriesCellViewModel] = []
    private var totalItems: [ExpenseIncomeCategoriesCellViewModel] = [] {
        didSet {
            let height = tableView.constraints.first(where: { $0.firstAttribute == .height && $0.firstAnchor == tableView.heightAnchor })
            height?.constant = cellHeight * CGFloat(totalItems.count)
            self.tableView.reloadData()
            if self.isExpanded {
                delegate?.expensesIncomeListDidExpand(self, scrollHeight: cellHeight * CGFloat(otherItems.count))
            }
        }
    }
    private var isExpanded: Bool = false {
        didSet {
            self.totalItems = self.isExpanded ? self.items + self.otherItems : self.items
        }
    }
    weak var delegate: ExpensesIncomeListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func set(items: [ExpenseIncomeCategoriesCellViewModel], otherItems: [ExpenseIncomeCategoriesCellViewModel]) {
        self.isExpanded = false
        self.items = items
        self.otherItems = otherItems.map { ExpenseIncomeCategoriesCellViewModel(category: $0.category, percentage: $0.percentage, amount: $0.amount, numberOfMovements: $0.numberOfMovements, type: .otherExpanded, isExpanded: $0.isExpanded) }
        if self.otherItems.count > 0 {
            self.otherItems[0].isFirstOther = true
        }
        self.totalItems = items
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.separatorStyle = .none
    }
}

private extension ExpensesIncomeListView {
    func commonInit() {
        self.tableView = UITableView()
        self.fullFit()
        self.addSubview(self.tableView)
        self.tableView.fullFit()
        self.tableView.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
        self.setupTableView()
    }
    
    func setupTableView() {
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: "CategoriesListCell", bundle: .module), forCellReuseIdentifier: "CategoriesListCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

extension ExpensesIncomeListView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesListCell", for: indexPath) as? CategoriesListCell else { return CategoriesListCell() }
        cell.setupWith(viewModel: self.totalItems[indexPath.item])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item < items.count {
            var item = items[indexPath.item]
            if item.shouldExpand {
                item.isExpanded = !item.isExpanded
                items[indexPath.item] = item
                self.isExpanded = !self.isExpanded
            } else {
                delegate?.expensesIncomeList(self, didSelectCategory: item.category)
            }
        } else {
            delegate?.expensesIncomeList(self, didSelectCategory: totalItems[indexPath.item].category)
        }
    }
}
