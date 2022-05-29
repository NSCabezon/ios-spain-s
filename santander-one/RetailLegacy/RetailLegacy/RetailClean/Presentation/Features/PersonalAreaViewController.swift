import UIKit
import CoreFoundationLib
import UI

protocol PersonalAreaPresenterProtocol: SideMenuCapable {
    var isSideMenuAvailable: Bool { get }
    func selected(indexPath: IndexPath)
    func reloadWhenComingBack()
}

class PersonalAreaViewController: BaseViewController<PersonalAreaPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    
    override class var storyboardName: String {
        return "PersonalArea"
    }
    
    func resetTableView() {
        dataSource.clearSections()
        tableView.reloadData()
    }
    
    func reloadSections() {
        tableView.reloadData()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isMovingToParent {
            presenter.reloadWhenComingBack()
        }
    }
    
    override func prepareView() {
        navigationController?.navigationBar.tintColor = .uiWhite
        navigationController?.navigationBar.isTranslucent = false
        
        tableView.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 60.0
        tableView.estimatedRowHeight = 68.0
        tableView.estimatedSectionFooterHeight = 0
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["PersonalAreaOneLineTableViewCell", "PersonalAreaLinkTableCell", "PersonalAreaSwitchTableCell", "PersonalAreaCMCStatusTableCell", "PersonalAreaIconedTableCell"])
        tableView.registerHeaderFooters(["SettingsTitleHeaderView"])
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    var footPrint: String {
        return UIDevice.current.getFootPrint()
    }
    var deviceName: String {
        return UIDevice.current.getDeviceName()
    }
}

// MARK: - RootMenuController
extension PersonalAreaViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
    
    func showCloseSessionDialog(_ confirmation: @escaping () -> Void) {
        let cancelComponents = DialogButtonComponents(titled: localized(key: "generic_link_no"), does: nil)
        
        let acceptAction = confirmation
        let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_link_yes"), does: acceptAction)
        Dialog.alert(title: nil, body: localized(key: "logout_popup_confirm"), withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: self)
    }
}

extension PersonalAreaViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
}

extension PersonalAreaViewController: ToolTipBackView {}
