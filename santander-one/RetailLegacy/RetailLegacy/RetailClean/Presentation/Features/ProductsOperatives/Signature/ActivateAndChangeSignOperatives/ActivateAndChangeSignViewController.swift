import UIKit
import UI
import CoreFoundationLib

final class ActivateAndChangeSignViewController: BaseViewController<ActivateAndChangeSignPresenterProtocol> {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var continueButton: RedButton!
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource.addSections(presenter.sections)
        self.setupTableView()
        self.view.backgroundColor = .uiBackground
        self.continueButton.configureHighlighted(font: .latoBold(size: 16))
        self.continueButton.set(localizedStylableText: presenter.buttonTitle, state: .normal)
        self.styledTitle = presenter.title
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(color: .white), for: .default)
        self.setAccessibilityIdentifiers()
    }
    
    override class var storyboardName: String {
        return "SignatureOperative"
    }
    
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    fileprivate func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.registerCells(["GenericHeaderViewCell", "SecureTextFieldTableViewCell"])
        self.tableView.dataSource = dataSource
        self.tableView.delegate = dataSource
        self.tableView.estimatedRowHeight = 127.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.backgroundColor = .uiBackground
    }
    
    private func setAccessibilityIdentifiers() {
        self.continueButton.accessibilityIdentifier = AccessibilityActivateAndChange.changeSignBtnContinue
        self.navigationBarTitleLabel.accessibilityIdentifier = AccessibilityChangePassword.personalAreaLabelSigningChange
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        self.presenter.confirmButtonTouched()
    }
}
