//

import UIKit

protocol CustomizeAppPresenterProtocol: SideMenuCapable {
    func selected(indexPath: IndexPath)
}

class CustomizeAppViewController: BaseViewController<CustomizeAppPresenterProtocol> {
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
        dataSource.delegate = self
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        navigationController?.navigationBar.tintColor = .santanderRed
        navigationController?.navigationBar.isTranslucent = false
        tableView.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 60.0
        tableView.estimatedRowHeight = 68.0
        tableView.estimatedSectionFooterHeight = 0
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["PersonalAreaOneLineTableViewCell", "CustomizeAppSwitchAndToolTipTableCell", "CustomizeAppToolTipTableCell"])
        tableView.registerHeaderFooters(["SettingsTitleHeaderView"])
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

// MARK: - RootMenuController

extension CustomizeAppViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}

// MARK: - TableDataSourceDelegate

extension CustomizeAppViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(indexPath: indexPath)
        if let switchCell = tableView.cellForRow(at: indexPath) as? PersonalAreaSwitchTableCell {
            switchCell.updateSwitchValue()
        }
    }
}

// MARK: - ToolTipBackView

extension CustomizeAppViewController: ToolTipBackView {}
