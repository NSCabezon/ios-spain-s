import UIKit
import CoreFoundationLib

protocol TipsPresenterProtocol: SideMenuCapable, Presenter {
    func selectedItem(index: Int)
}

class TipsViewController: BaseViewController<TipsPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    override class var storyboardName: String {
        return "Tips"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 16, right: 0)
        tableView.separatorStyle = .none
        tableView.registerCells(["TipTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 111
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    func setSection(_ section: TableModelViewSection) {
        dataSource.clearSections()
        dataSource.addSections([section])
        tableView.reloadData()
    }
}
// MARK: - RootMenuController

extension TipsViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}

// MARK: - TableDataSourceDelegate

extension TipsViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectedItem(index: indexPath.row)
    }
}
