import UIKit
protocol PersonalWithoutManagerPresenterProtocol {
    var title: LocalizedStylableText { get }
    var subtitle: LocalizedStylableText { get }
    var signUpTitlebutton: LocalizedStylableText { get }
    var requirementsTitle: LocalizedStylableText { get }
    var offersTitle: LocalizedStylableText { get }
    func onSubmitClick()
}

protocol PersonalWithoutManagerViewControllerDelegate: class {
    func signUpDidTouch()
}

class PersonalWithoutManagerViewController: BaseViewController<PersonalWithoutManagerPresenterProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: RedButton!
    
    weak var delegate: PersonalWithoutManagerViewControllerDelegate?
    
    let dataSource = TableDataSource()
    
    override class var storyboardName: String {
        return "PersonalManager"
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiWhite
        
        tableView.register(UINib(nibName: "PersonalWithoutManagerSectionTitleViewCell", bundle: .module), forCellReuseIdentifier: "PersonalWithoutManagerSectionTitleViewCell")
        tableView.register(UINib(nibName: "PersonalWithoutManagerTitleViewCell", bundle: .module), forCellReuseIdentifier: "PersonalWithoutManagerTitleViewCell")
        tableView.register(UINib(nibName: "PersonalManagerRequirementViewCell", bundle: .module), forCellReuseIdentifier: "PersonalManagerRequirementViewCell")
        tableView.register(UINib(nibName: "PersonalManagerOfferViewCellWithSubtitle", bundle: .module), forCellReuseIdentifier: "PersonalManagerOfferViewCellWithSubtitle")
        tableView.register(UINib(nibName: "PersonalManagerOfferNoSubtitleViewCell", bundle: .module), forCellReuseIdentifier: "PersonalManagerOfferNoSubtitleViewCell")
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .uiWhite
        
        submitButton.configureHighlighted(font: .latoHeavy(size: 18.7))
    }
    
    func reloadData(sections: [TableModelViewSection]) {
        dataSource.addSections(sections)
        tableView.reloadData()
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        presenter.onSubmitClick()
    }
}

extension PersonalWithoutManagerViewController: ManagerProfileProtocol {}
