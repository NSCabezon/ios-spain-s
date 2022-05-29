//

import UIKit
import UI

protocol InternalTransferConfirmationPresenterProtocol: Presenter {
    var continueTitle: LocalizedStylableText { get }
    func next()
    func trackFaqEvent(_ question: String, url: URL?)
}

class InternalTransferConfirmationViewController: BaseViewController<InternalTransferConfirmationPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var continueButton: RedButton!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "InternalTransferOperative"
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
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.continueTitle, state: .normal)
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericConfirmationTableViewCell", "ConfirmationItemsListHeader", "ConfirmationItemViewCell", "TransferAccountHeaderTableViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
    
    // MARK: - Private methods
    
    @IBAction private func continueButtonTapped(_ sender: UIButton) {
        self.presenter.next()
    }
}

extension InternalTransferConfirmationViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}
