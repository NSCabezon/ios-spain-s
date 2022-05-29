//
//  CurrencyCountryFinderViewController.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 25/05/2020.
//

import CoreFoundationLib
import UI

protocol CurrencyCountryFinderViewControllerDelegate: AnyObject {
    func didSelectCurrency(_ currency: SepaCurrencyInfoEntity)
    func didSelectCountry(_ country: SepaCountryInfoEntity, currency: SepaCurrencyInfoEntity)
    func didSelectCloseBanner(_ offerId: String?)
    func didSelectBanner()
}

protocol CurrencyCountryFinderViewControllerProtocol: AnyObject {
    func didUpdateViewModel(_ viewModel: CountryCurrencyViewModel)
    func setOfferBannerWithUrl(_ url: String?, offerId: String?)
}

public class CurrencyCountryFinderViewController: UIViewController {
    @IBOutlet weak private var topTitle: UILabel!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var backgroundView: UIView!
    @IBOutlet weak private var headerSeparator: UIView!
    @IBOutlet weak private var searchTextField: LisboaTextfield!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var locationView: UIView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    @IBOutlet weak private var closeBannerImageView: UIImageView!
    @IBOutlet weak private var clearButton: UIButton!
    @IBOutlet weak private var clearView: UIView!
    @IBOutlet weak private var clearImageView: UIImageView!
    @IBOutlet weak private var locationHeightConstraint: NSLayoutConstraint!
    private var quickOptionSelector: OptionsSelectorView?
    weak var delegate: CurrencyCountryFinderViewControllerDelegate?
    private let tableViewDefaultTopConstraint: CGFloat = 170.0
    private let maxCharacters = 140
    private var viewModel: CountryCurrencyViewModel?
    private var viewControllerDataType: SepaSearchOperation?
    private var noResultsViewVisible: Bool = false
    private var lastSearchedWords: String = ""
    private var offerId: String?
    private lazy var searchTextFieldStyle: LisboaTextFieldStyle = {
        var lisboaTextFieldStyle = LisboaTextFieldStyle.default
        lisboaTextFieldStyle.fieldFont = UIFont.santander(family: .text, type: .regular, size: 16)
        lisboaTextFieldStyle.fieldTextColor = .lisboaGray
        lisboaTextFieldStyle.containerViewBorderColor = UIColor.lightSky.cgColor
        lisboaTextFieldStyle.verticalSeparatorBackgroundColor = UIColor.darkTurqLight
        return lisboaTextFieldStyle
    }()
    private lazy var emptyView: SearchEmptyView = {
        let emptyView = SearchEmptyView()
        emptyView.backgroundColor = .white
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.heightAnchor.constraint(equalToConstant: 210.0).isActive = true
        return emptyView
    }()
    let presenter: CurrencyCountryFinderPresenterProtocol
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: CurrencyCountryFinderPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(presenter: CurrencyCountryFinderPresenterProtocol) {
        self.init(nibName: "CurrencyCountryFinderViewController", bundle: .module, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        configureView()
    }
}
// MARK: - CurrencyCountryFinderViewControllerProtocol
extension CurrencyCountryFinderViewController: CurrencyCountryFinderViewControllerProtocol {
    func didUpdateViewModel(_ viewModel: CountryCurrencyViewModel) {
        viewControllerDataType = viewModel.dataType
        if viewModel.numberOfItems > 0 {
            if noResultsViewVisible {
                self.hideNoResultsView()
            }
            self.tableView.isHidden = false
            self.viewModel = viewModel
            self.tableView.reloadData()
        } else {
            self.showNoResultsView()
        }
    }
        
    func setOfferBannerWithUrl(_ url: String?, offerId: String?) {
        self.offerId = offerId
        if let urlUnwrapped = url {
            self.bannerImageView.loadImage(urlString: urlUnwrapped) { [weak self] in
                if let image = self?.bannerImageView?.image {
                    let aspectRatio = image.size.height / image.size.width
                    let height = ((self?.bannerImageView?.frame.width ?? 0.0) * aspectRatio)

                    self?.onDrawFinished(newHeight: height)
                }
            }
        } else {
            self.bannerImageView.image = nil
        }        
        closeBannerImageView?.image = Assets.image(named: "icnXPullofferCopy")
    }
}

// MARK: - UITextFieldDelegate
extension CurrencyCountryFinderViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        switchToSearchMode()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let count = textField.text?.count, count >= maxCharacters else { return true }
        return string.isEmpty
    }
}

// MARK: - OptionsSelectorViewDelegate
extension CurrencyCountryFinderViewController: OptionsSelectorViewDelegate {
    public func didSelectItem(_ item: OptionsSelectorViewItems) {
        guard let dataType = viewControllerDataType, let viewModel = self.viewModel else {
            return
        }
        switch dataType {
        case .countries:
            if let selectedItem = viewModel.countryItemWithCode(item.subtitle) {
                let currency = viewModel.currencyItemWithCode(selectedItem.currency ?? "")
                self.delegate?.didSelectCountry(selectedItem, currency: currency)
            }
        case .currency:
            let selectedItem = viewModel.currencyItemWithCode(item.subtitle)
            self.delegate?.didSelectCurrency(selectedItem)
        }
        self.dismissViewController()
    }
}

// MARK: - Private methods
private extension CurrencyCountryFinderViewController {
    func configureView() {
        setupSearchTextField()
        setupNavigationBar()
        setupTableView()
        setupQuickOptions()
        quickOptionSelector?.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectLocation))
        bannerImageView.isUserInteractionEnabled = true
        bannerImageView.addGestureRecognizer(tapGestureRecognizer)
        bannerImageView.clipsToBounds = true
        clearView.isHidden = true
        clearImageView.image = Assets.image(named: "clearField")
    }
    
    func setupSearchTextField() {
        searchTextField.configure(with: nil,
                            title: localized("transfer_hint_searchCountry"),
                            style: searchTextFieldStyle,
                            extraInfo: (image: Assets.image(named: "icnSearch"), action: { self.searchTextField.field.becomeFirstResponder() }),
                            disabledActions: TextFieldActions.usuallyDisabledActions,
                            imageAccessibilityIdentifier: AccessibilityTransfers.icnSearch)
        searchTextField.field.addTarget(self, action: #selector(searchTextDidChange),
                                    for: UIControl.Event.editingChanged)
        searchTextField.field.autocapitalizationType = .none
        searchTextField.field.autocorrectionType = .no
        searchTextField.field.returnKeyType = .done
        self.searchTextField.fieldDelegate = self
        switch presenter.operationType {
        case .countries:
            self.topTitle.text = localized("toolbar_title_country")
            self.searchTextField.updateTitle(localized("transfer_hint_searchCountry"))
            self.topTitle.accessibilityIdentifier = AccessibilityTransfers.genericToolbarTitleCountry
            self.quickOptionSelector?.accessibilityIdentifier = AccessibilityTransfers.countryCollection
            self.tableView.accessibilityIdentifier = AccessibilityTransfers.countryList
        case .currency:
            self.topTitle.text = localized("toolbar_title_currency")
            self.searchTextField.updateTitle(localized("transfer_hint_searchCurrency"))
            self.topTitle.accessibilityIdentifier = AccessibilityTransfers.genericToolbarTitleCurrency
            self.quickOptionSelector?.accessibilityIdentifier = AccessibilityTransfers.currencyCollection
            self.tableView.accessibilityIdentifier = AccessibilityTransfers.currencyList
        }
        self.searchTextField.accessibilityIdentifier = AccessibilityTransfers.searchInputText.rawValue
        self.searchTextField.field.accessibilityIdentifier = AccessibilityTransfers.searchInputTextValue.rawValue
    }

    func switchToSearchMode() {
        self.tableView.tableHeaderView = nil
    }
    
    @objc func searchTextDidChange() {
        guard let text = searchTextField.text else {
            return
        }
        lastSearchedWords = text
        clearView.isHidden = text.isEmpty
        if text.isEmpty {
            presenter.resetSearch()
            self.tableView.tableHeaderView = self.quickOptionSelector
        } else {
            self.presenter.searchFor(text)
        }
    }
    
    @IBAction func clearTextField() {
        self.searchTextField.updateData(text: "")
        presenter.resetSearch()
        self.tableView.tableHeaderView = self.quickOptionSelector
        self.searchTextField.endEditing(true)
        clearView.isHidden = true
    }
    
    func showNoResultsView() {
        self.noResultsViewVisible = true
        self.tableView.isHidden = true
        self.emptyView.searchTerm = lastSearchedWords
        self.view.addSubview(self.emptyView)
        NSLayoutConstraint.activate([self.emptyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     self.emptyView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     self.emptyView.topAnchor.constraint(equalTo: self.searchTextField.bottomAnchor)])
    }
    
    func hideNoResultsView() {
        self.noResultsViewVisible = false
        self.emptyView.removeFromSuperview()
        self.tableView.isHidden = false
    }
    
    @objc private func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
        self.presenter.didSelectDismiss()
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorColor = .mediumSkyGray
        self.tableView.register(CurrencySearchTableViewCell.self, forCellReuseIdentifier: CurrencySearchTableViewCell.identifier)
        self.tableView.register(CountrySearchTableViewCell.self, forCellReuseIdentifier: CountrySearchTableViewCell.identifier)
    }
    
    func setupNavigationBar() {
        self.topTitle.font = UIFont.santander(family: FontFamily.headline, type: FontType.bold, size: 18.0)
        self.topTitle.textColor = UIColor.santanderRed
        self.closeButton.setImageName("icnClose", withTintColor: .santanderRed)
        self.closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        self.backgroundView.backgroundColor = .skyGray
        self.headerSeparator.backgroundColor = .mediumSkyGray
        self.view.backgroundColor = .white
    }
    
    func setupQuickOptions() {
        self.quickOptionSelector = OptionsSelectorView(frame: CGRect(x: 0, y: 0, width: 0, height: 166))
        self.tableView.tableHeaderView = self.quickOptionSelector
        guard let viewModel = self.viewModel, let currentDataType = self.viewControllerDataType else {
            return
        }
        let viewModelItems = viewModel.getFirstSixsForOperationType(currentDataType)
        let quickActionItems = viewModelItems.compactMap({OptionsSelectorViewItems(title: $0.name, subtitle: $0.code)})
        let enabledSubtitle = currentDataType == .currency ? true : false
        self.quickOptionSelector?.setItems(quickActionItems, showSubtitle: enabledSubtitle, selectedCode: viewModel.selectedItemCode)
    }
    
    var defaultSelectedIndexPath: IndexPath? {
        if let index = self.viewModel?.getSelectedItemIndex() {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    // MARK: - PullOffer functions
    
    @objc func selectLocation() {
        self.delegate?.didSelectBanner()
    }
           
    @IBAction func closeBannerView() {
        locationHeightConstraint.constant = 0
        locationView.isHidden = true
        self.delegate?.didSelectCloseBanner(self.offerId)
    }
        
    func onDrawFinished(newHeight: CGFloat?) {
        UIView.performWithoutAnimation {
            if let newHeight = newHeight, newHeight > 0 {
                self.locationHeightConstraint.constant = newHeight
                self.locationView.setNeedsLayout()
                self.locationView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CurrencyCountryFinderViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel?.numberOfItems ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel?.dataType == .currency, let item = viewModel?.currencyModelItemAtIndex(indexPath.row) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CurrencySearchTableViewCell.identifier, for: indexPath) as? CurrencySearchTableViewCell {
                cell.configureWithItem(item)
                cell.accessibilityIdentifier = AccessibilityTransfers.btnList.rawValue
                return cell
            }
        } else if viewModel?.dataType == .countries, let item = viewModel?.countryModelItemAtIndex(indexPath.row) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CountrySearchTableViewCell.identifier, for: indexPath) as? CountrySearchTableViewCell {
                cell.configureWithItem(item)
                cell.accessibilityIdentifier = AccessibilityTransfers.btnList.rawValue
                return cell
            }
        }
        
        return  UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension CurrencyCountryFinderViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = self.viewModel else {
            return
        }
        switch viewModel.dataType {
        case .countries:
            guard
                let item = viewModel.countryItemAtIndex(indexPath.row) else {
                return
            }
            let currencyEntity = viewModel.currencyItemWithCode(item.currency ?? "")
            self.delegate?.didSelectCountry(item, currency: currencyEntity)
        case .currency:
            guard let item = viewModel.currencyItemAtIndex(indexPath.row) else {
                return
            }
            self.delegate?.didSelectCurrency(item)
        }
        self.dismissViewController()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == defaultSelectedIndexPath {
            cell.setSelected(true, animated: false)
        }
    }
}
