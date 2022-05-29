//
//  PendingSolicitudeUICollectionCell.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/20/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol PendingSolicitudeCollectionViewCellDelegate: AnyObject {
    func pendingSolicitudeClosed(_ viewModel: PendingSolicitudeViewModel)
}

final class PendingSolicitudeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var headerTitle: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var pendintTitleLabel: UILabel!
    @IBOutlet private weak var pendingDescriptionLabel: UILabel!
    @IBOutlet private weak var pendingDescriptionContainer: UIView!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    private var viewModel: PendingSolicitudeViewModel?
    weak var delegate: PendingSolicitudeCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
        configureTitle()
        configurePendingDescription()
        configureCloseButton()
    }
    
    func configure(_ viewModel: PendingSolicitudeViewModel) {
        self.viewModel = viewModel
        self.headerTitle.text = localized("contracts_label_pending")
        self.iconImageView.image = Assets.image(named: "icnPendingSignature")
        self.pendintTitleLabel.text = viewModel.name
        self.pendingDescriptionLabel.text = viewModel.timeRemaining
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.viewContainer.backgroundColor = color
    }
    
    func setBorderColor(_ color: UIColor, shadowColor: UIColor) {
        self.clipsToBounds = false
        self.viewContainer.drawRoundedBorderAndShadow(with: ShadowConfiguration(color: shadowColor,
                                                                                opacity: 0.7,
                                                                                radius: 3.0,
                                                                                withOffset: 0.0, heightOffset: 2.0),
                                                      cornerRadius: 6.0,
                                                      borderColor: color,
                                                      borderWith: 1.0)
    }
}

private extension PendingSolicitudeCollectionViewCell {
    func configureView() {
        self.setBorderColor(.mediumSkyGray, shadowColor: .lightSanGray)
    }
    
    func configureTitle() {
        self.headerTitle.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        self.pendintTitleLabel.setSantanderTextFont(type: .bold, size: 18, color: .black)
    }
    
    func configurePendingDescription() {
        self.pendingDescriptionLabel.setSantanderTextFont(type: .bold, size: 10, color: .white)
        self.pendingDescriptionContainer.backgroundColor = .purple
        self.pendingDescriptionContainer.layer.cornerRadius = 2.0
    }
    
    func configureCloseButton() {
        self.closeButton.tintColor = .lightSanGray
        self.closeButton.setImage(Assets.image(named: "icnCloseCarousel")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeButtonSelected), for: .touchUpInside)
    }
    
    @objc func closeButtonSelected(_ button: UIButton) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.pendingSolicitudeClosed(viewModel)
    }
}
