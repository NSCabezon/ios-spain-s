import UIKit

protocol SelectTypeBlockCardPresenterProtocol: Presenter {
    func selected(index: IndexPath)
    func onContinueButtonClicked()
}

class SelectTypeBlockCardViewController: BaseViewController<SelectTypeBlockCardPresenterProtocol> {
    
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerButton: UIView!
    @IBOutlet weak var continueButton: RedButton!
        
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "OperativeLabelTableViewCell"])
        tableView.register(UINib(nibName: "TitledTableHeader", bundle: .module), forHeaderFooterViewReuseIdentifier: "TitledTableHeader")
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = "blockCard_title"
        continueButton.accessibilityIdentifier = "blockCard_continueBtn"
    }
}

extension SelectTypeBlockCardViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(index: indexPath)
    }
}
