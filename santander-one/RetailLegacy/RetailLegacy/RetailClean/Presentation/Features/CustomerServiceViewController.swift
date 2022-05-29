import UIKit
import MessageUI

class CustomerServiceViewController: BaseViewController<CustomerServicePresenterProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    var sections: [TableModelViewSection] {
        return dataSource.sections
    }
    
    override class var storyboardName: String {
        return "CustomerService"
    }
    
    override func prepareView() {
        tableView.backgroundColor = .uiBackground
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 27.0
        tableView.estimatedRowHeight = 68.0
        tableView.estimatedSectionFooterHeight = 0
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        tableView.registerCells(["PhoneTableViewCell", "WhatsAppTableViewCell", "GenericTextIconTableViewCell", "IconButtonsTableViewCell"])
        tableView.registerHeaderFooters(["CustomerServiceTitleHeaderView"])
        title = presenter.title
        
        let colors: [UIColor] = [.white]
        let vector = (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        navigationController?.navigationBar.setGradientBackground(colors: colors, vector: vector)
    }
    
    func loadSections(_ sections: [TableModelViewSection], completion: (() -> Void)? = nil) {
        dataSource.addSections(sections)
        tableView.reloadData {
            completion?()
        }
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

// MARK: - RootMenuController
extension CustomerServiceViewController: RootMenuController {
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

extension CustomerServiceViewController: ToolTipDisplayer {}

extension CustomerServiceViewController: TableDataSourceDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelect(indexPath)
    }
}
