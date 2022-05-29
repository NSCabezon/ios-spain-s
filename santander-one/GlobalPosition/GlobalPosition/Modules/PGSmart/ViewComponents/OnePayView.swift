//
//  OnePayView.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 20/12/2019.
//

import UI
import UIKit
import CoreFoundationLib

protocol OnePayViewProtocol {
    func setDelegate(_ delegate: OnePayCollectionViewControllerDelegate?)
    func setFavouriteCarousel(_ dataList: [OnePayCollectionInfo])
}

final class OnePayView: DesignableView, OnePayViewProtocol {

    @IBOutlet private weak var sendMoneyLabel: UILabel?
    @IBOutlet private weak var onePayCollectionView: UICollectionView?
    
    var controller: OnePayCollectionViewController?
    private var onePayCollectionInfoList: [OnePayCollectionInfo]!
    weak var delegate: OnePayCollectionViewControllerDelegate?
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureLabel()
        configureCollectionView()
        setAccessibilityId()
    }
    
    func setDelegate(_ delegate: OnePayCollectionViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func refresh() {
        sendMoneyLabel?.configureText(withKey: "pg_label_sendMoney")
        onePayCollectionView?.reloadData()
    }
    
    func setFavouriteCarousel(_ dataList: [OnePayCollectionInfo]) {
        self.configureCollectionView(dataList)
        self.onePayCollectionView?.reloadData()
    }
}

private extension OnePayView {
    func configureView() {
        backgroundColor = .lightGray40
    }
    
    func configureCollectionView(_ dataList: [OnePayCollectionInfo]? = nil) {
        controller = OnePayCollectionViewController(collectionView: self.onePayCollectionView, dataList: dataList)
        controller?.hasShadow = false
        controller?.delegate = self
        onePayCollectionView?.backgroundColor = UIColor.clear
    }
    
    func configureLabel() {
        sendMoneyLabel?.textColor = UIColor.lisboaGray
        sendMoneyLabel?.configureText(withKey: "pg_label_sendMoney",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, size: 22.0)))
    }
    
    func setAccessibilityId() {
        sendMoneyLabel?.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.baseTitle.rawValue
        self.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.smartBase.rawValue
    }
}

extension OnePayView: OnePayCollectionViewControllerDelegate {
    func newShippmentPressed() {
        delegate?.newShippmentPressed()
    }
    
    func newFavContactPressed() {
        delegate?.newFavContactPressed()
    }
    
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel) {
        delegate?.didTapInFavContact(viewModel)
    }
    
    func didTapInHistoricSendMoney() {
        delegate?.didTapInHistoricSendMoney()
    }
}
