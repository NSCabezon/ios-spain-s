//
//  CategoriesListView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 10/1/22.
//

import Foundation
import UI
import UIKit
import UIOneComponents
import OpenCombine
import CoreFoundationLib
import CoreDomain

private enum Constants {
    static let estimatedRowHeight: CGFloat = 92
}

enum Identifiers {
    static let categoriesCell = "CategoriesTableViewCell"
    static let otherSpendsCell = "OtherSpendsTableViewCell"
}

protocol CategoriesListViewRepresentable {
    var categoryzation: AnalysisAreaCategorization { get }
    var categories: [CategoryRepresentable] { get }
}

final class CategoriesListView: XibView {
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    private var subject = PassthroughSubject<CategoryRepresentable, Never>()
    public var publisher: AnyPublisher<CategoryRepresentable, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var subscriptions: Set<AnyCancellable> = []
    private var cellTypesInfo = [CategoryRepresentable]()
    private var allListedCategories = [CategoryRepresentable]()
    private var otherCellTypesInfo = [CategoryRepresentable]()
    private var othersSpendsIsExpanded = false
    private var typeOfCategories: AnalysisAreaCategorization = .expenses {
        didSet {
            setTitleLabel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableViewHeight.constant = tableView.contentSize.height
    }
    
    func setCategoriesListInfo(summary: AnalysisAreaCategoriesRepresentable) {
        typeOfCategories = summary.categorization
        cellTypesInfo.removeAll()
        otherCellTypesInfo.removeAll()
        subscriptions.removeAll()
        allListedCategories.removeAll()
        allListedCategories.append(contentsOf: summary.listCategories)
        cellTypesInfo.append(contentsOf: summary.nonOtherCategories)
        otherCellTypesInfo.append(contentsOf: summary.otherCategories)
        othersSpendsIsExpanded = false
        titleLabel.isHidden = summary.chartCategories.isEmpty
        tableView.isHidden = summary.chartCategories.isEmpty
        reloadTableView()
    }
}

private extension CategoriesListView {
    
    func setupView() {
        setupList()
    }
    
    func setupList() {
        titleLabel.font = .typography(fontName: .oneH200Bold)
        setTitleLabel()
        setupCategoriesTableView()
        setAccessibilityIdentifiers()
    }
    
    func setTitleLabel() {
        switch typeOfCategories {
        case .expenses:
            titleLabel.text = localized("analysis_label_categoriesExpenses")
        case .payments:
            titleLabel.text = localized("analysis_label_categoriesPayments")
        case .incomes:
            titleLabel.text = localized("analysis_label_categoriesIncome")
        }
    }
    
    func setupCategoriesTableView() {
        tableView.bounces = false
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        registerCells()
    }
    
    func registerCells() {
        let cellCategoriesNib = UINib(nibName: Identifiers.categoriesCell, bundle: .module)
        let cellOtherSpendsNib = UINib(nibName: Identifiers.otherSpendsCell, bundle: .module)
        tableView.register(cellCategoriesNib, forCellReuseIdentifier: Identifiers.categoriesCell)
        tableView.register(cellOtherSpendsNib, forCellReuseIdentifier: Identifiers.otherSpendsCell)
    }
    
    func setupCell(_ info: CategoryRepresentable, tableView: UITableView, cell: inout UITableViewCell) {
        guard case let .otherExpenses = info.type else {
            let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Identifiers.categoriesCell) as? CategoriesTableViewCell
            dequeuedCell?.setCellInfo(info)
            cell = dequeuedCell ?? UITableViewCell()
            return 
        }
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Identifiers.otherSpendsCell) as? OtherSpendsTableViewCell
        dequeuedCell?.setCellInfo(otherCellTypesInfo, isExpanded: othersSpendsIsExpanded)
        bindOtherSpendsCellView(cell: dequeuedCell)
        cell = dequeuedCell ?? UITableViewCell()
    }
    
    func reloadTableView() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height
        contentView.layoutSubviews()
        tableView.layoutIfNeeded()
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisLabelCategoriesExpenses
    }
    
    func bindOtherSpendsCellView(cell: OtherSpendsTableViewCell?) {
        bindDidTapExpanded(cell)
        bindDidSelectCategory(cell)
    }
    
    func bindDidTapExpanded(_ cell: OtherSpendsTableViewCell?) {
        cell?
            .publisher
            .case(OtherSpendsTableViewCellState.didTapExpanded)
            .sink { [unowned self] _ in
                didTapExpanded()
            }.store(in: &subscriptions)
    }
    
    func bindDidSelectCategory(_ cell: OtherSpendsTableViewCell?) {
        cell?
            .publisher
            .case { OtherSpendsTableViewCellState.didSelectCategory }
            .sink { [unowned self] category in
                subject.send(category)
            }.store(in: &subscriptions)
    }
    
    func didTapExpanded() {
        othersSpendsIsExpanded.toggle()
        let indexPath = IndexPath(row: allListedCategories.count - 1, section: 0)
        guard var cell = tableView.cellForRow(at: indexPath) as? OtherSpendsTableViewCell else {
            return
          }
        let categoryCellTypeInfo = self.allListedCategories[indexPath.row]
        if case .otherExpenses = categoryCellTypeInfo.type {
            cell.setExpanedCategories(isExpanded: othersSpendsIsExpanded)
        }
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        } completion: { _ in
            self.tableViewHeight.constant = self.tableView.contentSize.height
            self.contentView.layoutSubviews()
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

extension CategoriesListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allListedCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = self.allListedCategories[indexPath.row]
        var cell = UITableViewCell()
        setupCell(category, tableView: tableView, cell: &cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = allListedCategories[indexPath.row]
        switch info.type {
        case .otherExpenses:
            return
        default:
            subject.send(info)
        }
    }
}

struct CategoryTrackInfo {
    let itemID: String
    let type: AnalysisAreaCategorization
}
