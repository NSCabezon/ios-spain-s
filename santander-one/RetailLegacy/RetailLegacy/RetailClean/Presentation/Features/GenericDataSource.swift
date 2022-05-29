import UIKit

@objc protocol MultiTableViewSectionsDelegate {
    @objc optional func didSelectRowsAt(section: TableModelViewSection, indexRow: Int)
}

class GenericDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var elements = [TableModelViewSection]()
    weak var delegate: MultiTableViewSectionsDelegate?
    
    init(delegate: MultiTableViewSectionsDelegate? = nil) {
        self.delegate = delegate
    }
    
    func registerCells(cellsIdentifiers: [String], in tableView: UITableView) {
        for identifier in cellsIdentifiers {
            tableView.register(UINib(nibName: identifier, bundle: .module), forCellReuseIdentifier: identifier)
        }
    }
    
    func registerHeaders(headersIdentifiers: [String], in tableView: UITableView) {
        for identifier in headersIdentifiers {
            tableView.register(UINib(nibName: identifier, bundle: .module), forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
    
    func tableView(_ tableView: UITableView, addElements elements: [TableModelViewSection]) {
        self.elements = elements
        tableView.reloadData()
    }
    
    func clean(_ tableView: UITableView) {
        elements.removeAll()
        tableView.reloadData()
    }
    
    func remove(_ section: TableModelViewSection) {
        guard let index = elements.firstIndex(of: section) else {
            return
        }
        elements.remove(at: index)
    }
    
    func tableView(_ tableView: UITableView, reloadSection section: TableModelViewSection) {
        guard let index: Int = elements.firstIndex(of: section) else {
            return
        }
        tableView.reloadSections(IndexSet([index]), with: .fade)
    }
    
    func tableView(_ tableView: UITableView, reloadHeaderSection section: TableModelViewSection) {
        guard let index: Int = elements.firstIndex(of: section), let header = section.getHeader() else {
            return
        }
        if let headerView = tableView.headerView(forSection: index) as? BaseViewHeader {
            header.configure(viewHeader: headerView)
        }
    }
    
    func tableView(_ tableView: UITableView, reloadRow row: Int, inSection section: TableModelViewSection) {
        guard let index: Int = elements.firstIndex(of: section), section.items.count > 0 else {
            return
        }
        let indexPath = IndexPath(row: row, section: index)
        guard let item = elements[indexPath.section].get(indexPath.row) else {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? BaseViewCell else {
            return
        }
        item.configure(viewCell: cell)
    }
    
    func tableView(_ tableView: UITableView, scrollToSection section: TableModelViewSection, at position: UITableView.ScrollPosition) {
        guard let index: Int = elements.firstIndex(of: section) else {
            return
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: index), at: position, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionElement = elements[section]
        if sectionElement.isCollapsed {
            return 0
        }
        return sectionElement.rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var item = elements[indexPath.section].get(indexPath.row)  else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath)
        item.position = (indexPath.row, elements[indexPath.section].items.count)
        if let cell = cell as? BaseViewCell {
            cell.indexPath = indexPath
            item.bind(viewCell: cell)
            
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = elements[section]
        let header = item.getHeader()
        guard let identifier = header?.identifier else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if let headerView = headerView as? BaseViewHeader {
            header?.bind(viewHeader: headerView)
        }
        tableView.removeUnnecessaryHeaderTopPadding()

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let item = elements[section]
        let header = item.getHeader()
        
        return header?.height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = elements[indexPath.section].get(indexPath.row)
        
        return item?.height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = elements[indexPath.section]
        delegate?.didSelectRowsAt?(section: section, indexRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectHeaderSection section: TableModelViewSection) {
        guard let sectionNumber: Int = elements.firstIndex(of: section) else { return }
        if #available(iOS 11, *) {
            // nothing to do here
        } else {
            // this fixes a bug in iOS 9 & 10
            tableView.reloadData()
        }
        if section.isCollapsible, let header = section.getHeader() {
            section.isCollapsed = !section.isCollapsed
            header.setCollapsed(collapsed: section.isCollapsed)
            let totalItems = section.items.count - 1
            let indexes = (0...totalItems).map({ IndexPath(row: $0, section: sectionNumber) })
            if section.isCollapsed {
                tableView.deleteRows(at: indexes, with: .fade)
            } else {
                tableView.insertRows(at: indexes, with: .fade)
            }
            if let cell = tableView.headerView(forSection: sectionNumber) as? BaseViewHeader {
                header.bind(viewHeader: cell)
            }
            if tableView.canScroll() {
                tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: sectionNumber), at: .top, animated: true)
            } else {
                tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: true)
            }
        }
    }
    
}
