import UI
import CoreFoundationLib
import AVFoundation

protocol ManualModeBillsAndTaxesPresenterProtocol: Presenter {
    var buttonTitle: LocalizedStylableText { get }
    func onContinueButtonClicked()
    func didTapClose()
    func didTapFaqs()
    func didTapBack()
    func trackFaqEvent(_ question: String, url: URL?)
}

class ManualModeBillsAndTaxesViewController: BaseViewController<ManualModeBillsAndTaxesPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: RedButton!
    
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .white
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
    
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }

    override func prepareView() {
        super.prepareView()
        
        view.backgroundColor = .uiBackground
        
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "TooltipInTitleWithTextFieldViewCell", "AmountInputTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.buttonTitle, state: .normal)
        continueButton.onTouchAction = { [weak self] _ in
            self?.presenter.onContinueButtonClicked()
        }
        self.setAccessibilityIdentifiers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        // Removes BarcodeScanner from stack in case user gone from camera to manual in previous step
        if let viewControllers = self.navigationController?.viewControllers,
           let indexInNavigation = viewControllers.firstIndex(where: { $0 is BarcodeScannerViewController }) {
            self.navigationController?.viewControllers.remove(at: indexInNavigation)
        }
        let builder = NavigationBarBuilder(
            style: .white,
            title: .titleWithHeader(
                titleKey: styledTitle?.text ?? "",
                header: .title(
                    key: localizedSubTitleKey ?? "",
                    style: .default
                )
            )
        )
        builder.setLeftAction(.back(action: #selector(back)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func back() {
        presenter.didTapBack()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension ManualModeBillsAndTaxesViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension ManualModeBillsAndTaxesViewController: TooltipInTitleWithTextFieldActionDelegate {
    func auxiliaryButtonAction(completion: (TooltipInTitleWithTextFieldAuxiliaryAction) -> Void) {
        completion(.toolTip(delegate: self))
    }
}

extension ManualModeBillsAndTaxesViewController: ToolTipDisplayer {}

extension ManualModeBillsAndTaxesViewController: ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }
}

private extension ManualModeBillsAndTaxesViewController {
    func setAccessibilityIdentifiers() {
        self.continueButton.accessibilityIdentifier = AccesibilityLegacy.ManualModeBillsAndTaxesViewController.viewContinueButton
    }
}
