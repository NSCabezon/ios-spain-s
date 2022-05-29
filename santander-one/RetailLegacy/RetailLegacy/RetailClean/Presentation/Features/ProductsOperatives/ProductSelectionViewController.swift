//

import UIKit
import UI
import CoreFoundationLib

enum ProductSelectionProgressStyle {
    case white
    case uiBackground
}

protocol ProductSelectionPresenterProtocol: Presenter {
    
    associatedtype Product: GenericProduct
    
    var dependencies: PresentationComponent { get }
    var products: [Product] { get set }
    var view: ProductSelectionViewController { get }
    var tooltipMessage: LocalizedStylableText? { get }
    var progressBarBackgroundStyle: ProductSelectionProgressStyle { get }
    
    func selected(index: Int)
    func setTitle()
    func getTitle() -> String?
}

extension ProductSelectionPresenterProtocol {
    
    func set(title: String) {
        view.styledTitle = dependencies.stringLoader.getString(title)
    }
    
    func showProducts(sectionTitleKey: String) {
        let sectionContent = TableModelViewSection()
        // Add the products
        let profile = ProductSelectionProfile<Product>(list: products, dependencies: dependencies)
        profile.addToSection(sectionContent)
        // Add the title of table & view title
        let titleTable = TitledTableModelViewHeader()
        titleTable.insets = Insets(left: 11, right: 10, top: 27, bottom: 18)
        titleTable.title = dependencies.stringLoader.getString(sectionTitleKey)
        titleTable.titleIdentifier = "depositCardLabelSelectCard"
        sectionContent.setHeader(modelViewHeader: titleTable)
        view.sections += [sectionContent]
    }
}

class ProductSelectionViewController: BaseViewController<ProductSelectionPresenterProtocol>, ToolTipDisplayer {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "ProductSelection"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    // Add here keys when selector view controller need tooltip
    private let keysWithTooltip: Set = ["toolbar_title_ces"]
    
    // MARK: - Private attributes
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericHeaderViewCell", "SelectableProductViewCell", "SelectableCardViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override var progressBarBackgroundColor: UIColor? {
        switch presenter.progressBarBackgroundStyle {
        case .white:
            return .white
        case .uiBackground:
            return .uiBackground
        }
    }
    
    func prepareNavigationBar(using title: LocalizedStylableText) {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(actionInfo(_:)), for: .touchUpInside)
        navigationItem.setInfoTitle(title, button: button)
    }
}

private extension ProductSelectionViewController {
    func setupNavigationBar() {
        let titleKey = self.presenter.getTitle() ?? ""
        let navBarTitle = getNavBarTitle(titleKey)
        NavigationBarBuilder(
            style: .white,
            title: navBarTitle
        )
        .setLeftAction(.back(action: #selector(dismissViewController)))
        .build(on: self, with: nil)
    }
    
    func getNavBarTitle(_ titleKey: String) -> NavigationBarBuilder.Title {
        keysWithTooltip.contains(titleKey) ? .tooltip(titleKey: titleKey, type: .red, action: { [weak self] sender in
                self?.showToolTip(sender)
            })
            : .title(key: titleKey)
    }
    
    func showToolTip(_ sender: UIView) {
        guard let titleKey = presenter?.getTitle(),
              let toolTipMessage = presenter?.tooltipMessage else {
            return
        }
        let navigationToolTip = NavigationToolTip()
        navigationToolTip.add(title: localized(key: titleKey))
        navigationToolTip.add(description: toolTipMessage)
        navigationToolTip.show(in: self, from: sender)
    }
    
    @objc func dismissViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func actionInfo(_ sender: UIButton) {
        showToolTip(sender)
    }
}

extension ProductSelectionViewController: TableDataSourceDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        presenter.selected(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cardCell = cell as? SelectableCardViewCell {
            cardCell.cardName.accessibilityIdentifier = AccessibilityProductSelection.cardName
            cardCell.cardAccount.accessibilityIdentifier = AccessibilityProductSelection.cardAccount
            cardCell.cardItemQuantityTitle.accessibilityIdentifier = AccessibilityProductSelection.cardItemQuantityTitle
            cardCell.cardItemQuantity.accessibilityIdentifier = AccessibilityProductSelection.cardItemQuantity
            cardCell.cardItemImage?.accessibilityIdentifier = AccessibilityProductSelection.cardItemImage
        }
    }
}
