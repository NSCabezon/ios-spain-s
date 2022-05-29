//
//  LastBeneficiariesView.swift
//  Account
//
//  Created by Ignacio González Miró on 22/05/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol LastBeneficiariesViewDelegate: AnyObject {
    func didTapInBeneficiary(_ viewModel: EmittedSepaTransferViewModel)
}

final class LastBeneficiariesView: UIDesignableView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var collectionView: LastBeneficiariesCollectionView!
    private var lastTransfersViewModel: EmittedSepaTransferViewModel?
    private let loadingView = TransferEmittedLoadingView()
    private let emptyView = TransferEmittedEmptyView()
    weak var delegate: LastBeneficiariesViewDelegate?
    
    override func getBundleName() -> String {
        return "Transfer"
    }
    
    override func commonInit() {
        super.commonInit()
        let nib = UINib(nibName: "LastBeneficiaryCollectionViewCell", bundle: Bundle.module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: LastBeneficiaryCollectionViewCell.identifier)
        self.backgroundColor = .clear
        self.setup()
        self.setAppearance()
        self.setIdentifiers()
        self.addLoadingView()
    }
    
    func setViewModels(_ viewModels: [EmittedSepaTransferViewModel]) {
        self.collectionView.backgroundView = nil
        self.collectionView.setViewModels(viewModels)
        self.setAppearance()
    }
}

private extension LastBeneficiariesView {

    func setup() {
        self.collectionView.lastBeneficiaryDelegate = self
    }
    
    func setAppearance() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 18)
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.configureText(withKey: "sendMoney_label_lastBeneficiaries")
        self.titleLabel.accessibilityIdentifier = AccessibilityTransferDestination.lastPaymentsTitle.rawValue
        self.backgroundColor = .white
    }
    
    func setIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityLastBeneficiaries.title.rawValue
    }
    
    func addLoadingView() {
        self.collectionView.setViewModels([])
        self.loadingView.frame = collectionView.bounds
        self.collectionView.backgroundView = loadingView
        self.loadingView.startAnimating()
    }
    
    func stopLoading() {
        self.loadingView.startAnimating()
        self.loadingView.removeFromSuperview()
    }
    
    func clearTransfers() {
        self.addLoadingView()
        self.collectionView.setViewModels([])
    }
}

extension LastBeneficiariesView: LastBeneficiariesCollectionViewDelegate {
    func didSelectBeneficiary(_ viewModel: EmittedSepaTransferViewModel) {
        self.delegate?.didTapInBeneficiary(viewModel)
    }
}
