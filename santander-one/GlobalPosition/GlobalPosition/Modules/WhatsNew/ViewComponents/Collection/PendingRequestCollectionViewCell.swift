//
//  PendingRequestCollectionViewCell.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 09/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

class PendingRequestCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var headerTitle: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var identifierLabel: UILabel!
    @IBOutlet private weak var identifierValueLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var stateValueLabel: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var pdfIconImageView: UIImageView!

    private var viewModel: PendingSolicitudeViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
        configureImages()
        configureLabels()
    }
    
    func configure(_ viewModel: PendingSolicitudeViewModel) {
        self.viewModel = viewModel
        identifierValueLabel.text = (viewModel.entity.identifier ?? "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        headerTitle.configureText(withKey: viewModel.name ?? "",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16),
                                                                                       lineHeightMultiple: 0.75))
    }
}

private extension PendingRequestCollectionViewCell {
    
    func configureView() {
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.darkTorquoise.withAlphaComponent(0.33).cgColor
    }
    
    func configureImages() {
        iconImageView.image = Assets.image(named: "icnPendingSignatureGreen")
        pdfIconImageView.image = Assets.image(named: "icnPdfGreen")
    }
    
    func configureLabels() {
        headerTitle.setSantanderTextFont(type: .bold, size: 16, color: .darkTorquoise)
        identifierLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        identifierValueLabel.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        stateLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        stateValueLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        viewContainer.drawBorder(cornerRadius: 6, color: UIColor.lightSkyBlue, width: 1)
        
        identifierLabel.text = localized("whatsNew_label_identifier")
        stateLabel.text = localized("whatsNew_label_state")
        stateValueLabel.text = localized("contracts_label_pending")
        
        identifierValueLabel.adjustsFontSizeToFitWidth = true
    }
}
