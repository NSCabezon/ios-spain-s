import UIKit
import UI

protocol OnePayTransferFavouritesPresenterProtocol: Presenter {
    func selectedIndex(index: Int)
    func onCloseButtonTouched()
}

class OnePayTransferFavouritesViewController: BaseViewController<OnePayTransferFavouritesPresenterProtocol>, TableDataSourceDelegate {
    
    private enum Constants {
        static let closeButtonImage = "icnCloseModal"
    }
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var closeButton: UIButton!

    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    @IBAction private func onCloseButtonTouched(_ sender: UIButton) {
        presenter.onCloseButtonTouched()
    }
    
    func setTitle(title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["FavoriteTransferRecipientViewCell", "EmptyViewCell"])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110.0
        tableView.backgroundColor = .clear
        tableView.drawBorder(cornerRadius: 5.0, color: .uiWhite)
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 18)))
        separatorView.backgroundColor = .sanRed
        borderView.backgroundColor = .uiWhite
        borderView.drawRoundedAndShadowed()
        view.isOpaque = false
        view.backgroundColor = UIColor.sanGreyDark.withAlphaComponent(0.7)
        closeButton.setImage(Assets.image(named: Constants.closeButtonImage), for: .normal)
    }
    
    // MARK: - OnePayTransferSelectorViewController
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectedIndex(index: indexPath.row)
    }
}
