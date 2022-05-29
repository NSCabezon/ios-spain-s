import UIKit
import CoreFoundationLib

protocol OperativeConfirmationPresenterProtocol: Presenter {
    func onContinueButtonClicked()
    var infoTitle: LocalizedStylableText? { get }
    var toolTipMessage: LocalizedStylableText? { get }
    var progressBarBackgroundColor: UIColor { get }
    func controlSwipeGesture(tooltipShowed: Bool)
}

extension OperativeConfirmationPresenterProtocol {
    var progressBarBackgroundColor: UIColor { .uiWhite }
    func controlSwipeGesture(tooltipShowed: Bool) {}
}

class OperativeConfirmationViewController: BaseViewController<OperativeConfirmationPresenterProtocol> {
    
    // MARK: - OutletsprepareNavigationBar
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet private weak var sepatorView: UIView!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "ProductOperatives"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections, registeringCellsIn: tableView)
            tableView.reloadData()
        }
    }

    override var progressBarBackgroundColor: UIColor? {
        return self.presenter.progressBarBackgroundColor
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
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.backgroundColor = .uiBackground
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareNavigationBar()
    }
    
    func update(title: LocalizedStylableText) {
        styledTitle = title
    }
    
    func updateButton(title: LocalizedStylableText) {
        continueButton.set(localizedStylableText: title, state: .normal)
    }
    
    func prepareNavigationBar() {
        titleIdentifier = "operativeConfirmationTitle"
        guard let infoTitle = presenter.infoTitle else {
            return
        }
        let button = UIButton(type: .custom)
        
        button.addTarget(self, action: #selector(actionInfo(_:)), for: .touchUpInside)
        let imageWidth: CGFloat? = UIScreen.main.isIphone4or5 ? 21 : nil
        navigationItem.setInfoTitle(infoTitle, button: button, imageWidth: imageWidth)
    }
    
    @objc func actionInfo(_ sender: UIButton) {
        showToolTip(sender)
    }
    
    private func showToolTip(_ sender: UIButton) {
        guard let tooltipMessage = presenter.toolTipMessage else { return }
        ToolTip.displayToolTip(title: nil, description: nil, descriptionLocalized: tooltipMessage, sourceView: sender, sourceRect: CGRect(x: sender.bounds.origin.x, y: -10, width: sender.bounds.width, height: sender.bounds.height), viewController: self, dissapearAfter: nil)
    }
}

extension OperativeConfirmationViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        presenter.controlSwipeGesture(tooltipShowed: false)
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        presenter.controlSwipeGesture(tooltipShowed: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
