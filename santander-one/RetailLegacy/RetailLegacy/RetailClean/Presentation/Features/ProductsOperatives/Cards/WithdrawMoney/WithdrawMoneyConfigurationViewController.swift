import CoreFoundationLib
import UIKit
import UI

protocol WithdrawMoneyConfigurationPresenterProtocol: Presenter {
    func selectOperations()
    func selectDone()
    func loadTooltip()
    func startTooltipVideo()
}

class WithdrawMoneyConfigurationViewController: BaseViewController<WithdrawMoneyConfigurationPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var separatorFooterView: UIView!
    @IBOutlet private weak var operationsFooterButton: UIButton!
    @IBOutlet private weak var doneFooterButton: UIButton!
    private weak var lastTooltipViewSender: UIView?
    private weak var tooltipViewController: UIViewController?
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .white
    }
    
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
    
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func itemsInputContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    func reloadSections(_ numbers: [Int]) {
        let indexSet: IndexSet = IndexSet(numbers)
        tableView.reloadSections(indexSet, with: .none)
    }
    
    func reloadButtonsSection() {
        let sectionToReload = 2
        let indexSet: IndexSet = [sectionToReload]
        tableView.reloadSections(indexSet, with: .automatic)
    }
    
    override func prepareView() {
        separatorFooterView.backgroundColor = .lisboaGray
        view.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "AmountInputTableViewCell", "OperativeStackViewTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        setAccessbilityIdentifiers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let builder = NavigationBarBuilder(
            style: navigationBarStyle,
            title: .tooltip(
                titleKey: customTitle ?? "",
                type: .red,
                identifier: "rechargeMobile_title",
                action: didSelectInfo
            )
        )
        builder.build(on: self, with: nil)
        hideBackButton(false, animated: false)
    }
    
    @IBAction func actionOperations(_ sender: UIButton) {
        presenter.selectOperations()
    }
    
    @IBAction func actionDone(_ sender: UIButton) {
        presenter.selectDone()
    }
    
    func didSelectInfo(_ sender: UIView) {
        self.lastTooltipViewSender = sender
        presenter.loadTooltip()
    }
    
    func setOperationFooter(text: LocalizedStylableText) {
        operationsFooterButton.set(localizedStylableText: text, state: .normal)
        operationsFooterButton.titleLabel?.font = .latoMedium(size: 14)
    }
    
    func setDoneFooter(text: LocalizedStylableText) {
        doneFooterButton.set(localizedStylableText: text, state: .normal)
        doneFooterButton.titleLabel?.font = .latoMedium(size: 16)
    }
    
    func showGeneralTooltipWithVideo(_ isVideoEnabled: Bool) {
        guard let sender = self.lastTooltipViewSender else { return }
        let titleView = getTooltipText(
            "codeMoneyTooltip_title_codeMoney",
            font: UIFont.santander(family: .text, type: .bold, size: 20),
            separator: 8, identifier: "blockCard_tooltip_title"
        )
        var scrolledItems: [FullScreenToolTipViewItemData] = []
        if isVideoEnabled {
            let videoView = FullScreenToolTipViewItemData(
                view: VideoTooltipView(
                    imageName: "imgVideoCodeMoney",
                    action: presenter.startTooltipVideo
                ),
                bottomMargin: 12
            )
            scrolledItems.append(videoView)
        }
        let descriptionView = getTooltipText(
            "codeMoneyTooltip_text_getMoneyWithQR",
            font: UIFont.santander(family: .text, type: .light, size: 16),
            separator: 36, identifier: "blockCard_tooltip_description"
        )
        let stickyItems: [FullScreenToolTipViewItemData] = [titleView]
        scrolledItems.append(contentsOf: [descriptionView])
        let configuration = FullScreenToolTipViewData(topMargin: 0, stickyItems: stickyItems, scrolledItems: scrolledItems)
        self.tooltipViewController = configuration.show(in: self, from: sender)
    }
    
    func getTooltipText(_ text: String, font: UIFont, separator: CGFloat, identifier: String? = nil) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: CoreFoundationLib.localized(text), left: 18, right: 18, font: font, textColor: .lisboaGrayNew, labelAccessibilityID: identifier)
        let view = LabelTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    private func setAccessbilityIdentifiers() {
        doneFooterButton.accessibilityIdentifier = "rechangeMobile_doneButton"
        operationsFooterButton.accessibilityIdentifier = "rechangeMobile_operationsButton"
    }
}
