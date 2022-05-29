//
//  MonthTransfersViewController.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthTransfersViewProtocol: AnyObject {
    func setTransferDate(_ date: Date)
    func setAllTransfers(_ transfers: [EmittedGroupViewModel])
    func setReceivedTransfers(_ transfers: [EmittedGroupViewModel])
    func setEmittedTransfers(_ transfers: [EmittedGroupViewModel])
    func setAllResume(transfersNumbers: Int, totalAmount: AmountEntity)
    func setEmittedResume(transfersNumbers: Int, totalAmount: AmountEntity)
    func setReceivedResume(transfersNumbers: Int, totalAmount: AmountEntity)
    func setSelectedTransfer(_ selectedTransfer: ExpenseType)
    var selectedSegmentIndex: Int { get }
}

final class MonthTransfersViewController: UIViewController {
    
    @IBOutlet private weak var lisboaSegmentedControl: LisboaSegmentedControl!
    @IBOutlet private weak var scrollableView: UIView!
    private var currentSegmentIndex: Int = -1
    private var scrollableStackView = HorizontalScrollableStackView(frame: .zero)
    private let presenter: MonthTransfersPresenterProtocol
    private var transferDate: Date?
    private var selectedTransfer: ExpenseType?
    private var visibleView: MonthTransfersListView {
        let idx = self.lisboaSegmentedControl.selectedSegmentIndex
        return idx == 0 ? allTransfersView :
            (idx == 1) ? issuedTransfersView :
        receivedTransfersView
    }
    
    private var allViews: [MonthTransfersListView] {
        return [allTransfersView, issuedTransfersView, receivedTransfersView]
    }
    
    private lazy var allTransfersView: MonthTransfersListView = {
        let view = MonthTransfersListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var issuedTransfersView: MonthTransfersListView = {
        let view = MonthTransfersListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var receivedTransfersView: MonthTransfersListView = {
        let view = MonthTransfersListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(presenter: MonthTransfersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "MonthTransfersViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        presenter.viewDidLoad()
        isBizumTransfer() ? configureBizumTransfer() : configureNormalTransfer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        self.setSelectedTransfer()
    }
    
    @IBAction func didChangedSelectedIndex(_ sender: UISegmentedControl) {
        self.scrollToPage(page: sender.selectedSegmentIndex, animated: true)
        self.scrollToTop()
        currentSegmentIndex = sender.selectedSegmentIndex
    }
}

private extension MonthTransfersViewController {
    
    func commonInit() {
        configureScrollView()
        currentSegmentIndex = lisboaSegmentedControl.selectedSegmentIndex
    }
    
    func configureNavigationBar() {
        let month: String = localized(getMonthString())
        let title = localized("toolbar_title_transfers", [StringPlaceholder(.value, month)]).text
        let titleBizum = localized("toolbar_title_bizumOf", [StringPlaceholder(.value, month)]).text
        NavigationBarBuilder(style: .white,
                             title: .title(key: isBizumTransfer() ? titleBizum : title))
            .setLeftAction(.back(action: #selector(dismissSelected)))
            .setRightActions(.menu(action: #selector(menuSelected)))
            .build(on: self, with: self.presenter)
    }
    
    @objc func menuSelected() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
    
    func getMonthString() -> String {
        let allMonths = ["generic_label_january", "generic_label_february", "generic_label_march", "generic_label_april", "generic_label_may", "generic_label_june", "generic_label_july", "generic_label_august", "generic_label_september", "generic_label_october", "generic_label_november", "generic_label_december"]
        
        guard let monthIndex = Calendar.current.dateComponents([.month], from: transferDate ?? Date()).month,
            allMonths.count >= monthIndex else {
                return ""
        }
        
        return allMonths[monthIndex - 1]
    }
    
    func configureScrollView() {
        self.scrollableView.backgroundColor = .skyGray
        self.scrollableStackView.setup(with: self.scrollableView)
        self.scrollableStackView.setScrollDelegate(self)
        self.scrollableStackView.enableScrollPagging(true)
        
        self.scrollableStackView.addArrangedSubview(allTransfersView)
        self.scrollableStackView.addArrangedSubview(issuedTransfersView)
        self.scrollableStackView.addArrangedSubview(receivedTransfersView)
        self.scrollableStackView.setBounce(enabled: false)
        
        allTransfersView.widthAnchor.constraint(equalTo: scrollableView.widthAnchor).isActive = true
        allTransfersView.heightAnchor.constraint(equalTo: scrollableView.heightAnchor).isActive = true
        issuedTransfersView.widthAnchor.constraint(equalTo: scrollableView.widthAnchor).isActive = true
        issuedTransfersView.heightAnchor.constraint(equalTo: scrollableView.heightAnchor).isActive = true
        receivedTransfersView.widthAnchor.constraint(equalTo: scrollableView.widthAnchor).isActive = true
        receivedTransfersView.heightAnchor.constraint(equalTo: scrollableView.heightAnchor).isActive = true
        scrollableStackView.layoutIfNeeded()
        
        allViews.forEach { $0.setDelegate(self) }
    }
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollableView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollableStackView.scrollRectToVisible(frame, animated: animated)
    }
    
    func scrollToTop() {
        allViews.forEach { $0.scrollToTop() }
    }
    
    func setSelectedTransfer() {
        self.lisboaSegmentedControl.selectedSegmentIndex = self.selectedTransfer == .transferEmitted || self.selectedTransfer == .bizumEmitted ? 1 : 2
        
        DispatchQueue.main.async {
            self.scrollToPage(page: self.lisboaSegmentedControl.selectedSegmentIndex, animated: false)
        }
    }
    
    func configureBizumTransfer() {
        let month: String = localized(getMonthString())
        issuedTransfersView.configureEmptyTitle(localized("analysis_emptyView_bizumShipments",
                                                          [StringPlaceholder(.value, month)]))
        receivedTransfersView.configureEmptyTitle(localized("analysis_emptyView_bizumRequests",
                                                            [StringPlaceholder(.value, month)]))
        
        let titlesSegmented = ["bizum_tab_all", "bizum_tab_shipments", "bizum_tab_requests"]
        
        let accessibilityIdentifiers = [AccessibilityAnalysisArea.btnAll.rawValue,
                                        AccessibilityAnalysisArea.btnShipments.rawValue,
                                        AccessibilityAnalysisArea.btnRequests.rawValue]
        
        self.lisboaSegmentedControl.setup(with: titlesSegmented,
                                          accessibilityIdentifiers: accessibilityIdentifiers)
        self.lisboaSegmentedControl.backgroundColor = .skyGray
    }
    
    func configureNormalTransfer() {
        let month: String = localized(getMonthString())
        issuedTransfersView.configureEmptyTitle(localized("analysis_emptyView_transferDelivered",
                                                          [StringPlaceholder(.value, month)]))
        receivedTransfersView.configureEmptyTitle(localized("analysis_emptyView_transferReceived",
                                                            [StringPlaceholder(.value, month)]))
        
        let titlesSegmented = ["search_tab_all", "search_tab_delivered", "search_tab_received"]
        let accessibilityIdentifiers = [AccessibilityAnalysisArea.btnAll.rawValue,
                                        AccessibilityAnalysisArea.btnDelivered.rawValue,
                                        AccessibilityAnalysisArea.btnReceived.rawValue]
        self.lisboaSegmentedControl.setup(with: titlesSegmented,
                                          accessibilityIdentifiers: accessibilityIdentifiers)
        self.lisboaSegmentedControl.backgroundColor = .skyGray
    }
    
    func isBizumTransfer() -> Bool {
        return selectedTransfer == .bizumEmitted || selectedTransfer == .bizumReceived
    }
}

extension MonthTransfersViewController: MonthTransfersViewProtocol {
    var selectedSegmentIndex: Int {
        currentSegmentIndex
    }
    
    func setTransferDate(_ date: Date) {
        self.transferDate = date
    }
    
    func setSelectedTransfer(_ selectedTransfer: ExpenseType) {
        self.selectedTransfer = selectedTransfer
    }

    func setAllTransfers(_ transfers: [EmittedGroupViewModel]) {
        allTransfersView.addResults(transfers)
    }
    
    func setReceivedTransfers(_ transfers: [EmittedGroupViewModel]) {
        receivedTransfersView.addResults(transfers)
    }
    
    func setEmittedTransfers(_ transfers: [EmittedGroupViewModel]) {
        issuedTransfersView.addResults(transfers)
    }

    func setAllResume(transfersNumbers: Int, totalAmount: AmountEntity) {
        allTransfersView.setTableViewHeader(transfersNumbers: transfersNumbers, totalAmount: totalAmount)
    }
    
    func setEmittedResume(transfersNumbers: Int, totalAmount: AmountEntity) {
        issuedTransfersView.setTableViewHeader(transfersNumbers: transfersNumbers, totalAmount: totalAmount)
    }
    
    func setReceivedResume(transfersNumbers: Int, totalAmount: AmountEntity) {
        receivedTransfersView.setTableViewHeader(transfersNumbers: transfersNumbers, totalAmount: totalAmount)
    }
}

extension MonthTransfersViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let position =
            scrollView.contentOffset.x < 0 ?
                0.0 : (scrollView.contentOffset.x > scrollView.contentSize.width ?
                    scrollView.contentSize.width : scrollView.contentOffset.x)
        
        let idx = Int(position / self.view.frame.width)
        if self.lisboaSegmentedControl.selectedSegmentIndex != idx {
            self.lisboaSegmentedControl.selectedSegmentIndex = idx
            self.scrollToTop()
        }
    }
}

extension MonthTransfersViewController: MonthTransfersListViewDelegate {
    func didSelectEmitted(viewModel: TransferEmittedViewModel) {
        self.presenter.didSelectEmitted(viewModel: viewModel)
    }
}

extension MonthTransfersViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}
