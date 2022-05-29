import UIKit

protocol PayOffPresenterProtocol: Presenter {
    var title: LocalizedStylableText { get }
    var buttonTitle: LocalizedStylableText { get }
    func continueButton()
}

final class PayOffViewController: BaseViewController<PayOffPresenterProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: RedButton!
    
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.accessibilityIdentifier = "PayOffBackButton"
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "OperativeLabelTableViewCell", "AmountInputTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        setAccessibilityIdentifiers()
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.buttonTitle, state: .normal)
        title = presenter.title.text
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = "payOffTittle"
        continueButton.accessibilityIdentifier = "payOffBtnNext"
    }
    
    @IBAction func continueButtonAction(_ sender: RedButton) {
        presenter.continueButton()
    }
}
