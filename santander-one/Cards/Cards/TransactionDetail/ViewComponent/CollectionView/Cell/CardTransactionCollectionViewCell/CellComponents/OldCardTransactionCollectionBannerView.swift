//
//  CardTransactionCollectionBannerView.swift
//  Cards
//
//  Created by Oscar R. Garrucho.
//  Linkedin: https://www.linkedin.com/in/oscar-garrucho/
//  Copyright © 2022 Oscar R. Garrucho. All rights reserved.
//

import UIKit
import UI

protocol CardTransactionCollectionBannerViewDelegate: AnyObject {
    func didSelectOffer(viewModel: OldCardTransactionDetailViewModel)
    func ratioToResize(_ ratio: CGFloat)
}

final class OldCardTransactionCollectionBannerView: XibView {
    
    @IBOutlet private weak var bottomBorderLineView: UIView!
    @IBOutlet private weak var offerView: UIView!
    @IBOutlet private weak var loadingImageView: UIImageView!
    
    private weak var delegate: CardTransactionCollectionBannerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setDelegate(delegate: CardTransactionCollectionBannerViewDelegate) {
        self.delegate = delegate
    }
    
    func configureView(_ viewModel: OldCardTransactionDetailViewModel) {
        if viewModel.detail == nil, viewModel.error == nil {
            showLoading()
        } else {
            hideLoading()
            setupViewForExpandedState()
        }
        addOffer(viewModel)
    }
    
    func hideLoading() {
        self.loadingImageView.removeLoader()
        self.loadingImageView.isHidden = true
    }
}

private extension OldCardTransactionCollectionBannerView {
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
    
    func addOffer(_ viewModel: OldCardTransactionDetailViewModel) {
        offerView.subviews.forEach { $0.removeFromSuperview() }
        guard let offer = viewModel.offerEntity, let url = offer.banner?.url else { return }
        
        let bannerView = BannerView()
        bannerView.setImageUrl(url)
        bannerView.delegate = self
        bannerView.addAction { [weak self] in
            self?.delegate?.didSelectOffer(viewModel: viewModel)
        }
        offerView.addSubview(bannerView)
    }
}

extension OldCardTransactionCollectionBannerView: BannerViewDelegate {
    func ratioToResize(_ ratio: CGFloat) {
        delegate?.ratioToResize(ratio)
    }
}
