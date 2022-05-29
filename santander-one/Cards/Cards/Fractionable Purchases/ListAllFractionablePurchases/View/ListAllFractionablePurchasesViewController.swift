import UI
import CoreFoundationLib
import UIKit

protocol ListAllFractionablePurchasesViewProtocol: OldDialogViewPresentationCapable {
    func showFractionableMovements(_ viewModel: [ListAllFractionablePurchasesByDayViewModel])
    func showEmptyView()
    func showLoading(_ show: Bool)
}

extension ListAllFractionablePurchasesViewController: LoadingViewPresentationCapable {}

final class ListAllFractionablePurchasesViewController: UIViewController {
    private let sectionIdentifier = "DateSectionView"
    private let dependenciesResolver: DependenciesResolver
    private let presenter: ListAllFractionablePurchasesPresenterProtocol
    var viewModel: [ListAllFractionablePurchasesByDayViewModel]?
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var stackView: UIStackView!
    
    init(dependenciesResolver: DependenciesResolver, presenter: ListAllFractionablePurchasesPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: "ListAllFractionablePurchasesViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setnavigationBar()
    }
    
    func setnavigationBar() {
        NavigationBarBuilder(style: .custom(background: .color(.skyGray), tintColor: .santanderRed),
                             title: .title(key: "toolbar_title_instalmentsPurchases"))
            .setLeftAction(.back(action: #selector(didSelectBack)))
            .setRightActions(.menu(action: #selector(didSelectMenu)))
            .build(on: self, with: nil)
    }
}

extension ListAllFractionablePurchasesViewController: ListAllFractionablePurchasesViewProtocol {
    func showFractionableMovements(_ movements: [ListAllFractionablePurchasesByDayViewModel]) {
        self.viewModel = movements
        tableView.reloadData()
    }
    
    func showEmptyView() {
        clearView()
        let view = SingleEmptyView()
        view.titleFont(UIFont.santander(family: .headline,
                                        size: 20.0))
        view.updateTitle(localized("fractionatePurchases_text_emptyView"))
        stackView.addArrangedSubview(view)
    }
    
    func showLoading(_ show: Bool) {
        show ? self.showLoading() : self.dismissLoading()
    }
}

extension ListAllFractionablePurchasesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel[section].getDayMovements().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(ListAllFractionablePurchasesTableViewCell.self, indexPath: indexPath) as ListAllFractionablePurchasesTableViewCell
        let dayMovements = viewModel[indexPath.section].getDayMovements()
        let item = dayMovements[indexPath.row]
        cell.configureCell(item)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifier) as? DateSectionView,
              let viewModel = self.viewModel else { return nil }
        let transaction = viewModel[section].dateFormatted
        header.configure(withDate: transaction)
        section == 0 ? header.toggleHorizontalLine(toVisible: true) : header.toggleHorizontalLine(toVisible: false)
        tableView.removeUnnecessaryHeaderTopPadding()
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel else { return }
        let dayMovements = viewModel[indexPath.section].getDayMovements()
        let item = dayMovements[indexPath.row]
        presenter.didSelectItem(item)
    }
}

private extension ListAllFractionablePurchasesViewController {
    @objc func didSelectBack() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func didSelectMenu() {
        self.presenter.didSelectMenu()
    }
    
    func setup() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.register(ListAllFractionablePurchasesTableViewCell.self, bundle: ListAllFractionablePurchasesTableViewCell.bundle)
        let nib = UINib(nibName: sectionIdentifier, bundle: Bundle.uiModule)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: sectionIdentifier)
        let configuration = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .bold, size: 16.0),
            alignment: .left,
            lineHeightMultiple: 0.75,
            lineBreakMode: .byTruncatingTail)
        self.titleLabel.configureText(withLocalizedString: localized("financing_label_movements"), andConfiguration: configuration)
    }
    
    func clearView() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityListAllFractionablePurchases.subtitleLabel
        self.tableView.accessibilityIdentifier = AccessibilityListAllFractionablePurchases.containerView
    }
}

extension ListAllFractionablePurchasesViewController: ListAllFractionablePurchasesDelegate {
    func didSelectSeeFrationateOptions(viewModel: FractionablePurchaseViewModel) {
        presenter.seeFractionateOptions(viewModel: viewModel)
    }
}
