//
//  MonthSubscriptionsViewController.swift
//  Menu
//
//  Created by Laura González on 11/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthSubscriptionsViewProtocol: AnyObject {
    func setSubscriptionDate(_ date: Date)
    func setSubscriptions(_ subscriptions: [SubscriptionsGroupViewModel])
    func setResume(_ subscriptionsNumbers: Int, totalAmount: AmountEntity)
}

final class MonthSubscriptionsViewController: UIViewController {
    
    @IBOutlet private weak var scrollableView: UIView!
    
    private var scrollableStackView = HorizontalScrollableStackView(frame: .zero)
    private let presenter: MonthSubscriptionsPresenterProtocol
    private var subscriptionDate: Date?
    
    private lazy var subscriptionsView: MonthSubscriptionsListView = {
        let view = MonthSubscriptionsListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(presenter: MonthSubscriptionsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "MonthSubscriptionsViewController", bundle: Bundle.module)
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

// MARK: - Private Methods

private extension MonthSubscriptionsViewController {
    func commonInit() {
        configureScrollView()
        subscriptionsView.delegate = self
        
    }
    
    func configureNavigationBar() {
        let month: String = localized(getMonthString())
        let title = localized("toolbar_title_suscriptionsOf", [StringPlaceholder(.value, month)]).text
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
        
        guard let monthIndex = Calendar.current.dateComponents([.month], from: subscriptionDate ?? Date()).month,
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
        
        self.scrollableStackView.addArrangedSubview(subscriptionsView)
        self.scrollableStackView.setBounce(enabled: false)
        
        subscriptionsView.widthAnchor.constraint(equalTo: scrollableView.widthAnchor).isActive = true
        subscriptionsView.heightAnchor.constraint(equalTo: scrollableView.heightAnchor).isActive = true
        scrollableStackView.layoutIfNeeded()
    }
}

// MARK: - ViewController Protocol

extension MonthSubscriptionsViewController: MonthSubscriptionsViewProtocol {
    func setSubscriptionDate(_ date: Date) {
        self.subscriptionDate = date
    }
    
    func setSubscriptions(_ subscriptions: [SubscriptionsGroupViewModel]) {
        subscriptionsView.addResults(subscriptions)
    }
    
    func setResume(_ subscriptionsNumbers: Int, totalAmount: AmountEntity) {
        subscriptionsView.setResume(subscriptionsNumbers, totalAmount: totalAmount) 
    }
}

// MARK: - ScrollView Delegate

extension MonthSubscriptionsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}

extension MonthSubscriptionsViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension MonthSubscriptionsViewController: AnalysisListViewProtocolDelegate {
    func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
        presenter.didSelectItemAtIndexPath(indexPath)
    }
}
