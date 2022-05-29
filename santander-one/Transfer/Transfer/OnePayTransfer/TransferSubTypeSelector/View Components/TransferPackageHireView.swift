//
//  TransferPackageHireView.swift
//  Transfer
//
//  Created by crodrigueza on 18/8/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol TransferPackageHireViewDelegate: AnyObject {
    func transferPackageHireViewSelected(_ view: TransferPackageHireView)
}

final class TransferPackageHireView: XibView {

    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var titleWarningLabel: UILabel!
    weak var delegate: TransferPackageHireViewDelegate?

    init(frame: CGRect, delegate: TransferPackageHireViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension TransferPackageHireView {
    
    func setup() {
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.borderColor = UIColor.lightSkyBlue.cgColor
        self.containerView.layer.shadowColor = UIColor.atmsShadowGray.cgColor
        self.containerView.layer.shadowOpacity = 0.5
        self.containerView.layer.shadowOffset = .zero
        self.containerView.layer.shadowRadius = 5
        self.imageView.image = Assets.image(named: "icnBuyTransferPackages")
        self.titleLabel.text = localized("sendMoney_button_buyTransferPackages")
        self.subtitleLabel.text = localized("sendMoney_text_buyTransferPackages")
        self.titleLabel.setSantanderTextFont(type: .bold, size: 16, color: .darkTorquoise)
        self.subtitleLabel.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectHirePackage)))
        self.titleWarningLabel.text = localized("sendMoney_text_infoPaymentsCosts")
        self.titleWarningLabel.setSantanderTextFont(type: .regular, size: 12, color: .lisboaGray)
        self.setupAccessibilityElements()
    }
    
    @objc func didSelectHirePackage() {
        self.delegate?.transferPackageHireViewSelected(self)
    }
    
    func setupAccessibilityElements() {
        self.subviews.setAccessibilityHidden(true)
        self.accessibilityElementsHidden = false
        self.isAccessibilityElement = true
        self.accessibilityLabel = self.titleLabel.appendSpeechFromElements([subtitleLabel,
                                                                            titleWarningLabel])
    }
}
