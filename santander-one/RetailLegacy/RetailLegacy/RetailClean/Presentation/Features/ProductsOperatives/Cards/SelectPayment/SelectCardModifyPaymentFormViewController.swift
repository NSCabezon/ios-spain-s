import UIKit
import UI

protocol SelectCardModifyPaymentFormPresenterProtocol: Presenter {
    var infoTitle: LocalizedStylableText { get }
    var toolTipMessage: LocalizedStylableText { get }
    func onContinueButtonClicked()
    func selected(indexPath: IndexPath)
    func auxiliaryButtonAction(tag: Int, completion: (RadioTableAuxiliaryAction) -> Void)
}

class SelectCardModifyPaymentFormViewController: BaseViewController<SelectCardModifyPaymentFormPresenterProtocol>, ToolTipDisplayer {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerButton: UIView!
    @IBOutlet weak var continueButton: RedButton!
    
    lazy var radio: RadioSubtitleTable = RadioSubtitleTable(delegate: self)
    
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
    
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[2].items
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigationBar()
    }
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "RadioSubtitleTableViewCell", "OperativeLabelTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        continueButton.onTouchAction = { [weak self] button in
            self?.presenter.onContinueButtonClicked()
        }
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        setAccessibilityIdentifiers()
    }
    
    func prepareNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .tooltip(titleKey: presenter?.infoTitle.text ?? "", type: .red, identifier: "changeWayToPay_toolbarTitle", action: { [weak self] sender in
                self?.showToolTip(sender)
            })
        )
        builder.build(on: self, with: nil)
        hideBackButton(false, animated: false)
    }
    
    private func showToolTip(_ sender: UIView) {
        ToolTip.displayToolTip(title: nil, description: nil, descriptionLocalized: presenter.toolTipMessage, identifier: "changeWayToPay_tooltip", sourceView: sender, sourceRect: CGRect(x: sender.bounds.origin.x, y: -10, width: sender.bounds.width, height: sender.bounds.height), viewController: self, dissapearAfter: nil)
    }
    
    private func setAccessibilityIdentifiers() {
        continueButton.accessibilityIdentifier = "changeWayToPay_continueButton"
        titleIdentifier = "changeWayToPay_toolbarTitle"
    }
}

// MARK: - RadioTableDelegate
extension SelectCardModifyPaymentFormViewController: RadioTableDelegate {
    var tableComponent: UITableView {
        return tableView
    }
    
    func auxiliaryButtonAction(tag: Int, completion: (RadioTableAuxiliaryAction) -> Void) {
        presenter.auxiliaryButtonAction(tag: tag, completion: completion)
    }
}

extension SelectCardModifyPaymentFormViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? RadioSubtitleTableViewCell {
            cell.toolTipDelegate = self
        }
    }
}
