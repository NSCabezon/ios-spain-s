//
//  EmittedTransfersView.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import UIKit
import CoreFoundationLib
import UI

protocol EmittedTransfersViewDelegate: AnyObject {
    func didSelectTransfer(_ viewModel: TransferViewModel)
    func didSelectScheduledTransfers()
    func didSelectHistoricalEmittedTransfers()
    func didSwipeEmmited()
}

final class EmittedTransfersView: UIView {
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var recentLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var collectionView: EmittedTransfersCollectionView!
    private let loadingView = TransferEmittedLoadingView()
    private let emptyView = TransferEmittedEmptyView()
    weak var delegate: EmittedTransfersViewDelegate?
    private var view: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.setAppearance()
        self.addLoadingView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
        self.setAppearance()
        self.addLoadingView()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
        self.collectionView.transferDelegate = self
        self.setupAccessibilityId()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setAppearance() {
        self.bottomLineView.backgroundColor = UIColor.mediumSkyGray
        self.topLineView.backgroundColor = UIColor.mediumSkyGray
        self.recentLabel.text = localized("transfer_title_recent")
        self.historyButton.setTitle(localized("transfer_label_seeHistorical"), for: .normal)
    }
    
    func hideHistoricalButton() {
        self.historyButton.isHidden = true
    }

    public func setViewModels(_ viewModels: [TransferViewModel]) {
        self.stopLoading()
        self.collectionView.backgroundView = nil
        self.collectionView.setViewModels(viewModels)
    }
    
    public func showEmptyView() {
        self.stopLoading()
        self.emptyView.frame = collectionView.bounds
        self.collectionView.backgroundView = emptyView
    }
    
    func addLoadingView() {
        self.collectionView.setViewModels([])
        self.loadingView.frame = collectionView.bounds
        self.collectionView.backgroundView = loadingView
        self.loadingView.startAnimating()
    }
    
    private func stopLoading() {
        self.loadingView.startAnimating()
        loadingView.removeFromSuperview()
    }
    
    func clearTransfers() {
        self.addLoadingView()
        self.collectionView.setViewModels([])
    }
}

extension EmittedTransfersView: EmittedTransfersCollectionViewDelegate {
    func didSelectTransfer(_ viewModel: TransferViewModel) {
        self.delegate?.didSelectTransfer(viewModel)
    }
    
    func didSwipe() {
        self.delegate?.didSwipeEmmited()
    }
    
    @IBAction func didSelectHistoricalEmittedTransfers(_ sender: Any) {
        self.delegate?.didSelectHistoricalEmittedTransfers()
    }
}

private extension EmittedTransfersView {
    func setupAccessibilityId() {
        self.recentLabel.accessibilityIdentifier = AccessibilityTransferHome.historicalTitleLabel
        self.historyButton.accessibilityIdentifier = AccessibilityTransferHome.historicalTitleButton
    }
}
