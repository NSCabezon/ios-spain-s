import UIKit

protocol ProductDetailInfoPresenterProtocol {
    var productInfo: [TableModelViewSection] { get }
}

let infoCellIdentifier = "ProductDetailInfoCell"
let secondaryLoadingCellIndentifier = "SecondaryLoadingViewCell"
let firstSection = "CardDetailFirstSectionTableViewCell"
let changeAliasCellIdentifier = "ChangeAliasTableViewCell"

class ProductDetailInfoViewController: BaseViewController<ProductDetailInfoPresenterProtocol>, ToolTipDisplayer, MultiTableViewSectionsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
   
    override class var storyboardName: String {
        return "ProductDetail"
    }
    
    lazy var dataSource: ProductDetailInfoDataSource = {
        return ProductDetailInfoDataSource(items: presenter.productInfo)
    }()
    
    override func prepareView() {
        super.prepareView()
        tableView.backgroundColor = .uiBackground
        tableView.registerCells([firstSection, infoCellIdentifier, secondaryLoadingCellIndentifier, changeAliasCellIdentifier])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        dataSource.delegate = presenter as? ProductDetailInfoDataSourceDelegate
        dataSource.toolTipDelegate = self
    }
    
    func reloadData() {
        dataSource.items = presenter.productInfo
        tableView.reloadData()
    }
}
