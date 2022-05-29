//
//  ConfirmationIbanItemView.swift
//  Operative
//
//  Created by Cristobal Ramos Laina on 3/9/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol ConfirmationIbanItemViewDelegate: AnyObject {
    func didTapOnShare(_ iban: String)
}

public class ConfirmationIbanItemView: XibView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var bankImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var pointLine: PointLine!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    private var viewModel: ConfirmationItemViewModel?
    public weak var delegate: ConfirmationIbanItemViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setup(with viewModel: ConfirmationItemViewModel) {
        self.viewModel = viewModel
        self.adjustConstraintsForPosition(viewModel.position)
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.valueLabel.attributedText = viewModel.value
        self.valueLabel.numberOfLines = 0
        self.valueLabel.set(lineHeightMultiple: 0.85)
        self.setInfo(viewModel.info)
        self.setAction(viewModel.action)
        self.pointLine.isHidden = viewModel.position == .last
        self.setupAccessibilityId()
        if let bankIcon = viewModel.baseUrl {
            let iban = IBANEntity.create(fromText: viewModel.info?.string ?? "")
            self.set(self.bankIconPath(with: iban, baseUrl: bankIcon))
        }
        self.setupAccessibilityElements()
    }
    
    @IBAction private func actionButtonSelected(_ sender: UIButton) {
        self.viewModel?.action?.action()
    }
}

private extension ConfirmationIbanItemView {
    
    func setupView() {
        self.titleLabel.setSantanderTextFont(size: 13, color: .grafite)
        self.valueLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.infoLabel.setSantanderTextFont(type: .italic, size: 14, color: .lisboaGray)
        self.actionButton.setTitleColor(.darkTorquoise, for: .normal)
        self.actionButton.titleLabel?.font = .santander(family: .text, size: 14)
        self.bankImageView.isHidden = true
        self.shareImageView.isHidden = true
        self.titleLabel.text = ""
        self.valueLabel.text = ""
        self.valueLabel.text = ""
    }
    
    func adjustConstraintsForPosition(_ position: ConfirmationItemViewModel.Position) {
        switch position {
        case .first:
            self.topLayoutConstraint.constant = 19
        case .last:
            self.bottomLayoutConstraint.constant = 26
            self.pointLine.isHidden = true
        case .unknown: break
        }
    }
    
    func setInfo(_ info: NSAttributedString?) {
        guard let info = info else { return self.infoLabel.isHidden = true }
        self.infoLabel.attributedText = info
    }
    
    func setAction(_ action: ConfirmationItemAction?) {
        guard let action = action
        else { return self.actionButton.isHidden = true }
        self.actionButton.setTitle(action.title, for: .normal)
        self.actionButton.accessibilityLabel = action.title
    }
    
    func setupAccessibilityId() {
        guard let accessibilityIdentifier = viewModel?.accessibilityIdentifier else { return }
        self.accessibilityIdentifier = accessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = accessibilityIdentifier + "_title"
        self.valueLabel.accessibilityIdentifier = accessibilityIdentifier + "_value"
        self.infoLabel.accessibilityIdentifier = accessibilityIdentifier + "_info"
        self.actionButton.accessibilityIdentifier = accessibilityIdentifier + "_action_button"
        self.bankImageView.accessibilityIdentifier = accessibilityIdentifier + "_imageBank"
    }
    
    func setupAccessibilityElements() {
        self.shareImageView.accessibilityTraits = .button
        self.shareImageView.accessibilityLabel = localized("generic_button_share")
    }
    
    func set(_ bankIconUrl: String?) {
        self.shareImageView.image = Assets.image(named: "icnShareAccount")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doShare(tapGestureRecognizer:)))
        self.shareImageView.isUserInteractionEnabled = true
        self.shareImageView.addGestureRecognizer(tapGestureRecognizer)
        guard let bankIconUrl = bankIconUrl else { return }
        self.bankImageView.loadImage(urlString: bankIconUrl)
        self.bankImageView.isHidden = false
        self.bankImageView.isAccessibilityElement = true
    }
    
    func bankIconPath(with iban: IBANEntity, baseUrl: String) -> String? {
        guard let entityCode = iban.ibanElec.substring(4, 8) else { return nil }
        let countryCode = iban.countryCode
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    @objc func doShare(tapGestureRecognizer: UITapGestureRecognizer) {
        if let viewModel = self.viewModel {
            self.delegate?.didTapOnShare(viewModel.info?.string ?? "")
        }
    }
}
