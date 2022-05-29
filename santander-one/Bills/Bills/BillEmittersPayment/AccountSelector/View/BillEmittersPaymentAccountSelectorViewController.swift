import UIKit
import Operative
import UI
import CoreFoundationLib

protocol BillEmittersPaymentAccountSelectorViewProtocol: OperativeView {
    func showAccounts(_ viewModels: [BillAccountSelectionViewModel])
    func showFaqs(_ items: [FaqsItemViewModel])
}

class BillEmittersPaymentAccountSelectorViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let presenter: BillEmittersPaymentAccountSelectorPresenterProtocol
    private var viewModels: [BillAccountSelectionViewModel] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: BillEmittersPaymentAccountSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setTableView()
        self.setHeaderView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
}

private extension BillEmittersPaymentAccountSelectorViewController {
    func setupView() {
        self.view.backgroundColor = .skyGray
    }
    
    func setTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.register(AccountSelectionTableViewCell.self, bundle: AccountSelectionTableViewCell.bundle)
    }
    
    func setHeaderView() {
        let headerView = BillEmittersPaymentHeaderView()
        self.tableView.tableHeaderView = headerView
        self.tableView.updateHeaderViewFrame()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_originAccount",
                                    header: .title(key: "toolbar_title_paymentOther", style: .default))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc func close() {
        presenter.didTapClose()
    }
}

extension BillEmittersPaymentAccountSelectorViewController: BillEmittersPaymentAccountSelectorViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        presenter
    }
    
    func showAccounts(_ viewModels: [BillAccountSelectionViewModel]) {
        self.viewModels = viewModels
        self.tableView.reloadData()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension BillEmittersPaymentAccountSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension BillEmittersPaymentAccountSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: AccountSelectionTableViewCell.identifier, for: indexPath) as? AccountSelectionTableViewCell else { return UITableViewCell() }
        let accessibilityIdentifier = "billPaymentAccountSelectorBtn\(indexPath.row + 1)"
        cell.setViewModel(self.viewModels[indexPath.row], accessibilityIdendtifier: accessibilityIdentifier)
        cell.accessibilityIdentifier = accessibilityIdentifier
        return cell
    }
}

extension BillEmittersPaymentAccountSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelectAccount(self.viewModels[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
        cell.setHighlighted()
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
        cell.setUnhighlighted()
    }
}

final class BillEmittersPaymentHeaderView: UIView {
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let parent = superview else { return }
        self.widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: 1).isActive = true
        self.fullFit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUpView()
    }
    
    func setUpView() {
        self.addSubview(stackView)
        stackView.fullFit()
        stackView.addArrangedSubview(AccountSelectorHeaderView())
    }
}
