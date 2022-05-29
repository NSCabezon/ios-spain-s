//
//  VersionDetailTitle.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import UI
import CoreFoundationLib

final class VersionDetailTitle: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

private extension VersionDetailTitle {
    func commonInit() {
        self.configureView()
    }
    
    func configureView() {
        self.backgroundColor = UIColor.white
        self.heightAnchor.constraint(equalToConstant: 57.0).isActive = true
        var last: UIView = self.addLine(1.0, color: .mediumSkyGray, below: nil)
        last = self.addLine(7.0, color: .skyGray, below: last)
        last = self.addLine(1.0, color: .mediumSkyGray, below: last)
        self.addTitle(below: last)
    }
    
    func addLine(_ height: CGFloat, color: UIColor, below: UIView?) -> UIView {
        let lineView = UIView()
        self.addSubview(lineView)
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        self.trailingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 0.0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: height).isActive = true
        lineView.topAnchor.constraint(equalTo: below?.bottomAnchor ?? self.topAnchor, constant: 0.0).isActive = true
        return lineView
    }
    
    func addTitle(below: UIView) {
        let titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.lisboaGray
        titleLabel.configureText(withKey: "appInformation_label_newsLastUpdate",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 20.0)))
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.accessibilityIdentifier = AccesibilityConfigurationPersonalArea.newsLastUpdate
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: below.bottomAnchor, constant: 16.0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 29.0).isActive = true
    }
}
