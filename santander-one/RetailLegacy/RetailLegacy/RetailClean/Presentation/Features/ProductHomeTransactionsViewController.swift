//

import UIKit

protocol ProductHomeTransactionsPresenterProtocol {
    var numberOfDefaultSections: Int { get }
    var transactionsBackgroundColor: TransactionsBackgroundColor { get set }
    
    func willDisplayLastCell()
    func didSelectTransaction(section: Int, position: Int)
    func willDisplayElement(section: Int, position: Int)
    func didEndDisplayingElement(section: Int, position: Int)
    func showPresenterLoading(type: LoadingViewType)
    func hidePresenterLoading()
    func reloadContent(request: Bool)
}

final class ProductHomeTransactionsViewController: BaseViewController<ProductHomeTransactionsPresenterProtocol>, ToolTipDisplayer, UITableViewDelegate, MultiTableViewSectionsDelegate {
    
    enum ViewState {
        case loading
        case ready
    }
    
    override class var storyboardName: String {
        return "ProductHome"
    }
    
    var isIphone4or5: Bool {
        return UIScreen.main.isIphone4or5
    }
    
    var isScrollEnabled: Bool {
        get {
            return tableView.isScrollEnabled
        }
        set {
            tableView.isScrollEnabled = newValue
        }
    }
    
    var avaliableSpace: CGFloat {
        return view.frame.size.height - 88
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource: TransactionsDataSource = {
        return TransactionsDataSource()
    }()
    
    private var viewState: ViewState = .ready {
        didSet {
            switch viewState {
            case .loading:
                installLoading()
            case .ready:
                removeLoading()
            }
        }
    }
    
    override func prepareView() {
        tableView.separatorStyle = .none
        tableView.registerCells(["ProductOptionsTableViewCell", "TransactionFilterViewCell", "AccountTransactionViewCell", "LoanTransactionViewCell",
                                 "FundViewCell", "PensionPlanViewCell", "ImpositionViewCell", "SecondaryLoadingViewCell", "EmptyViewCell",
                                 "EmptyViewCell", "StockViewCell", "ProductDetailInfoCell", "PortfolioProductTitleViewCell", "PortfolioProductViewCell",
                                 "PortfolioProductTransactionViewCell", "InsuranceGeneralDataTableViewCell", "InsuranceInfoTableViewCell",
                                 "ImpositionTransactionViewCell", "CardTransactionsViewCell", "OrderViewCell", "CardTransactionFilterOffViewCell",
                                 "CardTransactionFilterOnViewCell", "DispensationViewCell", "ImpositionLiquidationViewCell", "VeryEmptyViewCell", "TransactionMoreViewCell", "TransactionMoreEmptyViewCell"])
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = presenter.transactionsBackgroundColor == .white ? .uiWhite : .uiBackground
        
        dataSource.toolTipDelegate = self
        
    }

    func setTransactionsBackground(color: TransactionsBackgroundColor) {
        tableView.backgroundColor = color == .white ? .uiWhite : .uiBackground
    }
    
    func addSections(_ sections: [TableModelViewSection]) {
        dataSource.addSections(sections)
        tableView.reloadData()
    }
    
    func insertSection(section: TableModelViewSection, at index: Int) {
        dataSource.insertSection(section, at: index)
        tableView.reloadData()
    }
    
    func replaceAllSections(with sections: [TableModelViewSection], shouldScrollToTop: Bool = true, completion: @escaping () -> Void) {
        dataSource.replaceAllSections(sections)
        tableView.reloadData(completion: completion)
        if shouldScrollToTop {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToTop()
            }
        }
    }
    
    func replaceHeaderSection(with section: TableModelViewSection, shouldScrollToTop: Bool = true) {
        let classForCoder: AnyClass = section.classForCoder
        if dataSource.sections.count > 0 {
            for i in 0 ... dataSource.sections.count - 1 {
                let section = dataSource.sections[i]
                if section.classForCoder == classForCoder {
                    dataSource.removeSection(i)
                    dataSource.insertSection(section, at: i)
                    break
                }
            }
        } else {
            dataSource.insertSection(section, at: 0)
        }
        
        tableView.reloadData()
        if shouldScrollToTop {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToTop()
            }
        }
    }
    
    func scrollToTop() {
        scrollListToTop()
    }
    
    private func scrollListToTop() {
        guard !dataSource.sections.isEmpty, let indexPath = tableView.indexPathForRow(at: CGPoint.zero) else {
            return
        }
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func fixBounds() {
        tableView.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
    }
    
    // MARK: - MultiTableViewSectionsDelegate
    
    func willDisplayLastRow() {
        presenter.willDisplayLastCell()
    }
    
    func showLoading() {
        viewState = .loading
    }
    
    func hideLoading() {
        viewState = .ready
    }
    
    func updateIndex (index: Int) {
        var sections: Int = 0
        var rowCount = index
        for section in dataSource.sections {
            if section.isKind(of: TransactionDaySection.self) {
                break
            } else {
                sections += 1
            }
        }
        var indexPath = IndexPath(row: 0, section: sections + index)
        for section in sections..<dataSource.sections.count {
            let items = dataSource.sections[section].items.count
            if rowCount - items < 0 {
                indexPath = IndexPath(row: rowCount, section: section)
                break
            }
            rowCount -= items
        }
        if dataSource.sections.count > indexPath.section {
            let sectionViewModel = dataSource.sections[indexPath.section]
            if sectionViewModel.get(indexPath.row) != nil {
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
    
    @objc
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSource.sections[indexPath.section].isKind(of: TransactionDaySection.self) {
            presenter.didSelectTransaction(section: indexPath.section, position: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSource.sections.count > indexPath.section, dataSource.sections[indexPath.section].isKind(of: TransactionDaySection.self) {
            presenter.willDisplayElement(section: indexPath.section, position: indexPath.row)
        }
        if indexPath.section == dataSource.sections.count - 1 {
            presenter.willDisplayLastCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSource.sections.count > indexPath.section, dataSource.sections[indexPath.section].isKind(of: TransactionDaySection.self) {
            presenter.didEndDisplayingElement(section: indexPath.section, position: indexPath.row)
        }
    }
    
    @objc
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard dataSource.sections.count > indexPath.section else {
            return UITableView.automaticDimension
        }
        let item = dataSource.sections[indexPath.section].get(indexPath.row)
        return item?.height ?? UITableView.automaticDimension
    }
    
    private func installLoading() {
        let type = LoadingViewType.onView(view: tableView, frame: calculateTableExcess(), position: .top, controller: self)
        presenter.showPresenterLoading(type: type)
    }
    
    private func removeLoading() {
        presenter.hidePresenterLoading()
    }
    
    private func calculateTableExcess() -> CGRect {
        tableView.layoutIfNeeded()
        let height = tableView.frame.height - tableView.contentSize.height
        return CGRect(x: tableView.frame.origin.x, y: tableView.frame.maxY - height, width: tableView.frame.width, height: height)
    }
}
