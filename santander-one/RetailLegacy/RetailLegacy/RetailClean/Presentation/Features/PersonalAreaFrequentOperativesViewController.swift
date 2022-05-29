import UIKit

protocol PersonalAreaFrequentOperativesProtocol: SideMenuCapable {
    var title: String { get }
    var actionTitle: LocalizedStylableText { get }
    func saveConfiguration()
    func didMoveItem(item: TableModelViewProtocol)
}

class PersonalAreaFrequentOperativesViewController: BaseViewController<PersonalAreaFrequentOperativesProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: RedButton!
    @IBOutlet weak var separatorView: UIView!
    
    private lazy var dataSource: DraggableTableViewDataSource = {
        let dataSource = DraggableTableViewDataSource()
        dataSource.movementsDelegate = self
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "DraggableBasicTableViewCell"])
        tableView.registerHeaderFooters(["SettingsTitleHeaderView"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 68
        tableView.estimatedSectionHeaderHeight = 60.0
        tableView.estimatedSectionHeaderHeight = 40
        tableView.estimatedSectionFooterHeight = 0
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        tableView.isEditing = true
        if #available(iOS 11.0, *) {
            tableView.dragInteractionEnabled = true
        }
        
        title = presenter.title
        saveButton.set(localizedStylableText: presenter.actionTitle, state: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        separatorView.backgroundColor = .lisboaGray
    }
    
    override class var storyboardName: String {
        return "PersonalArea"
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }

    func addSections(_ sections: [TableModelViewSection]) {
        dataSource.addSections(sections)
        tableView.reloadData()
    }
    
    func refreshData() {
        tableView.reloadData()
    }
    
    @objc func savePressed() {
        presenter.saveConfiguration()
    }
}

extension PersonalAreaFrequentOperativesViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}

extension PersonalAreaFrequentOperativesViewController: DraggableTableViewDataSourceDelegate {
    func moveInSection(section: TableModelViewSection) {
    }
    
    func didMoveItem(item: TableModelViewProtocol) {
        presenter.didMoveItem(item: item)
    }
}
