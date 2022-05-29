//
//  SantanderKeySecureDeviceView.swift
//  UI
//
//  Created by Margaret López Calderón on 9/9/21.
//

import UIKit
import CoreFoundationLib

public protocol SantanderKeySecureDeviceViewDelegate: AnyObject {
    func didTapPlayVideo(offer: OfferEntity)
}

public final class SantanderKeySecureDeviceView: XibView {
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet {
            self.logoImageView.image = Assets.image(named: "icnBigSantanderLock")
        }
    }
    @IBOutlet weak var logoTitleLabel: UILabel! {
        didSet {
            self.logoTitleLabel.textColor = .black
            self.logoTitleLabel.numberOfLines = 0
            let config = LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 20),
                alignment: .center,
                lineHeightMultiple: 0.75
            )
            self.logoTitleLabel.configureText(withKey: "ecommerce_label_SantanderKey", andConfiguration: config)
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.textColor = .lisboaGray
            self.titleLabel.numberOfLines = 0
            self.titleLabel.textAlignment = .center
            self.titleLabel.font = .santander(family: .headline, type: .regular, size: 19)
        }
    }
    @IBOutlet weak var bodyHeadLabel: UILabel! {
        didSet {
            self.bodyHeadLabel.textColor = .lisboaGray
            self.bodyHeadLabel.numberOfLines = 0
            self.bodyHeadLabel.font = .santander(family: .headline, type: .regular, size: 14)
        }
    }
    @IBOutlet weak var dashLineView: UIView!
    @IBOutlet weak var separatorView: DottedLineView! {
        didSet {
            self.separatorView.strokeColor = .brownGray
            self.separatorView.lineWidth = 1
            self.separatorView.lineDashPattern = [10, 5]
        }
    }

    @IBOutlet weak var locationVideoButton: UIView!
    
    @IBOutlet weak var bodyDescriptionLabel: UILabel! {
        didSet {
            self.bodyDescriptionLabel.textColor = .lisboaGray
            self.bodyDescriptionLabel.numberOfLines = 0
            self.bodyDescriptionLabel.font = .santander(family: .text, type: .regular, size: 12)
        }
    }
    weak var delegate: SantanderKeySecureDeviceViewDelegate?
    
    private var offer: OfferEntity?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(viewModel: SantanderKeySecureDeviceViewModel,
                            delegate: SantanderKeySecureDeviceViewDelegate,
                            offer: OfferEntity?) {
        self.init(frame: .zero)
        self.offer = offer
        self.delegate = delegate
        self.configureView(viewModel)
        self.configureOffer()
    }
}

private extension SantanderKeySecureDeviceView {
    
    func addLocationVideoButton() {
        let view = LocationSantanderKeyVideoButton()
        view.delegate = self
        self.locationVideoButton.addSubview(view)
        view.fullFit()
    }
    
    func configureView(_ viewModel: SantanderKeySecureDeviceViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title)
        self.bodyHeadLabel.configureText(withKey: viewModel.bodyHead)
        self.bodyDescriptionLabel.configureText(withKey: viewModel.bodyDescription)
    }
    
    func configureOffer() {
        if self.offer != nil {
            self.addLocationVideoButton()
        } else {
            self.locationVideoButton.isHidden = true
        }
    }
}

extension SantanderKeySecureDeviceView: LocationSantanderKeyVideoButtonDelegate {
    public func didTapPlayVideo() {
        guard let offer = offer else { return }
        self.delegate?.didTapPlayVideo(offer: offer)
    }
}
