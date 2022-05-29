//
//  PeriodicTransfersTableView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 10/02/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol PeriodicTransfersTableViewDelegate: AnyObject {
    func didSelectPeriodicTransfer(_ viewModel: PeriodicTransferViewModelProtocol)
}

final class PeriodicTransfersTableView: UIView {
    @IBOutlet weak var tableView: UITableView!
    private var transfers: [PeriodicTransferViewModelProtocol] = []
    weak var delegate: PeriodicTransfersTableViewDelegate?
    var view: UIView?

    private lazy var loadingTransfersView: ScheduledTransferLoadingView = {
        let loadingView = ScheduledTransferLoadingView(frame: self.frame)
        return loadingView
    }()
    
    private lazy var emptyTransfersView: ScheduledTransferEmptyView = {
        let emptyView = ScheduledTransferEmptyView(frame: self.frame)
        return emptyView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public
    public func setData(_ transfers: [PeriodicTransferViewModelProtocol]) {
        self.transfers = transfers
        self.loadingTransfersView.stopAnimating()
        self.tableView.backgroundView = transfers.isEmpty ? self.emptyTransfersView : nil
        self.tableView.reloadData()
    }
    
    public func setEmptyResultView() {
        self.loadingTransfersView.stopAnimating()
        self.tableView.backgroundView = self.emptyTransfersView
    }
    
    public func setEmptyViewModel(_ viewModel: ScheduledTransferEmptyViewModel) {
        self.emptyTransfersView.setViewModel(viewModel)
    }
}

private extension PeriodicTransfersTableView {
    func setupView() {
        self.xibSetup()
        self.configureView()
    }
    
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func configureView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundView = self.loadingTransfersView
        self.tableView.register(PeriodicTransferTableViewCell.nib, forCellReuseIdentifier: PeriodicTransferTableViewCell.identifier)
    }
}

extension PeriodicTransfersTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transfers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PeriodicTransferTableViewCell.identifier, for: indexPath) as? PeriodicTransferTableViewCell else { return UITableViewCell() }
        let viewModel = self.transfers[indexPath.row]
        viewModel.setIndex(indexPath.row)
        cell.setViewModel(viewModel)
       return cell
    }
}

extension PeriodicTransfersTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.transfers[indexPath.row]
        self.delegate?.didSelectPeriodicTransfer(viewModel)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
