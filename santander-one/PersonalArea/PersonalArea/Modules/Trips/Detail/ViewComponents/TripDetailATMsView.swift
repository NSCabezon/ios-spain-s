//
//  TripDetailATMsView.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 02/04/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol TripDetailATMsViewProtocol: AnyObject {
    func didTapImage()
}

final class TripDetailATMsView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageContentView: UIView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleImageLabel: UILabel!
    @IBOutlet private weak var titleImageContentView: UIView!
    @IBOutlet weak var separatorView: UIView!
    weak var delegate: TripDetailATMsViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundTitleImageViewCorner()
    }
}

// MARK: - Private Methods

private extension TripDetailATMsView {
    
    func setupViews() {
        self.setAppearance()
        self.setFonts()
        self.setStrings()
        self.setGestureRecognizer()
    }
    
    func setAppearance() {
        [titleLabel, titleImageLabel].forEach { $0?.textColor = .lisboaGray }
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.numberOfLines = 2
        self.titleLabel.minimumScaleFactor = 0.5
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setImages()
        self.configureBorders()
        self.titleImageContentView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    func setFonts() {
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        titleImageLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
    }
    
    func setImages() {
        self.iconImageView.image = Assets.image(named: "oneIcnAtms")
        self.mapImageView.image = Assets.image(named: "imgAtm")
    }
    
    func configureBorders() {
        self.roundImageCorners()
        let shadowConfiguration = ShadowConfiguration(color: .atmsShadowGray, opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.imageContentView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 3.0, borderColor: .mediumSkyGray, borderWith: 1.0)
    }
    
    func roundImageCorners() {
        self.mapImageView.layer.cornerRadius = 3.0
        self.mapImageView.clipsToBounds = true
    }
    
    func roundTitleImageViewCorner() {
        self.titleImageContentView.roundCorners(corners: [.bottomLeft, .bottomRight],
                                                radius: 3.0)
        self.titleImageContentView.clipsToBounds = true
    }
    
    func setStrings() {
        self.titleLabel.text = localized("yourTrips_label_query")
        self.titleImageLabel.text = localized("yourTrips_button_queryAtm")
    }
    
    func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.mapImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped() {
        delegate?.didTapImage()
    }
}
