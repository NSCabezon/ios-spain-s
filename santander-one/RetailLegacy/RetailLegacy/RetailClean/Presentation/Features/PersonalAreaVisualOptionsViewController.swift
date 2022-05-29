import UIKit

protocol PersonalAreaVisualOptionsPresenterProtocol: SideMenuCapable, DraggableTableViewDataSourceDelegate {
    var isSideMenuAvailable: Bool { get }
    var saveTitle: LocalizedStylableText { get }
    func saveConfiguration()
}

class PersonalAreaVisualOptionsViewController: BaseViewController<PersonalAreaVisualOptionsPresenterProtocol> {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: RedButton!
    @IBOutlet weak var separatorView: UIView!
    
    private lazy var dataSource: DraggableTableViewDataSource = {
        let dataSource = DraggableTableViewDataSource()
        dataSource.movementsDelegate = presenter
        return dataSource
    }()
    
    override class var storyboardName: String {
        return "PersonalArea"
    }
    
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
        
        saveButton.configureHighlighted(font: .latoMedium(size: 16))
        (saveButton as UIButton).set(localizedStylableText: presenter.saveTitle, state: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        separatorView.backgroundColor = .lisboaGray
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.enableUserInteraction()
    }

    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    func addSections(_ sections: [TableModelViewSection], completion: (() -> Void)? = nil) {
        dataSource.addSections(sections)
        tableView.reloadData {
            completion?()
        }
    }
    
    @objc func savePressed() {
        presenter.saveConfiguration()
    }
    
    func disableUserInteraction() {
        self.navigationController?.parent?.view.isUserInteractionEnabled = false
    }
    
    func enableUserInteraction() {
        self.navigationController?.parent?.view.isUserInteractionEnabled = true
    }
}

extension PersonalAreaVisualOptionsViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
