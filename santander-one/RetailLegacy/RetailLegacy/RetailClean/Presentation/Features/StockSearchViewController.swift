//

import UIKit
import UI

protocol StockSearchPresenterProtocol: Presenter {
    func textWasChanged(text: String)
    func willDisplayIndex(index: Int)
    func endDisplayIndex(index: Int)
    func selectIndex(index: Int)
    func toggleSideMenu()
}

class StockSearchViewController: BaseViewController<StockSearchPresenterProtocol>, ChangeTextFieldDelegate, UITextFieldDelegate {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var searchTextField: CustomTextField!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    private let grayImageView: UIView = UIImageView(image: Assets.image(named: "icnSearchGray"))
    private let redImageView: UIView = UIImageView(image: Assets.image(named: "icnSearchRed"))
    lazy var dataSource: StockSearchDataSource = {
        let dataSource = StockSearchDataSource(tableView: tableView)
        dataSource.delegate = self
        return dataSource
    }()
    override class var storyboardName: String {
        return "StockSearch"
    }
    
    override func viewDidLoad() {
        setUpView()
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Class Methods
    
    override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    func setHeader(text: LocalizedStylableText) {
        headerLabel.set(localizedStylableText: text)
    }
    
    func setPlaceholder(text: LocalizedStylableText) {
        searchTextField.setOnPlaceholder(localizedStylableText: text)
    }
    
    // MARK: - Private Methods
    
    private func setUpView() {
        separatorView.backgroundColor = .lisboaGray
        tableView.separatorStyle = .none
        tableView.backgroundColor = .uiBackground
        tableView.register(UINib(nibName: "SecondaryLoadingViewCell", bundle: .module), forCellReuseIdentifier: "SecondaryLoadingViewCell")
        tableView.register(UINib(nibName: "StockQuoteSearchViewCell", bundle: .module), forCellReuseIdentifier: "StockQuoteSearchViewCell")
        tableView.register(UINib(nibName: "StockSearchViewCell", bundle: .module), forCellReuseIdentifier: "StockSearchViewCell")
        tableView.register(UINib(nibName: "EmptyViewCell", bundle: .module), forCellReuseIdentifier: "EmptyViewCell")
        headerLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15)))
        (searchTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16), textAlignment: .left))
        searchTextField.leftView = grayImageView
        searchTextField.leftViewMode = .always
        searchTextField.borderStyle = .none
        searchTextField.layer.cornerRadius = 5
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.borderColor = UIColor.lisboaGray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .always
    }
    
    private func textFieldEndEditing (textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            searchTextField.leftView = grayImageView
        } else {
            searchTextField.leftView = redImageView
        }
    }
    
    // MARK: - ChangeTextFieldDelegate
    
    func willChangeText(textField: UITextField, text: String) {
        presenter.textWasChanged(text: text)
    }
    
    // MARK: - UITextFieldDelegate
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textFieldEndEditing(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldEndEditing(textField: textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextField.leftView = UIImageView(image: Assets.image(named: "icnSearchRed"))
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        presenter.textWasChanged(text: "")
        return true
    }
}

// MARK: - TableDataSourceDelegate

extension StockSearchViewController: TableDataSourceDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSource.validActionIndex(index: indexPath.section) {
            presenter.selectIndex(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSource.validActionIndex(index: indexPath.section) {
            presenter.willDisplayIndex(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSource.validActionIndex(index: indexPath.section) {
            presenter.endDisplayIndex(index: indexPath.row)
        }
    }
}

// MARK: - RootMenuController

extension StockSearchViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
