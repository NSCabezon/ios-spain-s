import UIKit
import CoreFoundationLib
import CoreDomain

protocol ServicesForYouPresenterProtocol: Presenter, SideMenuCapable {
    func actionSelectedCell(index: Int)
}

final class ServicesForYouViewController: BaseViewController<ServicesForYouPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    
    override class var storyboardName: String {
        return "ServicesForYou"
    }
    
    var sections: [TableModelViewSection] {
        set {
            dataSource.clearSections()
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
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    override func prepareView() {        
        view.backgroundColor = .sanGreyLight
        tableView.separatorStyle = .none
        tableView.backgroundColor = .uiWhite
        tableView.registerCells(["ImageTableViewCell", "ItemTableViewCell", "OperativeSeparatorTableViewCell"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    func calculateHeight() {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }        
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

extension ServicesForYouViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.actionSelectedCell(index: indexPath.row)
    }
}

extension ServicesForYouViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}

extension ServicesForYouViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return .otherServices
    }
}
