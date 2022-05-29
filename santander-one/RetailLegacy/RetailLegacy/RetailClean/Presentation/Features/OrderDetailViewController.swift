//

import UIKit

protocol OrderDetailPresenterProtocol: SideMenuCapable {
    var contentTitle: LocalizedStylableText { get }
    var moreInfo: LocalizedStylableText { get }
    var cancelOrder: LocalizedStylableText { get }
    var sections: [TableModelViewSection] { get }
    func toggleSideMenu()
    func cancelOrderButtonTouched()
    func moreInfoAction()
}

class OrderDetailViewController: BaseViewController<OrderDetailPresenterProtocol> {
    
    @IBOutlet weak var contentView: ContentViewShadow!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelOrderButton: RedButton!
    @IBOutlet weak var containerCancelButton: UIView!
    @IBOutlet weak var containerCancelButtonHeight: NSLayoutConstraint!

    //Margins
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    private var tableViewHeight: CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }
    
    override class var storyboardName: String {
        return "OrderDetail"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        
        contentView.drawRoundedAndShadowed()
        contentTitleLabel.applyStyle(LabelStylist(textColor: .uiBlack,
                                                  font: UIFont.latoSemibold(size: 14),
                                                  textAlignment: .center))
        moreInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium,
                                              font: UIFont.latoRegular(size: 14),
                                              textAlignment: .center))
        
        contentTitleLabel.set(localizedStylableText: presenter.contentTitle)
        moreInfoLabel.set(localizedStylableText: presenter.moreInfo)
        cancelOrderButton.configure()
        cancelOrderButton.set(localizedStylableText: presenter.cancelOrder, state: .normal)
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "OrderHeaderStatusTableViewCell", bundle: .module), forCellReuseIdentifier: "OrderHeaderStatusTableViewCell")
        tableView.register(UINib(nibName: "OrderDetailViewCell", bundle: .module), forCellReuseIdentifier: "OrderDetailViewCell")
        tableView.register(UINib(nibName: "SecondaryLoadingViewCell", bundle: .module), forCellReuseIdentifier: "SecondaryLoadingViewCell")
        tableView.backgroundColor = .clear
        tableView.dataSource = dataSource
    }
    
    func reloadData() {
        dataSource.addSections(presenter.sections)
        tableView.reloadData()
        tableHeight.constant = tableViewHeight
    }
    
    func hiddeCancelButton() {
        containerCancelButton.isHidden = true
        containerCancelButtonHeight.constant = 0
    }
    
    override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    @IBAction func moreInfoAction(_ sender: UITapGestureRecognizer) {
        presenter.moreInfoAction()
    }
    
    @IBAction func cancelOrderButtonAction(_ sender: RedButton) {
        presenter.cancelOrderButtonTouched()
    }
}

// MARK: - Enable side menu
extension OrderDetailViewController: RootMenuController {
    
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
    
}
