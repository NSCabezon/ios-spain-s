//
//  ReportFraud.swift
//  PersonalArea
//
//  Created by alvola on 30/03/2020.
//

import CoreFoundationLib
import UI

final class ReportFraud: DesignableView {
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    private var view: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.layoutSubviews()
        frameView.layoutSubviews()
        titleLabel.configureText(withKey: "yourTrips_button_fraud",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: titleLabel.font.withSize(frameView.bounds.width < 150 ? 15.0 : 20.0)))
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabels()
    }
    
    private func configureView() {
        frameView.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSky, widthOffSet: 1, heightOffSet: 2)
        frameView.backgroundColor = .white
        contentView?.backgroundColor = .clear
        contentView?.isUserInteractionEnabled = false
    }
    
    private func configureLabels() {
        titleLabel.textColor = .lisboaGray
        titleLabel.minimumScaleFactor = 0.3
        setTitle("yourTrips_button_fraud", image: "icnThief")
        phoneImageView.image = Assets.image(named: "icnCornerPhone")
    }
    
    func setTitle(_ title: String, image: String) {
        titleLabel.configureText(withKey: title,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .light, size: 20.0),
                                                                                      lineHeightMultiple: 0.85))
        iconImageView?.image = Assets.image(named: image)
        setNeedsLayout()
    }
}
