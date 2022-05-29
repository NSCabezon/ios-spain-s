//
//  SelectionListView.swift
//  TransferOperatives
//
//  Created by David Gálvez Alonso on 10/1/22.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SelectionListViewDelegate: AnyObject {
    func didSearchItem(_ searchItem: String)
    func didSelectItem(_ item: String)
}

final class SelectionListView: XibView {
    private enum Constants {
        static let firstIndexPath: IndexPath = IndexPath(row: NSNotFound, section: .zero)
        static let numberOfSections: Int = 1
        static let sectionHeight: CGFloat = 294.0
        enum Countries {
            static let titleKey: String = "chooseCountry_label_chooseCountry"
            static let inputPlaceholder: String = "chooseCountry_label_searchCountries"
            static let tableTitleKey: String = "chooseCountry_label_allCountries"
        }
        enum Currencies {
            static let titleKey: String = "chooseCurrency_label_selectCurrency"
            static let inputPlaceholder: String = "chooseCurrency_label_searchCurrency"
            static let tableTitleKey: String = "chooseCurrency_label_allCurrencies"
        }
        enum EmptyState {
            static let titleKey: String = "generic_label_emptyNoResults"
            static let subtitleKey: String = "sendMoney_label_emptyDontResultsSearch"
        }
    }
    
    enum SelectionType {
        case countries
        case currencies
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchInput: OneInputRegularView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateView: EmptyStateView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: SelectionListViewDelegate?
    private var selectionType: SelectionType = .countries {
        didSet {
            self.setLabelTexts()
            self.configureSearchInput()
        }
    }
    private lazy var searchInputViewModel: OneInputRegularViewModel = {
        return OneInputRegularViewModel(status: .inactive,
                                        text: "",
                                        placeholder: localized(self.selectionType == .countries ?
                                                                Constants.Countries.inputPlaceholder :
                                                                Constants.Currencies.inputPlaceholder),
                                        searchAction: self.searchDidPressed,
                                        resetText: true)
    }()
    private var carouselItems: [OneSmallSelectorListViewModel] = []
    private var listItems: [OneSmallSelectorListViewModel] = [] {
        didSet {
            self.updateContentVisibility()
            self.tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
    }
    
    func setSelectionType(_ type: SelectionType) {
        self.selectionType = type
        self.setAccessibilityIdentifiers()
    }
    
    func setItems(listItems: [OneSmallSelectorListViewModel],
                  carouselItems: [OneSmallSelectorListViewModel]) {
        self.listItems = listItems
        self.carouselItems = carouselItems
    }
    
    func clearInput() {
        self.searchInput.setupTextField(self.searchInputViewModel)
    }
}

private extension SelectionListView {
    func setupView() {
        self.configureView()
        self.configureTableView()
        self.configureEmptyStateView()
        self.configureLabels()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = Constants.sectionHeight
        self.registerCells()
    }
    
    func configureSearchInput() {
        self.searchInput.delegate = self
        self.clearInput()
    }
    
    func configureEmptyStateView() {
        self.emptyStateView.configure(
            titleKey: Constants.EmptyState.titleKey,
            infoKey: Constants.EmptyState.subtitleKey,
            buttonTitleKey: nil
        )
        self.emptyStateView.delegate = self
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.titleLabel.textColor = .oneLisboaGray
    }

    func searchDidPressed() {
        self.dismissKeyboard()
    }
    
    func registerCells() {
        self.tableView.register(SmallSelectorListTableViewCell.self, bundle: Bundle.module)
    }
    
    func updateContentVisibility() {
        guard self.listItems.isEmpty else {
            self.emptyStateView.isHidden = true
            self.tableView.isHidden = false
            return
        }
        self.emptyStateView.isHidden = false
        self.tableView.isHidden = true
    }
    
    func setAccessibilityInfo() {
        self.searchInput.isAccessibilityElement = true
        self.searchInput.accessibilityLabel = localized("voiceover_").text
        UIAccessibility.post(notification: .layoutChanged, argument: self.searchInput)
    }
    
    func setLabelTexts() {
        let titleText: String = {
            switch self.selectionType {
            case .countries:
                return Constants.Countries.titleKey
            case .currencies:
                return Constants.Currencies.titleKey
            }
        }()
        self.titleLabel.text = localized(titleText)
    }
    
    func setAccessibilityIdentifiers() {
        switch self.selectionType {
        case .countries:
            self.view?.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.chooseCountryViewCountries
            self.tableView.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.chooseCountryListCountries
            self.titleLabel.accessibilityIdentifier = Constants.Countries.titleKey
        case .currencies:
            self.view?.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.chooseCurrencyViewCurrencies
            self.tableView.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.chooseCurrencyListCurrencies
            self.titleLabel.accessibilityIdentifier = Constants.Currencies.titleKey
        }
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    func getHeaderSelectedCountry() -> OneSmallSelectorListViewModel? {
        guard self.carouselItems.first(where: { $0.status == .activated }) == nil else { return nil }
        return self.listItems.first(where: { $0.status == .activated })
    }
}

extension SelectionListView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SmallSelectorListTableViewCell.self, indexPath: indexPath)
        cell.configure(listItems[indexPath.row], index: indexPath.row, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = self.listItems[indexPath.row]
        guard selectedItem.status != .activated else {
            return
        }
        self.delegate?.didSelectItem(selectedItem.leftTextKey)
        self.tableView.scrollToRow(at: Constants.firstIndexPath, at: .bottom, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.searchInput.isTextFieldEmpty() else { return nil }
        let headerView = SelectionListHeaderView()
        headerView.delegate = self
        headerView.fillView(carouselItems: self.carouselItems, selectedItem: self.getHeaderSelectedCountry(), type: self.selectionType)
        headerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.searchInput.isTextFieldEmpty() ? UITableView.automaticDimension : .zero
    }
}

extension SelectionListView: OneInputRegularViewDelegate {
    func textDidChange(_ text: String) {
        self.delegate?.didSearchItem(text)
    }
    
    func shouldReturn() {
        self.dismissKeyboard()
    }
}

extension SelectionListView: EmptyStateViewDelegate {
    func didTapActionButton() {}
}

extension SelectionListView: SelectionListHeaderViewDelegate {
    func didSelectItem(_ item: OneSmallSelectorListViewModel) {
        self.delegate?.didSelectItem(item.leftTextKey)
    }
}

extension SelectionListView: AccessibilityCapable {}

extension SelectionListView: OneSmallSelectorListViewDelegate {
    func didSelectOneSmallSelectorListView(status: OneSmallSelectorListViewModel.Status, at index: Int) {
        guard let item = self.listItems[safe: index] else {
            return
        }
        self.didSelectItem(item)
    }
}
