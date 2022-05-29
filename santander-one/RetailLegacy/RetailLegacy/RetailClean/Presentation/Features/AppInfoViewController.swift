import UIKit

protocol AppInfoPresenterProtocol: SideMenuCapable {
}

class AppInfoViewController: BaseViewController<AppInfoPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    
    override class var storyboardName: String {
        return "PersonalArea"
    }
    
    var sections: [TableModelViewSection] {
        set {
            dataSource.addSections(newValue)
            tableView.reloadData()
        }
        get {
            return dataSource.sections
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        
        tableView.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["ChangeLogIconViewCellItem", "ChangeLogVersionViewCellItem", "ChangeLogFirstViewCellItem", "ChangeLogViewCellItem"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

// MARK: - RootMenuController
extension AppInfoViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
