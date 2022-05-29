//
//  SendMoneyDestinationAccountFullFavoritesListView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 30/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SendMoneyDestinationAccountFullFavoritesListViewDelegate: AnyObject {
    func didSearchFavorite(text: String)
    func didSelectFavorite(_ favorite: OneFavoriteContactCardViewModel)
    func didTapAddNewContact()
}

final class SendMoneyDestinationAccountFullFavoritesListView: XibView {
    private enum Constants {
        static let firstIndexPath: IndexPath = IndexPath(row: .zero, section: .zero)
        static let numberOfSections: Int = 1
        enum Input {
            static let placeholder: String = "sendMoney_label_findFavorites"
        }
        enum EmptyState {
            static let title: String = "sendMoney_label_emptyContactNotfound"
            static let subtitle: String = "sendMoney_label_emptyAddNewContact"
            static let button: String = "sendMoney_button_addNewContact"
        }
    }

    @IBOutlet private weak var searchInput: OneInputRegularView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateView: EmptyStateView!
    @IBOutlet private weak var loadingContainerView: UIView!
    @IBOutlet private weak var loadingImageView: UIImageView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: SendMoneyDestinationAccountFullFavoritesListViewDelegate?
    private lazy var searchInputViewModel: OneInputRegularViewModel = {
        return OneInputRegularViewModel(status: .inactive,
                                        text: "",
                                        placeholder: localized(Constants.Input.placeholder),
                                        searchAction: self.searchDidPressed,
                                        resetText: false,
                                        accessibilitySuffix: AccessibilitySendMoneyDestination.AllFavorites.allFavoritesSuffix)
    }()
    private var favorites: [OneFavoriteContactCardViewModel] = [] {
        didSet {
            self.isLoading = false
            self.updateContentVisibility()
            self.tableView.reloadData()
        }
    }
    private var isLoading: Bool = true {
        didSet {
            self.updateContentVisibility()
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
    
    func setFavorites(_ favorites: [OneFavoriteContactCardViewModel]) {
        self.favorites = favorites
    }
    
    func clearInput() {
        self.searchInput.setupTextField(self.searchInputViewModel)
    }
}

private extension SendMoneyDestinationAccountFullFavoritesListView {
    func setupView() {
        self.configureView()
        self.configureTableView()
        self.configureSearchInput()
        self.configureEmptyStateView()
        self.configureLoadingView()
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
        self.registerCells()
    }
    
    func configureSearchInput() {
        self.searchInput.delegate = self
        self.clearInput()
    }
    
    func configureEmptyStateView() {
        self.emptyStateView.configure(
            titleKey: Constants.EmptyState.title,
            infoKey: Constants.EmptyState.subtitle,
            buttonTitleKey: Constants.EmptyState.button
        )
        self.emptyStateView.setAccessibilitySuffix(AccessibilitySendMoneyDestination.AllFavorites.allFavoritesSuffix)
        self.emptyStateView.delegate = self
    }
    
    func configureLoadingView() {
        self.loadingImageView.setJumpingLoader()
        self.loadingImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.AllFavorites.emptyLoader
        self.loadingContainerView.accessibilityIdentifier = AccessibilitySendMoneyDestination.AllFavorites.emptyLoader
    }
    
    func searchDidPressed() {
        self.dismissKeyboard()
        self.delegate?.didSearchFavorite(text: self.searchInput.getInputText() ?? "")
    }
    
    func registerCells() {
        self.tableView.register(SendMoneyDestinationAccountFullFavoritesCell.self, bundle: Bundle.module)
    }
    
    func updateContentVisibility() {
        guard !self.isLoading else {
            self.loadingContainerView.isHidden = false
            self.emptyStateView.isHidden = true
            self.tableView.isHidden = true
            return
        }
        guard self.favorites.isEmpty else {
            self.loadingContainerView.isHidden = true
            self.emptyStateView.isHidden = true
            self.tableView.isHidden = false
            return
        }
        self.loadingContainerView.isHidden = true
        self.emptyStateView.isHidden = false
        self.tableView.isHidden = true
    }
    
    func setAccessibilityInfo() {
        self.searchInput.isAccessibilityElement = true
        self.searchInput.accessibilityLabel = localized("voiceover_findFavorites").text
        UIAccessibility.post(notification: .layoutChanged, argument: self.searchInput)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}

extension SendMoneyDestinationAccountFullFavoritesListView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SendMoneyDestinationAccountFullFavoritesCell.self, indexPath: indexPath)
        let favorite = favorites[indexPath.row]
        cell.configure(with: favorite, highlightedText: self.searchInput.getInputText()?.lowercased())
        let accessibilitySuffix = "\(AccessibilitySendMoneyDestination.AllFavorites.allFavoritesSuffix)"
        cell.setAccessibilitySuffix(accessibilitySuffix)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isLoading = true
        self.delegate?.didSelectFavorite(favorites[indexPath.row])
        self.tableView.scrollToRow(at: Constants.firstIndexPath, at: .top, animated: false)
    }
}

extension SendMoneyDestinationAccountFullFavoritesListView: OneInputRegularViewDelegate {
    func textDidChange(_ text: String) {
        self.delegate?.didSearchFavorite(text: text.lowercased())
    }
    
    func shouldReturn() {
        self.dismissKeyboard()
    }
}

extension SendMoneyDestinationAccountFullFavoritesListView: EmptyStateViewDelegate {
    func didTapActionButton() {
        self.delegate?.didTapAddNewContact()
    }
}

extension SendMoneyDestinationAccountFullFavoritesListView: AccessibilityCapable {}
