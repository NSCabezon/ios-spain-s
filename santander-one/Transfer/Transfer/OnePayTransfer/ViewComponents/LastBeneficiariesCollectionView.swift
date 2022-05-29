//
//  LastBeneficiariesCollectionView.swift
//  Account
//
//  Created by Ignacio González Miró on 22/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol LastBeneficiariesCollectionViewDelegate: AnyObject {
    func didSelectBeneficiary(_ viewModel: EmittedSepaTransferViewModel)
}

final class LastBeneficiariesCollectionView: UICollectionView {
    private var viewModels: [EmittedSepaTransferViewModel] = []
    weak var lastBeneficiaryDelegate: LastBeneficiariesCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [EmittedSepaTransferViewModel]) {
        self.viewModels = viewModels
        self.reloadData()
    }
}

private extension LastBeneficiariesCollectionView {
    func setupView() {
        self.delegate = self
        self.dataSource = self
        self.configLayouts()
    }
    
    func configLayouts() {
        guard let flowlayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowlayout.itemSize = CGSize(width: 120, height: 113)
        flowlayout.minimumLineSpacing = 8
        flowlayout.minimumInteritemSpacing = 8
        flowlayout.scrollDirection = .horizontal
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }
}

extension LastBeneficiariesCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LastBeneficiaryCollectionViewCell.identifier, for: indexPath) as? LastBeneficiaryCollectionViewCell else { return UICollectionViewCell() }
        let viewModel = self.viewModels[indexPath.row]
        cell.setup(with: viewModel)
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = AccessibilityLastBeneficiaries.item.rawValue + "\(indexPath.row)"
        return cell
    }
}

extension LastBeneficiariesCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = self.viewModels[indexPath.row]
        self.lastBeneficiaryDelegate?.didSelectBeneficiary(viewModel)
    }
}
