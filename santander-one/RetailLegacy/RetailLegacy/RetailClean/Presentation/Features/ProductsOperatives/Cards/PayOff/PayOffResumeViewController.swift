import UIKit

protocol PayOffResumePresenterProtocol: Presenter {
    var buttonTitle: LocalizedStylableText { get }
    func confirmButtonTouched()
}

final class PayOffResumeViewController: BaseViewController<PayOffResumePresenterProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var confirmButton: RedButton!
    
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
        return TableDataSource()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["ConfirmationItemViewCell", "GenericConfirmationTableViewCell", "ConfirmationItemsListHeader", "DepositMoneyIntoCardHeaderConfirmationTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.set(localizedStylableText: presenter.buttonTitle, state: .normal)
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = "payOffResumeTitle"
        confirmButton.accessibilityIdentifier = "btn_confirm_confirmationDepositCard"
    }
}
