//
//  MonthReceiptsViewController.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthReceiptsViewProtocol: AnyObject {
    func setReceiptDate(_ date: Date)
    func addResults(_ results: [ReceiptsGroupViewModel])
    func setAllReceipts(_ receipst: [ReceiptsGroupViewModel])
    func setAllResume(receiptNumbers: Int, totalAmount: AmountEntity)
}

final class MonthReceiptsViewController: UIViewController {
    @IBOutlet private weak var scrollableView: UIView!
    
    private lazy var receiptListView: MonthReceiptsListView = {
        let view = MonthReceiptsListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var scrollableStackView = HorizontalScrollableStackView(frame: .zero)
    private let presenter: MonthReceiptsPresenterProtocol
    private var receiptDate: Date?
    
    init(presenter: MonthReceiptsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "MonthReceiptsViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

private extension MonthReceiptsViewController {
    func commonInit() {
        receiptListView.listViewDelegate = self
        configureScrollView()
    }
    
    func configureNavigationBar() {
        let month: String = localized(getMonthString())
        let title = localized("toolbar_title_receiptsOf", [StringPlaceholder(.value, month)]).text
        NavigationBarBuilder(style: .white,
                             title: .title(key: title))
            .setLeftAction(.back(action: #selector(dismissSelected)))
            .setRightActions(.menu(action: #selector(menuSelected)))
            .build(on: self, with: self.presenter)
    }
    
    func getMonthString() -> String {
        let allMonths = ["generic_label_january", "generic_label_february", "generic_label_march", "generic_label_april", "generic_label_may", "generic_label_june", "generic_label_july", "generic_label_august", "generic_label_september", "generic_label_october", "generic_label_november", "generic_label_december"]
        
        guard let monthIndex = Calendar.current.dateComponents([.month], from: receiptDate ?? Date()).month,
            allMonths.count >= monthIndex else {
                return ""
        }
        
        return allMonths[monthIndex - 1]
    }
    
    @objc func menuSelected() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
    
    func configureScrollView() {
        self.scrollableView.backgroundColor = .skyGray
        self.scrollableStackView.setup(with: self.scrollableView)
        self.scrollableStackView.enableScrollPagging(true)
        self.scrollableStackView.addArrangedSubview(receiptListView)
        self.scrollableStackView.setBounce(enabled: false)
        
        self.receiptListView.widthAnchor.constraint(equalTo: scrollableView.widthAnchor).isActive = true
        self.receiptListView.heightAnchor.constraint(equalTo: scrollableView.heightAnchor).isActive = true
        self.scrollableStackView.layoutIfNeeded()
        
        self.receiptListView.setDelegate(self)
    }
}

extension MonthReceiptsViewController: MonthReceiptsViewProtocol {
    func addResults(_ results: [ReceiptsGroupViewModel]) {
        self.receiptListView.addResults(results)
    }
    
    func setReceiptDate(_ date: Date) {
        self.receiptDate = date
    }
    
    func setAllReceipts(_ receipts: [ReceiptsGroupViewModel]) {
        self.receiptListView.addResults(receipts)
    }
    
    func setAllResume(receiptNumbers: Int, totalAmount: AmountEntity) {
        self.receiptListView.setTableViewHeader(receiptNumbers: receiptNumbers, totalAmount: totalAmount)
    }
}

extension MonthReceiptsViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension MonthReceiptsViewController: MonthReceiptsListViewDelegate {
    func didSelectReceipt(viewModel: ReceiptsViewModel) {
        self.presenter.didSelectReceipt(viewModel)
    }
}

extension MonthReceiptsViewController: AnalysisListViewProtocolDelegate {
    func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
        presenter.didSelectItemAtIndexPath(indexPath)
    }
}
