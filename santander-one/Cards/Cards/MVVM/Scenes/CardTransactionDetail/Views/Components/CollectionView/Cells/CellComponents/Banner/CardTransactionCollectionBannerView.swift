//
//  CardTransactionCollectionBannerView.swift
//  Pods
//
//  Created by Hernán Villamil on 7/4/22.
//

import OpenCombine
import CoreDomain
import UIKit
import UI

final class CardTransactionCollectionBannerView: XibView {
    @IBOutlet private weak var bottomBorderLineView: UIView!
    @IBOutlet private weak var offerView: UIView!
    @IBOutlet private weak var loadingImageView: UIImageView!
    let didSelectOfferSubject = PassthroughSubject<CardTransactionViewItemRepresentable?, Never>()
    let resizeWithRatioSubject = PassthroughSubject<CGFloat, Never>()
    var item: CardTransactionViewItemRepresentable? {
        didSet { configureView(item) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func hideLoading() {
        self.loadingImageView.removeLoader()
        self.loadingImageView.isHidden = true
    }
}

private extension CardTransactionCollectionBannerView {
    func setupView() {
        backgroundColor = UIColor.skyGray
        hideLoading()
        setupViewForExpandedState()
    }
    
    func showLoading() {
        self.loadingImageView.isHidden = false
        self.loadingImageView.setPointsLoader()
    }
    
    func setupViewForExpandedState() {
        bottomBorderLineView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        bottomBorderLineView.layer.borderWidth = 1
        bottomBorderLineView.isHidden = false
    }
    
    func addOffer(_ item: CardTransactionViewItemRepresentable?) {
        offerView.subviews.forEach { $0.removeFromSuperview() }
        guard let offer = item?.offerRepresentable, let url = offer.bannerRepresentable?.url else { return }
        
        let bannerView = BannerView()
        bannerView.setImageUrl(url)
        bannerView.delegate = self
        bannerView.addAction { [unowned self] in
            self.didSelectOfferSubject.send(self.item)
        }
        offerView.addSubview(bannerView)
    }
    
    func configureView(_ item: CardTransactionViewItemRepresentable?) {
        if item?.transactionDetail == nil, item?.error == nil {
            showLoading()
        } else {
            hideLoading()
            setupViewForExpandedState()
        }
        addOffer(item)
    }
}

extension CardTransactionCollectionBannerView: BannerViewDelegate {
     func ratioToResize(_ ratio: CGFloat) {
         resizeWithRatioSubject.send(ratio)
     }
 }
