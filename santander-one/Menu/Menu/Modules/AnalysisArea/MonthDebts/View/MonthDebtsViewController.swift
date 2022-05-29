//
//  MonthDebtsViewController.swift
//  Menu
//
//  Created by Laura González on 05/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthDebtsViewProtocol: AnyObject {
    func setDebtDate(_ date: Date)
    func setAllDebts(_ debts: [DebtsGroupViewModel])
    func setResume(_ totalAmount: AmountEntity)
}

final class MonthDebtsViewController: UIViewController {
    
    @IBOutlet private weak var scrollableView: UIView!
    
    private var scrollableStackView = HorizontalScrollableStackView(frame: .zero)
    private let presenter: MonthDebtsPresenterProtocol
    private var debtDate: Date?
    
    private lazy var allDebtsView: MonthDebtsListView = {
        let view = MonthDebtsListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(presenter: MonthDebtsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "MonthDebtsViewController", bundle: Bundle.module)
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

private extension MonthDebtsViewController {
    func commonInit() {
        configureScrollView()
        allDebtsView.delegate = self
    }
    
    func configureNavigationBar() {
        let month: String = localized(getMonthString())
        let title = localized("toolbar_title_debtOf", [StringPlaceholder(.value, month)]).text
        NavigationBarBuilder(style: .white,
                             title: .title(key: title))
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
        
        guard let monthIndex = Calendar.current.dateComponents([.month], from: debtDate ?? Date()).month,
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
        
        self.scrollableStackView.addArrangedSubview(allDebtsView)
        self.scrollableStackView.setBounce(enabled: false)
        
        allDebtsView.widthAnchor.constraint(equalTo: scrollableView.widthAnchor).isActive = true
        allDebtsView.heightAnchor.constraint(equalTo: scrollableView.heightAnchor).isActive = true
        scrollableStackView.layoutIfNeeded()
    }
}

extension MonthDebtsViewController: MonthDebtsViewProtocol {
    func setDebtDate(_ date: Date) {
        self.debtDate = date
    }
    
    func setAllDebts(_ debts: [DebtsGroupViewModel]) {
        allDebtsView.addResults(debts)
    }
    
    func setResume(_ totalAmount: AmountEntity) {
        allDebtsView.setTableViewHeader(totalAmount)
    }
}

extension MonthDebtsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}

extension MonthDebtsViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension MonthDebtsViewController: AnalysisListViewProtocolDelegate {
    func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
        presenter.didSelectItemAtIndexPath(indexPath)
    }
}
