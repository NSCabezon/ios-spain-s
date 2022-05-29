import UIKit

protocol VariableIncomePresenterProtocol: Presenter, SideMenuCapable {
    func didSelect(section: TableModelViewSection, indexRow: Int)
}

class VariableIncomeViewController: BaseViewController<VariableIncomePresenterProtocol>, MultiTableViewSectionsDelegate {
    
    override class var storyboardName: String {
        return "GlobalPosition"
    }
    
    private lazy var dataSource: GenericDataSource = {
        let datasource = GenericDataSource()
        datasource.delegate = self
        return datasource
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func prepareView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        registerCells()
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    func addSections(_ sections: [TableModelViewSection]) {
        sections.forEach { (section) in
            section.getHeader()?.setTableModelViewHeaderDelegate(mDelegate: self)
        }
        dataSource.tableView(tableView, addElements: sections)
    }
    
    func removeAllSections() {
        dataSource.clean(tableView)
    }
    
    func updateTable() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func updateTableAndScrollTo(section: TableModelViewSection, toTop: Bool) {
        dataSource.tableView(tableView, reloadSection: section)
        if toTop {
            tableView.scrollRectToVisible(.zero, animated: true)
        } else {
            dataSource.tableView(tableView, scrollToSection: section, at: .bottom)
        }
    }
    
    @objc func didSelectRowsAt(section: TableModelViewSection, indexRow: Int) {
        presenter.didSelect(section: section, indexRow: indexRow)
    }
    
    // MARK: - Events
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    fileprivate func registerCells() {
        let identifiers = ["ItemProductGenericViewCell", "EmptyViewCell"]
        dataSource.registerCells(cellsIdentifiers: identifiers, in: tableView)
        dataSource.registerHeaders(headersIdentifiers: ["ProductGenericViewHeader"], in: tableView)
    }   
}

extension VariableIncomeViewController: TableModelViewHeaderDelegate {
    func onTableModelViewHeaderSelected(section: TableModelViewSection) {
        dataSource.tableView(tableView, didSelectHeaderSection: section)
    }
}
