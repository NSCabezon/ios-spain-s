import UIKit

protocol InsertPhoneSignUpCesCardPresenterProtocol: Presenter {
    var infoTitle: LocalizedStylableText { get }
    var toolTipMessage: LocalizedStylableText { get }
    var placeholderText: LocalizedStylableText { get }
    func willChangeText(text: String?)
    func onContinueButtonClicked()
}

class InsertPhoneSignUpCesCardViewController: BaseViewController<InsertPhoneSignUpCesCardPresenterProtocol>, UITextViewDelegate, ChangeTextViewDelegate {
    
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerButton: UIView!
    @IBOutlet weak var continueButton: RedButton!
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "OperativeLabelTableViewCell", bundle: .module), forCellReuseIdentifier: "OperativeLabelTableViewCell")
        tableView.register(UINib(nibName: "OperativePhoneTextFieldTableViewCell", bundle: .module), forCellReuseIdentifier: "OperativePhoneTextFieldTableViewCell")
        tableView.register(UINib(nibName: "GenericHeaderViewCell", bundle: .module), forCellReuseIdentifier: "GenericHeaderViewCell")
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
    }
    
    func prepareNavigationBar() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(actionInfo(_:)), for: .touchUpInside)
        navigationItem.setInfoTitle(presenter.infoTitle, button: button)
    }
    
    @objc func actionInfo(_ sender: UIButton) {
        showToolTip(sender)
    }
    
    private func showToolTip(_ sender: UIButton) {
        ToolTip.displayToolTip(title: nil, description: nil, descriptionLocalized: presenter.toolTipMessage, sourceView: sender, sourceRect: CGRect(x: sender.bounds.origin.x, y: -10, width: sender.bounds.width, height: sender.bounds.height), viewController: self, dissapearAfter: nil)
    }
    
    // MARK: - ChangeTextViewDelegate
    
    func willChangeText(textView: UITextView, text: String) {
        presenter.willChangeText(text: text)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .sanGreyMedium {
            textView.text = ""
            textView.textColor = .sanRed
            textView.font = UIFont.latoLight(size: 22)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.set(localizedStylableText: presenter.placeholderText)
            textView.textColor = .sanGreyMedium
            textView.font = UIFont.latoItalic(size: 14)
        }
    }
}
