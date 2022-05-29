import UIKit
import UI
import CoreFoundationLib

protocol TransferSearchableConfigurationSelectionPresenterProtocol: Presenter {
    func userDidSearch(_ term: String)
    func didSelectIndex(_ index: Int)
}

class TransferSearchableConfigurationSelectionViewController: BaseViewController<TransferSearchableConfigurationSelectionPresenterProtocol>, ChangeTextFieldDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var accountHeaderContainerView: UIView!
    @IBOutlet private weak var searchTextField: CustomTextField!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountHeaderContainerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    // MARK: - Private attributes
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.separatorStyle = .none
        tableView.registerCells(["TransferSearchableConfigurationFavsTableViewCell", "GenericHeaderViewCell", "EmptyViewCell"])
        tableView.register(BaseViewCell.self, forCellReuseIdentifier: "BaseViewCell")
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        
        locationView.backgroundColor = .clear
        locationView.clipsToBounds = false
        
        setupTextField()
    }
    
    func clearSections() {
        dataSource.clearSections()
    }
    
    func setHiddenHeader(hidden: Bool) {
        accountHeaderContainerView.isHidden = hidden
    }
    
    func setHeader(_ headerViewModel: AccountHeaderViewModel) {
        guard let accountHeaderView = AccountOperativeHeaderView.instantiateFromNib() else { return }
        headerViewModel.configure(accountHeaderView)
        accountHeaderContainerView.translatesAutoresizingMaskIntoConstraints = false
        accountHeaderContainerView.addSubview(accountHeaderView)
        accountHeaderView.topAnchor.constraint(equalTo: accountHeaderContainerView.topAnchor).isActive = true
        accountHeaderView.bottomAnchor.constraint(equalTo: accountHeaderContainerView.bottomAnchor).isActive = true
        accountHeaderView.leadingAnchor.constraint(equalTo: accountHeaderContainerView.leadingAnchor).isActive = true
        accountHeaderView.trailingAnchor.constraint(equalTo: accountHeaderContainerView.trailingAnchor).isActive = true
    }
    
    // MARK: - Private methods
    
    fileprivate func setupTextField() {
        (searchTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16), textAlignment: .left))
        searchTextField.leftView = UIImageView(image: Assets.image(named: "icnSearchGray"))
        searchTextField.leftViewMode = .always
        searchTextField.borderStyle = .none
        searchTextField.layer.cornerRadius = 5
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.borderColor = UIColor.lisboaGray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .always
        searchTextField.backgroundColor = .uiWhite
        self.searchTextField.accessibilityIdentifier = AccessibilityTransferHome.seachTextView
    }
    
    // MARK: - ChangeTextFieldDelegate
    
    func willChangeText(textField: UITextField, text: String) {
        if text.isEmpty {
            searchTextField.leftView = UIImageView(image: Assets.image(named: "icnSearchGray"))
        } else {
            searchTextField.leftView = UIImageView(image: Assets.image(named: "icnSearchRed"))
        }
        presenter.userDidSearch(text)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        presenter.userDidSearch("")
        searchTextField.leftView = UIImageView(image: Assets.image(named: "icnSearchGray"))
        return true
    }
    
    func hideBannerView() {
        locationHeightConstraint.constant = 0
        locationView.isHidden = true
        separatorView.isHidden = true
        tableViewBottomConstraint.isActive = false
        let constraint: NSLayoutConstraint = NSLayoutConstraint(item: tableView as UITableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        constraint.isActive = true
    }
    
    func onDrawFinished(newHeight: Float?) {
        UIView.performWithoutAnimation {
            if let newHeight = newHeight, newHeight > 0 {
                self.locationHeightConstraint.constant = CGFloat(newHeight)
                
                self.locationView.setNeedsLayout()
                self.locationView.layoutIfNeeded()
                self.locationView.layoutSubviews()
            }
        }
    }
}

extension TransferSearchableConfigurationSelectionViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectIndex(indexPath.row)
    }
}
