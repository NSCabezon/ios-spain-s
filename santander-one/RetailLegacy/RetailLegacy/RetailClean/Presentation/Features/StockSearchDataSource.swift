//

import UIKit

class StockSearchDataSource: TableDataSource {
    
    private unowned let tableView: UITableView
    private let sectionSearch = TableModelViewSection()
    private let searchIndex: Int = 0
    private let sectionEmpty = TableModelViewSection()
    private let emptyIndex: Int = 1
    private let sectionQuotes = TableModelViewSection()
    private let quotesIndex: Int = 2
    private let sectionPagination = TableModelViewSection()
    private let paginationIndex: Int = 3
    private var isLoading: Bool {
        return !sectionSearch.items.isEmpty
    }
    private var isPaging: Bool {
        return !sectionPagination.items.isEmpty
    }
    private var isEmpty: Bool {
        return !sectionEmpty.items.isEmpty
    }

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        addSections([sectionSearch, sectionEmpty, sectionQuotes, sectionPagination])
        tableView.reloadData()
    }
    
    func validActionIndex(index: Int) -> Bool {
        return index == quotesIndex
    }
    
    func toTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func showLoadingSection<T>(item: TableModelViewItem<T>) {
        guard !isLoading else {
            return
        }
        sectionSearch.add(item: item)
        tableView.reloadSections([searchIndex], with: .automatic)
    }
    
    func hideLoadingSection() {
        guard isLoading else {
            return
        }
        sectionSearch.clean()
        tableView.reloadSections([searchIndex], with: .automatic)
    }
    
    func showPaginationSection<T>(item: TableModelViewItem<T>) {
        guard !isPaging else {
            return
        }
        sectionPagination.add(item: item)
        tableView.reloadSections([paginationIndex], with: .automatic)
    }
    
    func hidePaginationSection() {
        guard isPaging else {
            return
        }
        sectionPagination.clean()
        tableView.reloadSections([paginationIndex], with: .automatic)
    }
    
    func showEmptySection<T>(item: TableModelViewItem<T>) {
        guard !isEmpty else {
            return
        }
        sectionEmpty.add(item: item)
        tableView.reloadSections([emptyIndex], with: .automatic)
    }
    
    func hideEmptySection() {
        guard isEmpty else {
            return
        }
        sectionEmpty.clean()
        tableView.reloadSections([emptyIndex], with: .automatic)
    }
    
    func replaceQuotesSection<T>(section: [TableModelViewItem<T>]) {
        sectionQuotes.clean()
        sectionQuotes.addAll(items: section)
        tableView.reloadSections([quotesIndex], with: .automatic)
    }
    
    func insertQuotesSection<T>(section: [TableModelViewItem<T>]) {
        let countSection = section.count
        guard countSection > 0 else {
            return
        }
        let count = sectionQuotes.rowsCount
        var newRows: [IndexPath] = []
        for i in count..<count + countSection {
            newRows.append(IndexPath(row: i, section: quotesIndex))
        }
        tableView.beginUpdates()
        sectionQuotes.addAll(items: section)
        tableView.insertRows(at: newRows, with: .automatic)
        tableView.endUpdates()
    }
    
    func reloadQuoteIndex(index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: quotesIndex)], with: .automatic)
    }
}
