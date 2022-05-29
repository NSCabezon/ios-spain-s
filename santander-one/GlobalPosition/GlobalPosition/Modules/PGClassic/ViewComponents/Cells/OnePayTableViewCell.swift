//
//  OnePayTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 05/11/2019.
//

import UIKit
import CoreFoundationLib

protocol OnePayTableViewCellProtocol {
    func setDelegate(_ delegate: OnePayCollectionViewControllerDelegate?)
    func setFavouriteContactsList(_ onePayInfoList: [OnePayCollectionInfo])
    func setLoadingView()
}

final class OnePayTableViewCell: UITableViewCell {
    @IBOutlet weak var sendMoneyLabel: UILabel?
    @IBOutlet weak var onePayCollectionView: UICollectionView?
    var controller: OnePayCollectionViewController?
    private var onePayCollectionInfo: [OnePayCollectionInfo]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 240.0)
    }
}

private extension OnePayTableViewCell {
    // setupView
    func commonInit() {
        selectionStyle = .none
        onePayCollectionView?.showsHorizontalScrollIndicator = false
        configureLabel()
        configureCollectionView()
        setAccessibility(setViewAccessibility: self.setAccessibility) 
    }
    
    func configureCollectionView() {
        controller = OnePayCollectionViewController(collectionView: onePayCollectionView, dataList: onePayCollectionInfo)
        backgroundColor = .blueAnthracita
        onePayCollectionView?.backgroundColor = .blueAnthracita
    }
    
    func configureLabel() {
        sendMoneyLabel?.textColor = UIColor.white
        sendMoneyLabel?.font = UIFont.santander(family: .text, size: 20.0)
        sendMoneyLabel?.configureText(withKey: "pg_label_sendMoney")
    }
    
    func setAccessibility() {
        self.sendMoneyLabel?.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.baseTitle.rawValue
        self.accessibilityElements = [self.sendMoneyLabel, self.onePayCollectionView]
    }
}

extension OnePayTableViewCell: OnePayTableViewCellProtocol {
    func setDelegate(_ delegate: OnePayCollectionViewControllerDelegate?) {
        controller?.delegate = delegate
    }
    
    func setFavouriteContactsList(_ onePayInfoList: [OnePayCollectionInfo]) {
        controller?.cellsInfo = onePayInfoList
    }
    
    func setLoadingView() {
        let loadingPills = OnePayPGConfiguration.loadingPills
        controller?.cellsInfo = loadingPills
    }
}

extension OnePayTableViewCell: AccessibilityCapable { }
