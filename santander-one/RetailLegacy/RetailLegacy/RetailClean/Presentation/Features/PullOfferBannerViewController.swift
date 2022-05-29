import CoreFoundationLib
import UIKit
import UI

protocol PullOfferBannerPresenterProtocol: SideMenuCapable {
    func actionSelectedCell(index: Int)
}

class PullOfferBannerViewController: BaseViewController<PullOfferBannerPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topHeaderLabel: UILabel!
    @IBOutlet weak var topHeaderView: UIView!
    
    override class var storyboardName: String {
        return "PublicProducts"
    }

    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .white
    }
    
    var sections: [TableModelViewSection] {
        set {
            dataSource.clearSections()
            dataSource.addSections(newValue)
            tableView.reloadData()
        }
        get {
            return dataSource.sections
        }
    }
    
    var titleHeader: LocalizedStylableText? {
        didSet {
            if let title = titleHeader {
                topHeaderLabel.set(localizedStylableText: title)
            } else {
                topHeaderLabel.text = nil
            }
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    override func prepareView() {
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.backgroundColor = .uiBackground
        tableView.registerCells(["BannerTableViewCell"])
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        topHeaderView.backgroundColor = .sanGreyDark
        topHeaderLabel.applyStyle(LabelStylist(textColor: .uiBackground, font: .latoBold(size: 16), textAlignment: .center))
        titleHeader = CoreFoundationLib.localized("personalsProducts_label_selectionForYou")
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    func calculateHeight() {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

extension PullOfferBannerViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.actionSelectedCell(index: indexPath.row)
    }
}

extension PullOfferBannerViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
