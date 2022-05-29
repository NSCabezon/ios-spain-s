//
//  HistoricalEmittedTransferListView.swift
//  Transfer
//
//  Created by alvola on 14/05/2020.
//

import UIKit
import CoreFoundationLib

protocol HistoricalTransferListViewProtocol {
    func startAnimating()
    func stopAnimating()
    func addResults(_ results: [EmittedGroupViewModel])
    func configureEmptyTitle(_ title: String, subtitle: String)
    func setEmptySearchedText(_ text: String)
    func setDelegate(_ delegate: HistoricalTransferListViewDelegate?)
    func setTableHeaderText(_ text: String, resultsNumber: Int)
    func clearTableHeader()
    func scrollToTop()
}

protocol HistoricalTransferListViewDelegate: AnyObject {
    func didSelectTransfer(viewModel: TransferViewModel)
    func endEditing()
}

final class HistoricalTransferListView: UIView {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        addSubview(tableView)
        let tap = UITapGestureRecognizer(target: self,
                                             action: #selector(emptyViewTapped))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        return tableView
    }()
    
    private lazy var loadingImageView: UIImageView = {
        let image = UIImageView()
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.isHidden = true
        return image
    }()
    
    private lazy var loadingTitleLabel: UILabel = {
        let label = UILabel()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.isHidden = true
        return label
    }()
    
    private lazy var loadingSubtitleLabel: UILabel = {
        let label = UILabel()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.isHidden = true
        return label
    }()
    
    private var hideLoading: Bool = true {
        didSet {
            self.loadingImageView.isHidden = hideLoading
            self.loadingTitleLabel.isHidden = hideLoading
            self.loadingSubtitleLabel.isHidden = hideLoading
        }
    }
    
    private lazy var emptyView: HistoricalTransferEmptyView = {
        let view = HistoricalTransferEmptyView()
        addSubview(view)
        view.isHidden = true
        return view
    }()
    
    private lazy var searchHeaderView: SearchTransferHeaderView = {
        let header = SearchTransferHeaderView(frame: .zero)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.emptyViewTapped)))
        return header
    }()
    
    private lazy var tableHeaderViewContainer: UIView = {
        let container = UIView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: self.tableView.frame.width,
                                                          height: 47.0)))
        container.addSubview(searchHeaderView)
        self.searchHeaderView.fullFit()
        return container
    }()
    
    private var list: [EmittedGroupViewModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private weak var delegate: HistoricalTransferListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

private extension HistoricalTransferListView {
    func commonInit() {
        self.tableView.fullFit()
        self.configureLoading()
        self.configureTableView()
        self.layoutIfNeeded()
    }
    
    func configureLoading() {
        self.loadingImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.loadingImageView.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        self.loadingImageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        self.loadingImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 72.0).isActive = true
        self.configureLoadingText()
        self.loadingTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.loadingTitleLabel.heightAnchor.constraint(equalToConstant: 29.0).isActive = true
        self.loadingTitleLabel.topAnchor.constraint(equalTo: self.loadingImageView.bottomAnchor, constant: 9.0).isActive = true
        self.loadingSubtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.loadingSubtitleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        self.loadingSubtitleLabel.topAnchor.constraint(equalTo: self.loadingTitleLabel.bottomAnchor, constant: -4).isActive = true
    }
    
    func configureLoadingText() {
        self.loadingTitleLabel.configureText(withKey: "generic_popup_loadingContent")
        self.loadingTitleLabel.textColor = .lisboaGray
        self.loadingTitleLabel.font = UIFont.santander(size: 20.0)
        self.loadingSubtitleLabel.configureText(withKey: "loading_label_moment")
        self.loadingSubtitleLabel.textColor = .grafite
        self.loadingSubtitleLabel.font = UIFont.santander(size: 14.0)
    }
    
    func configureEmptyView() {
        self.emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.emptyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.emptyView.topAnchor.constraint(equalTo: self.topAnchor, constant: 60.0),
            self.emptyView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.emptyView.heightAnchor.constraint(equalToConstant: 211.0)
        ])
        self.emptyView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(self.emptyViewTapped)))
        self.emptyView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferViewEmptyView
    }
    
    func configureTableView() {
        self.tableView.register(HistoricalTransferTableViewCell.self, bundle: .module)
        self.tableView.registerHeader(header: HistoricalTransferDateSectionView.self, bundle: .module)
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 74.0
    }
    
    @objc func emptyViewTapped() {
        self.delegate?.endEditing()
    }
}

extension HistoricalTransferListView: HistoricalTransferListViewProtocol {
    func startAnimating() {
        self.emptyView.isHidden = true
        self.hideLoading = false
        self.loadingImageView.setPointsLoader()
    }
    
    func stopAnimating() {
        self.hideLoading = true
        self.loadingImageView.removeLoader()
    }
    
    func addResults(_ results: [EmittedGroupViewModel]) {
        self.list = results
        self.emptyView.isHidden = !list.isEmpty
    }
    
    func configureEmptyTitle(_ title: String, subtitle: String) {
        self.emptyView.setTitleKey(title)
        self.emptyView.setSubtitleKey(subtitle)
        self.configureEmptyView()
        self.layoutIfNeeded()
    }
    
    func setEmptySearchedText(_ text: String) {
        self.emptyView.setTitle(localized("globalSearch_title_empty", [StringPlaceholder(.value, text)]))
        self.emptyView.setSubtitleKey(nil)
    }
    
    func setTableHeaderText(_ text: String, resultsNumber: Int) {
        guard resultsNumber > 0 else { return clearTableHeader() }
        self.searchHeaderView.searchText(text, results: resultsNumber)
        self.tableView.tableHeaderView = self.tableHeaderViewContainer
    }
    
    func clearTableHeader() {
        self.tableView.tableHeaderView = nil
    }
    
    func scrollToTop() {
        guard !list.isEmpty else { return }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func setDelegate(_ delegate: HistoricalTransferListViewDelegate?) {
        self.delegate = delegate
    }
}

extension HistoricalTransferListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].transfer.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoricalTransferTableViewCell",
                                                       for: indexPath) as? HistoricalTransferTableViewCell
            else { return UITableViewCell() }
        let emitted = list[indexPath.section].transfer[indexPath.row]
        cell.dottedHidden(isLast: indexPath.row == self.list[indexPath.section].transfer.count - 1)
        cell.setup(withViewModel: emitted, section: indexPath.section, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transferSelected = self.list[indexPath.section].transfer[indexPath.row]
        self.delegate?.didSelectTransfer(viewModel: transferSelected.viewModel)
    }
}

extension HistoricalTransferListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HistoricalTransferDateSectionView")
            as? HistoricalTransferDateSectionView else { return nil }
        headerView.configure(withDate: list[section].dateFormatted)
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyViewTapped)))
        headerView.hideSeparator(true)
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.endEditing()
    }
}
