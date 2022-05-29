//
//  OfferPrivateMenuViewModel.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 26/05/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib

class OfferPrivateMenuViewModel: TableModelViewItem<BannerPGViewCell> {
    let url: String
    var insertedHeight: CGFloat?
    var bannerOffer: Offer?
    var insets: UIEdgeInsets?
    var taskCancelable: CancelableTask?
    private weak var actionDelegate: LocationBannerViewModelDelegate?
    
    // MARK: - Events
    var didSelect: (() -> Void)?
    
    init(url: String, bannerOffer: Offer? = nil, leftInset: CGFloat? = nil, rightInset: CGFloat? = nil, topInset: CGFloat? = nil, bottomInset: CGFloat? = nil, actionDelegate: LocationBannerViewModelDelegate?, dependencies: PresentationComponent) {
        self.url = url
        self.actionDelegate = actionDelegate
        self.bannerOffer = bannerOffer
        self.insets = UIEdgeInsets(top: topInset ?? 0, left: leftInset ?? 0, bottom: bottomInset ?? 0, right: rightInset ?? 0)
        super.init(dependencies: dependencies)
    }
    
    override var height: CGFloat? {
        return self.insertedHeight
    }
    
    override func bind(viewCell: BannerPGViewCell) {
        viewCell.lastItem = true
        viewCell.insets = insets
        viewCell.isClosable = false
        taskCancelable = dependencies.imageLoader.loadTask(absoluteUrl: url, imageView: viewCell.bannerImage, placeholderIfDoesntExist: nil, completion: { [weak self] in
            viewCell.onImageLoadFinished()
            self?.taskCancelable = nil
        })
    }
    
    public func onImageLoadFinished(newHeight: CGFloat) {
        if newHeight != insertedHeight {
            insertedHeight = newHeight
            actionDelegate?.finishDownloadImage(newHeight: nil)
        }
    }
    
    func didCloseButton() {
        actionDelegate?.closeBanner(bannerOffer: self.bannerOffer, item: self)
    }
    
    func willReuseView(viewCell: BannerPGViewCell) {
        taskCancelable?.cancel()
    }
}

extension OfferPrivateMenuViewModel: Executable {
    func execute() {
        didSelect?()
    }
}
