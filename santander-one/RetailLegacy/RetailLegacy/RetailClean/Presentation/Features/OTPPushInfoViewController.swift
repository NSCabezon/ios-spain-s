import UIKit

protocol OTPPushInfoPresenterProtocol: Presenter {
    func registerSelected()
}

class OTPPushInfoViewController: BaseViewController<OTPPushInfoPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var acceptButton: RedButton!
    
    // MARK: - Private attributes
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    // MARK: - Public attributes
    
    override static var storyboardName: String {
        return "OTPPush"
    }
    
    // MARK: - Public methods
    
    func add(sections: [TableModelViewSection]) {
        dataSource.addSections(sections)
        tableView.reloadData()
    }
    
    func set(acceptText: LocalizedStylableText) {
        acceptButton.configureHighlighted(font: .latoBold(size: 16))
        acceptButton.set(localizedStylableText: acceptText.uppercased(), state: .normal)
    }
    
    override func prepareView() {
        super.prepareView()
        acceptButton.titleLabel?.textAlignment = .center
        acceptButton.titleLabel?.lineBreakMode = .byWordWrapping
        acceptButton.titleLabel?.numberOfLines = 2
        view.backgroundColor = .uiBackground
        separator.backgroundColor = .lisboaGray
        setupTableView()
    }
    
    // MARK: - Private methods
    
    @IBAction private func acceptButtonTapped(_ sender: UIButton) {
        presenter.registerSelected()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.registerCells(["ConfirmationItemViewCell", "GenericHeaderViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
}
