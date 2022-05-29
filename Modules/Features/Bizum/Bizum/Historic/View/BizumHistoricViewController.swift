import UIKit
import UI
import CoreFoundationLib
import ESUI

// MARK: - BizumHistoricViewProtocol

protocol BizumHistoricViewProtocol: DialogViewPresentationCapable {
    func showFeatureNotAvailableToast()
    func showSearchClearAction()
    func hiddeSearchClearAction()
    func clearSearch()
    func goToAllTab()
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
    func showResults(_ sections: [BizumHistoricSectionViewModel], totalItems: Int, isOnErrorMessage: Bool)
    func disableSelector()
}

// MARK: - BizumHistoricViewController

final class BizumHistoricViewController: UIViewController {
    var isSearchEnabled: Bool = true
    @IBOutlet private weak var segmentedControl: LisboaSegmentedControl!
    @IBOutlet private weak var textField: LisboaTextfield!
    @IBOutlet weak var tableView: UITableView!
    private let presenter: BizumHistoricPresenterProtocol
    private var sections: [BizumHistoricSectionViewModel]?
    private var searchTerm: String?
    private lazy var tableHeaderView: BizumHistoricTableHeaderView = {
        BizumHistoricTableHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
    }()
    private lazy var tableHeaderViewContainer: UIView = {
        let container = UIView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: tableView.frame.width,
                                                          height: 40.0)))
        container.addSubview(tableHeaderView)
        tableHeaderView.fullFit()
        return container
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 240.0).isActive = true
        view.backgroundColor = .clear
        let type = LoadingViewType.onView(view: view,
                                          frame: nil,
                                          position: .top,
                                          controller: self)
        let text = LoadingText(title: localized("generic_popup_loadingContent"),
                               subtitle: localized("loading_label_moment"))
        let info = LoadingInfo(type: type,
                               loadingText: text,
                               topInset: 15.0,
                               background: .clear,
                               loadingImageType: .points,
                               style: .onView)
        LoadingCreator.createAndShowLoading(info: info)
        return view
    }()
    
    var associatedDialogView: UIViewController {
        return self
    }
    private var isOnError: Bool = false
    let keyboardManager: KeyboardManager = KeyboardManager()

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: BizumHistoricPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.configureView()
        self.presenter.didLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }
}

// MARK: - BizumHistoricViewController - BizumHistoricViewProtocol

extension BizumHistoricViewController: BizumHistoricViewProtocol {
    func showFeatureNotAvailableToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func showSearchClearAction() {
        self.textField.configure(
            extraInfo: (
                Assets.image(named: "clearField"),
                action: { [weak self] in
                    self?.clearTextField()
                }
            )
        )
    }
    
    func disableSelector() {
        self.textField.field.isEnabled = false
    }
    
    func hiddeSearchClearAction() {
        self.textField.configure(extraInfo: nil)
    }
    
    func clearSearch() {
        self.textField.updateData(text: "")
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        self.loadingView.isHidden = false
        self.tableView.isHidden = true
        self.textField.isHidden = true
        self.segmentedControl.isEnabled = false
        completion?()
    }
    
    func hideLoadingView(_ completion: (() -> Void)?) {
        self.loadingView.isHidden = true
        self.tableView.isHidden = false
        self.textField.isHidden = false
        self.segmentedControl.isEnabled = true
        completion?()
    }
    
    func showResults(_ sections: [BizumHistoricSectionViewModel], totalItems: Int, isOnErrorMessage: Bool) {
        tableView.estimatedSectionHeaderHeight = sections.isEmpty ? 0 : 30
        self.sections = sections
        self.isOnError = isOnErrorMessage
        updateTableHeader(totalItems)
        tableView.reloadData()
    }
    
    func goToAllTab() {
        segmentedControl.selectedSegmentIndex = 0
    }
}

// MARK: - BizumHistoricViewController - NavigationBarWithSearchProtocol

extension BizumHistoricViewController: NavigationBarWithSearchProtocol {
    var searchButtonPosition: Int {
        return 1
    }
    
    func searchButtonPressed() {
        self.presenter.didSelectSearch()
    }
}

// MARK: - BizumHistoricViewController - Private

private extension BizumHistoricViewController {
    func configureView() {
        configureTextField()
        configureSegment()
        configTableView()
        configureLoadingView()
    }
    
    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .white,
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_historical",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions( .menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func configureTextField() {
        var textfiledStyle = LisboaTextFieldStyle.default
        textfiledStyle.fieldFont = UIFont.santander(size: 16)
        textfiledStyle.fieldTextColor = .lisboaGray
        textfiledStyle.containerViewBorderColor = UIColor.lightSky.cgColor
        textfiledStyle.verticalSeparatorBackgroundColor = UIColor.darkTurqLight
        textfiledStyle.extraInfoHorizontalSeparatorBackgroundColor = UIColor.lightSky
        let formmater = UIFormattedCustomTextField()
        formmater.setMaxLength(maxLength: 140)
        self.textField.configure(with: formmater,
                                 title: localized("search_hint_textConcept"),
                                 style: textfiledStyle,
                                 extraInfo: (Assets.image(named: "icnSearch"), action: nil),
                                 disabledActions: TextFieldActions.usuallyDisabledActions)
        self.textField.field.addTarget(self, action: #selector(textFieldDidChange),
                                       for: UIControl.Event.editingChanged)
        self.textField.field.autocapitalizationType = .none
        self.textField.field.autocorrectionType = .no
        self.textField.field.returnKeyType = .done
        self.textField.isHidden = false
        self.textField.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoryInputSearch
        self.view.shouldGroupAccessibilityChildren = true
    }
    
    func configureSegment() {
        self.segmentedControl.setup(with: ["bizum_tab_all", "bizum_tab_send", "bizum_tab_received", "bizum_tab_shopping"],
                                    accessibilityIdentifiers: [AccessibilityBizumHistoric.bizumTabAll,
                                                               AccessibilityBizumHistoric.bizumTabSend,
                                                               AccessibilityBizumHistoric.bizumTabRecived,
                                                               AccessibilityBizumHistoric.bizumTabShoping])
        self.segmentedControl.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricSegmentedHistoricList
        self.segmentedControl.backgroundColor = .skyGray
        self.segmentedControl.addTarget(self, action: #selector(didChangeSegment(sender:)), for: .valueChanged)
    }
    
    func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricList
        tableView.register(UINib(nibName: BizumHistoricSimpleTableViewCell.identifier,
                                 bundle: .module),
                           forCellReuseIdentifier: BizumHistoricSimpleTableViewCell.identifier)
        tableView.register(UINib(nibName: BizumHistoricMultipleTableViewCell.identifier,
                                 bundle: .module),
                           forCellReuseIdentifier: BizumHistoricMultipleTableViewCell.identifier)
        tableView.register(UINib(nibName: BizumHistoricSectionHeaderView.identifier,
                                 bundle: .module),
                           forHeaderFooterViewReuseIdentifier: BizumHistoricSectionHeaderView.identifier)
        tableView.register(UINib(nibName: BizumEmptyTableViewCell.identifier,
                                 bundle: .module),
                           forCellReuseIdentifier: BizumEmptyTableViewCell.identifier)
    }
    
    func configureLoadingView() {
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50.0),
                                     loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     loadingView.topAnchor.constraint(equalTo: self.textField.bottomAnchor)])
        loadingView.isHidden = true
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        updateSearchIcon(text: text)
        searchTerm = text.isEmpty ? nil : text
        presenter.didSearchText(text)
    }
    
    func updateSearchIcon(text: String) {
        if text.isEmpty {
            textField.configure(extraInfo: (Assets.image(named: "icnSearch"), action: nil))
        } else {
            textField.configure(extraInfo: (Assets.image(named: "clearField"),
                                            action: clearTextField))
        }
    }
    
    @objc func clearTextField() {
        guard let optionalSearchTerm = self.searchTerm, !optionalSearchTerm.isEmpty else { return }
        self.textField.updateData(text: "")
        self.textField.endEditing(true)
        self.presenter.didClearSearch()
        searchTerm = nil
        updateTableHeader(0)
    }
    
    @objc func didChangeSegment(sender: LisboaSegmentedControl) {
        clearTextField()
        switch sender.selectedSegmentIndex {
        case 0:
            self.presenter.didSelectAll()
        case 1:
            self.presenter.didSelectSend()
        case 2:
            self.presenter.didSelectReceived()
        case 3:
            self.presenter.didSelectBuy()
        default:
            break
        }
        searchTerm = nil
    }
    
    func updateTableHeader(_ totalItems: Int) {
        if searchTerm == nil {
            tableView.tableHeaderView = nil
        } else {
            tableHeaderView.setTitle(results: totalItems)
            tableView.tableHeaderView = tableHeaderViewContainer
        }
    }
}

extension BizumHistoricViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = sections else { return 0 }
        return sections.isEmpty ? 1 : sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = sections else { return 0 }
        return sections.isEmpty ? 1 : sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sections = sections else { return UITableViewCell() }
        if sections.isEmpty {
            return getEmptyCell(indexPath, searchTerm: searchTerm)
        } else {
            let item = sections[indexPath.section].items[indexPath.row]
            let isSeparatorHidden = indexPath.row == sections[indexPath.section].items.count - 1
            switch item {
            case let item as BizumHistoricMultipleCellViewModel:
                return getMultipleCell(item, indexPath: indexPath, isSeparatorHidden: isSeparatorHidden)
            case let item as BizumHistoricSimpleCellViewModel:
                return getSimpleCell(item, indexPath: indexPath, isSeparatorHidden: isSeparatorHidden)
            default:
                return UITableViewCell()
            }
        }
    }
    
    func getSimpleCell(_ viewModel: BizumHistoricSimpleCellViewModel, indexPath: IndexPath, isSeparatorHidden: Bool) -> UITableViewCell {
        guard let historicSimpleCell = tableView.dequeueReusableCell(withIdentifier: BizumHistoricSimpleTableViewCell.identifier, for: indexPath) as? BizumHistoricSimpleTableViewCell else {
            return UITableViewCell()
        }
        historicSimpleCell.delegate = self
        historicSimpleCell.set(viewModel)
        historicSimpleCell.hideSeparatorView(isSeparatorHidden)
        return historicSimpleCell
    }
    
    func getMultipleCell(_ viewModel: BizumHistoricMultipleCellViewModel, indexPath: IndexPath, isSeparatorHidden: Bool) -> UITableViewCell {
        guard let historicMultipleCell = tableView.dequeueReusableCell(withIdentifier: BizumHistoricMultipleTableViewCell.identifier, for: indexPath) as? BizumHistoricMultipleTableViewCell else {
            return UITableViewCell()
        }
        historicMultipleCell.set(viewModel)
        historicMultipleCell.hideSeparatorView(isSeparatorHidden)
        return historicMultipleCell
    }
    
    func getEmptyCell(_ indexPath: IndexPath, searchTerm: String?) -> UITableViewCell {
        guard let emptyCell = tableView.dequeueReusableCell(withIdentifier: BizumEmptyTableViewCell.identifier, for: indexPath) as? BizumEmptyTableViewCell else {
            return UITableViewCell()
        }
        let errorMessage: LocalizedStylableText = !isOnError
            ? localized("bizum_title_emptyReceived")
            : localized("generic_label_emptyError")
        searchTerm != nil
            ? emptyCell.setSearchTerm(term: searchTerm)
            : emptyCell.setEmptyResults(errorMessage)
        return emptyCell
    }
}

extension BizumHistoricViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sections = sections, !sections.isEmpty {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BizumHistoricSectionHeaderView.identifier) as? BizumHistoricSectionHeaderView
            header?.hideSeparator(section == 0)
            header?.setTitle(title: sections[section].dateFormatted.text)
            header?.contentView.backgroundColor = UIColor(white: 1, alpha: 0.9)
            header?.tintColor = UIColor(white: 1, alpha: 0.9)
            tableView.removeUnnecessaryHeaderTopPadding()
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sections = sections, !sections.isEmpty else { return }
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        self.presenter.didSelectDetail(item)
    }
}

extension BizumHistoricViewController: BizumHistoricTableViewCellDelegate {
    func didSelectActionWithViewModel(_ viewModel: BizumAvailableActionViewModel) {
        self.presenter.didSelectBizumAction(viewModel)
    }
}

extension BizumHistoricViewController: KeyboardManagerDelegate { }
