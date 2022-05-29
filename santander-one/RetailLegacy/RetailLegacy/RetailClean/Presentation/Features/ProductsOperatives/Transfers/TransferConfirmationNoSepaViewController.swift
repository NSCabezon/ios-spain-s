import UIKit

protocol TransferConfirmationNSPresenterProtocol: Presenter {
    func onContinueButtonClicked()
}

class TransferConfirmationNoSepaViewController: BaseViewController<TransferConfirmationNSPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet private weak var sepatorView: UIView!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    // MARK: - Private attributes
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    @IBAction private func onContinueButtonClicked(_ sender: UIButton) {
        presenter.onContinueButtonClicked()
    }
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericConfirmationTableViewCell", "ConfirmationItemsListHeader", "ConfirmationItemViewCell", "TransferAccountHeaderTableViewCell", "TextFieldTableViewCell", "ConfirmationTextFieldTableViewCell", "OperativeLabelTableViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        continueButton.configureHighlighted(font: .latoBold(size: 16))
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }

    func update(title: LocalizedStylableText) {
        styledTitle = title
    }

    func updateButton(title: LocalizedStylableText) {
        continueButton.set(localizedStylableText: title, state: .normal)
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .uiBackground
    }
}
