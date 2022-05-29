import UIKit
import CoreFoundationLib

protocol MobileTopUpPresenterProtocol: Presenter {
    var title: LocalizedStylableText { get }
    var titleIdentifier: String { get }
    var buttonTitle: LocalizedStylableText { get }
    var operatorsPickerCloseTitle: LocalizedStylableText { get }
    var sections: [TableModelViewSection] { get }
    func next()
}

class MobileTopUpViewController: BaseViewController<MobileTopUpPresenterProtocol> {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: RedButton!
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericHeaderViewCell", "PhoneInputTextFieldTableViewCell", "OperatorInfoTableViewCell", "AmountInputTableViewCell", "OptionsPickerTableViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        continueButton.accessibilityIdentifier = AccessibilityMobileRecharge.btnContinue.rawValue
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.buttonTitle, state: .normal)
        styledTitle = presenter.title
        titleIdentifier = presenter.titleIdentifier
        self.navigationController?.navigationBar.setNavigationBarColor(.uiWhite)
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[2].items
    }
    
    func reloadOperatorInfo() {
        tableView.reloadSections([3], with: .automatic)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        presenter.next()
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
