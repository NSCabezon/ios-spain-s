//
//  CategoriesDetailListView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 29/06/2021.
//

import UI
import CoreFoundationLib

protocol CategoriesDetailListViewDelegate: AnyObject {
    func didTapOnFilter()
}

final class CategoriesDetailListView: UIDesignableView {
    
    @IBOutlet private weak var listTableView: UITableView!
    
    private let sectionIdentifier = "DateSectionView"
    private let categoriesDetailHeaderView = CategoriesDetailHeaderView()
    private var details: [CategoriesDetailGroupViewModel] = []
    weak var delegate: CategoriesDetailListViewDelegate?

    weak var filterDelegate: CategoriesFilterDelegate?
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupTableView()
        self.setupView()
        self.categoriesDetailHeaderView.setupView()
    }
    
    func setDelegate() {
        self.categoriesDetailHeaderView.filterDelegate = self.filterDelegate
    }
    
    func setViewModel(_ viewModel: CategoriesDetailViewModel) {
        self.details = viewModel.details
        self.categoriesDetailHeaderView.setMovements(viewModel.movementsNumber)
        self.layoutIfNeeded()
        self.categoriesDetailHeaderView.setViewModel(viewModel)
        self.listTableView.reloadData()
    }
    
    func addTagContainer(withTags tags: [TagMetaData], delegate: TagsContainerViewDelegate) {
        self.categoriesDetailHeaderView.addTagContainer(withTags: tags, delegate: delegate)
    }
    
    func getHeaderView() -> CategoriesDetailHeaderView {
        return self.categoriesDetailHeaderView
    }
    
    func updateHeader() {
        self.layoutIfNeeded()
        self.listTableView.reloadData()
    }
}

private extension CategoriesDetailListView {
    func setupView() {
        self.categoriesDetailHeaderView.layoutIfNeeded()
        self.listTableView.tableHeaderView = self.categoriesDetailHeaderView
        self.listTableView.widthAnchor.constraint(equalTo: self.categoriesDetailHeaderView.widthAnchor).isActive = true
        self.listTableView.tableHeaderView?.heightAnchor.constraint(equalTo: self.categoriesDetailHeaderView.heightAnchor).isActive = true
        self.listTableView.tableHeaderView?.topAnchor.constraint(equalTo: self.listTableView.topAnchor).isActive = true
        self.listTableView.tableHeaderView?.leadingAnchor.constraint(equalTo: self.listTableView.leadingAnchor).isActive = true
        self.categoriesDetailHeaderView.delegate = self
    }
    
    func setupTableView() {
        let nib = UINib(nibName: sectionIdentifier, bundle: Bundle.uiModule)
        let detailNib = UINib(nibName: "CategoriesDetailTableViewCell", bundle: .module)
        self.listTableView.register(nib, forHeaderFooterViewReuseIdentifier: sectionIdentifier)
        self.listTableView.register(detailNib, forCellReuseIdentifier: "CategoriesDetailTableViewCell")
        self.listTableView.bounces = false
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
    }
}

extension CategoriesDetailListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifier) as? DateSectionView
        let detailDate = self.details[section].setDateFormatterFiltered(false)
        header?.configure(withDate: detailDate)
        header?.toggleHorizontalLine(toVisible: false)
        tableView.removeUnnecessaryHeaderTopPadding()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }
}

extension CategoriesDetailListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.details.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.details[section].groupedDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesDetailTableViewCell") as? CategoriesDetailTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = self.details[indexPath.section].groupedDetails[indexPath.row]
        cell.setViewModel(viewModel)
        if indexPath.section == self.details.count - 1 &&
            tableView.numberOfRows(inSection: self.details.count - 1) - 1 == indexPath.row {
            cell.hideDottedLine()
        }
        return cell
    }
}

extension CategoriesDetailListView: CategoriesDetailHeaderViewDelegate {
    func didChangeHeaderHeight() {
        self.categoriesDetailHeaderView.layoutIfNeeded()
        self.listTableView.reloadData()
    }
    
    func didTapOnFilter() {
        delegate?.didTapOnFilter()
    }
}
