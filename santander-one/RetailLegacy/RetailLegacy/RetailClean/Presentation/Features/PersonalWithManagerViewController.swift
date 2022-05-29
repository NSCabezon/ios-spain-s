//

import UIKit
import MessageUI
import CoreFoundationLib

protocol PersonalWithManagerPresenterProtocol {
    var managersSections: [TableModelViewSection] { get }
    var managers: [Manager] { get }
    func sendMail(at index: Int)
    func startChat()
    func startVideoCall()
    func opinatorTouched()

    func startDate()
    func phoneButtonWasTapped(index: Int)
}

class PersonalWithManagerViewController: BaseViewController<PersonalWithManagerPresenterProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource = TableDataSource()
    
    override class var storyboardName: String {
        return "PersonalManager"
    }
    
    override func prepareView() {
        super.prepareView()
        
        tableView.register(UINib(nibName: "PersonalManagerProfileViewCell", bundle: .module), forCellReuseIdentifier: profileSection)
        tableView.register(UINib(nibName: "PersonalManagerCallViewCell", bundle: .module), forCellReuseIdentifier: callSection)
        tableView.register(UINib(nibName: "PersonalManagerDefaultViewCell", bundle: .module), forCellReuseIdentifier: defaultSection)
        tableView.register(UINib(nibName: "PersonalManagerOpinatorViewCell", bundle: .module), forCellReuseIdentifier: opinatorSection)
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
}

extension PersonalWithManagerViewController: PersonalManagerCallViewDelegate {
    func phoneButtonDidTouched(at index: Int) {
        presenter.phoneButtonWasTapped(index: index)
    }
}

extension PersonalWithManagerViewController: PersonalManagerDefaultDelegate {
    func mailButtonDidTouched(at index: Int) {
        presenter.sendMail(at: index)
    }
    
    func dateButtonDidTouched(at index: Int) {
        presenter.startDate()
    }
    
    func chatButtonDidTouched(at index: Int) {
        presenter.startChat()
    }
    
    func videoCallButtonDidTouched(at index: Int) {
        presenter.startVideoCall()
    }
}

extension PersonalWithManagerViewController: PersonalManagerOpinatorViewDelegate {
    func opinatorButtonDidTouched() {        
        presenter.opinatorTouched()
    }
    
}

extension PersonalWithManagerViewController: ManagerProfileProtocol {}
