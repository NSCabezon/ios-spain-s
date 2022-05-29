//
//  SubsectionButtonView.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 15/07/2020.
//

import UI
import CoreFoundationLib

protocol SubsectionButtonProtocol: AnyObject {
    func didSelectSubsection(_ subSection: PersonalAreaSection)
}

final class SubsectionButtonView: XibView {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var accesoryImageView: UIImageView!
    private weak var delegate: SubsectionButtonProtocol?
    private var info: SubsectionInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configureBorders()
    }
    
    func setInfo(_ info: SubsectionInfo) {
        iconImageView.image = Assets.image(named: "\(info.iconName)")
        guard let title = info.title else { return }
        label.configureText(withLocalizedString: title,
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0)))
        label.textColor = .darkTorquoise
        self.info = info
        self.layoutIfNeeded()
    }
    
    func setDelegate(_ delegate: SubsectionButtonProtocol) {
        self.delegate = delegate
    }
    
    func setAccessibilityIdentifiers(_ info: SubsectionInfo) {
        self.iconImageView.accessibilityIdentifier = info.iconAccessibilityIdentifier
        self.label.accessibilityIdentifier = info.titleAccessibilityIdentifier
        self.accesoryImageView.accessibilityIdentifier = info.arrowAccessibilityIdentifier
    }
}

// MARK: - Private Methods
private extension SubsectionButtonView {
    
    func setupView() {
        accesoryImageView.image = Assets.image(named: "icnArrowThinRight")
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
    }
    
    func configureBorders() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mediumSkyGray.cgColor
    }
    
    @objc func didTapView() {
        guard let subsection = info?.goToSection else { return }
        delegate?.didSelectSubsection(subsection)
    }
}
