//
//  OfferCustomView.swift
//  UI
//
//  Created by Tania Castellano Brasero on 31/05/2021.
//

import CoreFoundationLib

public class OfferCustomTipView: XibView {
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var offerStackView: UIStackView!
    public var viewModel: OfferCustomTipViewModel?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public func configView(_ model: OfferCustomTipViewModel, action : (() -> Void)?) {
        self.viewModel = model
        self.titleLabel.configureText(withKey: model.title ?? "")
        setImageSource(model.iconUrl)
        configBanner(model, action: action)
    }
}

private extension OfferCustomTipView {
    func setup() {
        self.backgroundColor = .paleYellow
        self.iconView.backgroundColor = .clear
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.titleLabel.textColor = .lisboaGray
    }
    
    func setImageSource(_ url: String?) {
        guard let urlUnwrapped = url else {
            self.iconView.image = nil
            return }
        self.iconView.loadImage(urlString: urlUnwrapped)
    }
    
    func configBanner(_ model: OfferCustomTipViewModel, action : (() -> Void)?) {
        guard let bannerImage = model.imageBanner else { return }
        let view = BannerView(frame: .zero)
        view.setImageUrl(bannerImage)
        offerStackView.addArrangedSubview(view)
        view.addAction(action)
    }
}
