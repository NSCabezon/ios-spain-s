import UIKit
import UI

protocol LandingPushPresenterProtocol {
    func goToAppPressed()
    func closePressed()
    func selected(index: Int)
}

class LandingPushViewController: BaseViewController<LandingPushPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sanButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var goToAppButton: WhiteButton!
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let tableDataSource = TableDataSource()
        tableDataSource.delegate = self
        return tableDataSource
    }()
    
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    override class var storyboardName: String {
        return "Mailbox"
    }
    
    override func prepareView() {
        super.prepareView()
        if #available(iOS 11.0, *) {
            tableView.insetsContentViewsToSafeArea = false
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.separatorStyle = .none
        tableView.registerCells(["LandingPushHeaderTableViewCell", "LandingPushDeeplinkTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        
        goToAppButton.configureHighlighted(font: .santanderTextBold(size: 16))
        goToAppButton.set(localizedStylableText: stringLoader.getString("landingPush_buttom_openApp"), state: .normal)
        goToAppButton.onTouchAction = { [weak self] _ in
            self?.presenter.goToAppPressed()
        }
        sanButton.setImage(Assets.image(named: "icnSanWhiteShadowed")?.withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.setImage(Assets.image(named: "icnCloseLandingShadowed")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        presenter.closePressed()
    }
    
    @IBAction func sanIconClicked(_ sender: Any) {
        presenter.goToAppPressed()
    }
}

extension LandingPushViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: false)
            presenter.selected(index: indexPath.row)
        }
    }
}
