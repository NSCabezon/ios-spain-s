//

import UIKit
import MessageUI
import CoreFoundationLib

let profileSection = "PersonalManagerProfileViewCell"
let callSection = "PersonalManagerCallViewCell"
let defaultSection = "PersonalManagerDefaultViewCell"
let opinatorSection = "PersonalManagerOpinatorViewCell"

protocol OfficeWithManagerPresenterProtocol {
    var managersSections: [TableModelViewSection] { get }
    var managers: [Manager] { get }
    func sendMail(at index: Int)
    func dateWithManager()

    func startChat()
    func startViewCall()
    func phoneButtonWasTapped(index: Int)
}

class OfficeWithManagerViewController: BaseViewController<OfficeWithManagerPresenterProtocol>, TableDataSourceDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override class var storyboardName: String {
        return "PersonalManager"
    }
    lazy private var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()

    override func prepareView() {
        super.prepareView()
        
        tableView.register(UINib(nibName: "PersonalManagerProfileViewCell", bundle: .module), forCellReuseIdentifier: profileSection)
        tableView.register(UINib(nibName: "PersonalManagerCallViewCell", bundle: .module), forCellReuseIdentifier: callSection)
        tableView.register(UINib(nibName: "PersonalManagerDefaultViewCell", bundle: .module), forCellReuseIdentifier: defaultSection)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
    }
    
    func reloadData() {
        dataSource.addSections(presenter.managersSections)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RetailLogger.d(logTag, "Selected \(indexPath)")
    }
}

extension OfficeWithManagerViewController: ManagerProfileProtocol {}

extension OfficeWithManagerViewController: PersonalManagerCallViewDelegate {
    func phoneButtonDidTouched(at index: Int) {
        presenter.phoneButtonWasTapped(index: index)
    }
}

extension OfficeWithManagerViewController: PersonalManagerDefaultDelegate {
    func mailButtonDidTouched(at index: Int) {
        presenter.sendMail(at: index)
    }
    
    func dateButtonDidTouched(at index: Int) {
        presenter.dateWithManager()
    }
    
    func chatButtonDidTouched(at index: Int) {
        presenter.startChat()
    }
    
    func videoCallButtonDidTouched(at index: Int) {
        presenter.startViewCall()
    }
}
