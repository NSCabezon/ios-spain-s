import UIKit
import CoreFoundationLib

protocol UpdateUsualTransferCountryCurrencyPresenterProtocol: Presenter {
    func onContinueButtonClicked()
    func onCountryButtonClicked()
    func onCurrencyButtonClicked()
    
}

class UpdateUsualTransferCountryCurrencyViewController: BaseViewController<UpdateUsualTransferCountryCurrencyPresenterProtocol>, TableDataSourceDelegate {
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet weak var separtorView: UIView!
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    var progressBarBackgroundColorFromPresenter: UIColor = .uiWhite

    override var progressBarBackgroundColor: UIColor? {
        return self.progressBarBackgroundColorFromPresenter
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    @IBAction private func onContinueButtonClicked(_ sender: UIButton) {
        presenter.onContinueButtonClicked()
    }
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["TitledTableModelViewHeader", "OperativeLabelTableViewCell", "OnePayTransferSelectorCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
        separtorView.backgroundColor = .lisboaGray
        self.navigationController?.navigationBar.setNavigationBarColor(.uiWhite)
    }
    
    func reloadCountrySection() {
        tableView.reloadSections([0], with: .none)
    }
    
    func reloadCurrencySection() {
        tableView.reloadSections([1], with: .none)
    }
    
    // MARK: - UpdateUsualTransferCountryCurrencyViewController
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            presenter.onCountryButtonClicked()
        case 1:
            presenter.onCurrencyButtonClicked()
        default:
            break
        }
    }
}
