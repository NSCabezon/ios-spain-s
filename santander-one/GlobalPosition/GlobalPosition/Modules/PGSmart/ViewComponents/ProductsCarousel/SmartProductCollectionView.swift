//
//  SmartProductCollectionView.swift
//  GlobalPosition
//
//  Created by Luis Escámez Sánchez on 19/12/2019.
//

import UIKit
import UI
import Foundation
import CoreFoundationLib

protocol SmartProductCollectionViewDelegate: AnyObject {
    func didTapOnProduct(product: PGCellInfo)
    func activateCard(_ card: Any)
    func turnOnCard(_ card: Any)
    func didClosePullOffer(_ pullOffer: Any)
}

final class SmartProductCollectionView: DesignableView, CardProductTableViewCellDelegate, DiscreteModeConformable {
    
    var discreteMode: Bool = false
    
    weak var smartProductsDelegate: SmartProductCollectionViewDelegate?
    var products: [PGCellInfo] = []
    private let supportedCells = ["SmartAccountCollectionViewCell", "SmartCardCollectionViewCell", "SmartGenericProductCollectionViewCell", "SmartNoProductsCollectionViewCell", "SmartOfferCollectionViewCell"]
    
    @IBOutlet weak var productCollectionView: UICollectionView!

    private let semaphore = DispatchSemaphore(value: 1)
    
    override func commonInit() {
        super.commonInit()
        
        setupView()
    }
    
    // MARK: - Accesible Methods
    
    func setSmartProducts(products: [PGCellInfo]) {
        self.products = products
    }
    
    func reloadData() {
        semaphore.wait()
        productCollectionView.reloadData()
        semaphore.signal()
    }
    
    func reloadCollectionRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: productCollectionView.numberOfSections - 1)
        
        guard indexPath.section < productCollectionView.numberOfSections else { return }
        guard indexPath.row < productCollectionView.numberOfItems(inSection: indexPath.section) else { return }

        UIView.performWithoutAnimation {
            semaphore.wait()
            productCollectionView.reloadItems(at: [indexPath])
            semaphore.signal()
        }
    }
    
    func setDelegate(_ delegate: SmartProductCollectionViewDelegate?) {
        self.smartProductsDelegate = delegate
    }
    
    func scrollToOrigin() {
        productCollectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    // MARK: - CardProductTableViewCellDelegate methods
    
    func activateCard(_ card: Any?) {
        guard let card = card else { return }
        smartProductsDelegate?.activateCard(card)
    }
    
    func turnOnCard(_ card: Any?) {
        guard let card = card else { return }
        smartProductsDelegate?.turnOnCard(card)
    }
}

private extension SmartProductCollectionView {
    
    func setupView() {
        registerCells()
        configureCollection()
    }
    
    func configureCollection() {
        productCollectionView.backgroundColor = .clear
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
    }
    
    func registerCells() {
        supportedCells.forEach {
            productCollectionView.register(UINib(nibName: $0, bundle: Bundle(for: PGSmartViewController.self)), forCellWithReuseIdentifier: $0)
        }
    }
    
    func setAccessibilityValue(_ indexPath: IndexPath, _ cell: UICollectionViewCell) {
        let items = String(self.products.count)
        let index = String(indexPath.row + 1)
        let label = localized("voiceover_position", [StringPlaceholder(.number, index), StringPlaceholder(.number, items)]).text
        cell.accessibilityLabel = label
    }
    
    func setAccessbilityIdentifiers() {
        self.accessibilityIdentifier = "pgSmart_collection_view"
    }
}

extension SmartProductCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellInfo = self.products[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellInfo.cellClass, for: indexPath)
        (cell as? GeneralPGCellProtocol)?.setCellInfo(cellInfo.info)
        (cell as? SmartCardCollectionViewCell)?.setCellDelegate(self)
        (cell as? SmartOfferCollectionViewCell)?.setCellDelegate(self)
        self.setAccessbilityIdentifiers()
        self.setAccessibility { self.setAccessibilityValue(indexPath, cell) }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellInfo = self.products[indexPath.row]
        smartProductsDelegate?.didTapOnProduct(product: cellInfo)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 168, height: 215)
    }
}

extension SmartProductCollectionView: PullOfferCollectionCellDelegate {
    func pullOfferCloseDidPressed(_ elem: Any?) {
        self.smartProductsDelegate?.didClosePullOffer(elem)
    }
}

extension SmartProductCollectionView: AccessibilityCapable { }
