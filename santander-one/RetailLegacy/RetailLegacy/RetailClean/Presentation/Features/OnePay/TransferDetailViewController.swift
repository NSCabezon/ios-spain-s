import CoreFoundationLib
import UIKit
import UI

protocol TransfersDetailPresenterProtocol: SideMenuCapable {
    var title: String? { get }
    var buttonTitle: [LocalizedStylableText] { get }
    func executeAction(_ position: Int)
}

class TransferDetailViewController: BaseViewController<TransfersDetailPresenterProtocol>, ToolTipDisplayer {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var separatorView: UIView!
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .clear(tintColor: .sanRed)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = CoreFoundationLib.localized("toolbar_title_deliveryDetails")
    }
    
    private lazy var dataSource: TableDataSource = {
        return TableDataSource()
    }()
    
    override func prepareView() {
        super.prepareView()
        self.view.backgroundColor = .sky30
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["DetailTitleHeader"])
        tableView.registerCells(["GenericConfirmationTableViewCell", "DetailThreeLinesTableViewCell", "DetailItemTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        title = presenter.title
        for (index, option) in presenter.buttonTitle.enumerated() {
            let isWhiteButton = index == 0 && presenter.buttonTitle.count > 1
            let colorButton = isWhiteButton ? WhiteButton() : RedButton()
            colorButton.set(localizedStylableText: option, state: .normal)
            colorButton.setAccessibilityIdentifiers(buttonAccessibilityIdentifier: isWhiteButton ? AccessibilityOthers.btnWhite : AccessibilityOthers.btnRed,
                                                    titleLabelAccessibilityIdentifier: isWhiteButton ? AccessibilityOthers.labelBtnWhite : AccessibilityOthers.labelBtnRed)
            colorButton.tag = index
            colorButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            buttonStack.addArrangedSubview(colorButton)
        }
        separatorView.backgroundColor = .lisboaGray
    }
    
    func setSections(_ sections: [TableModelViewSection]) {
        dataSource.addSections(sections)
        tableView.reloadData()
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        presenter.executeAction(sender.tag)
    }
    
    override class var storyboardName: String {
        return "TransferDetail"
    }
}

extension TransferDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
