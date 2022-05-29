//
//  RightArrowButtton.swift
//  UI
//
//  Created by Juan Carlos López Robles on 4/28/20.
//

import Foundation

public final class RightArrowButtton: UIButton {
    private let edgeInset: CGFloat = 5.0
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setApperance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setApperance()
    }
    
    public override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted ? .sky : .white
        }
    }

    public var showArrow: Bool = true {
        didSet {
            self.setupRightImage()
            self.setupMargins()
        }
    }
}

private extension RightArrowButtton {
    private func setApperance() {
        self.setupLayers()
        self.setupRightImage()
        self.setupMargins()
        self.setupTextAppearance()
    }
    
    private func setupLayers() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.darkTorquoise.cgColor
    }
    
    private func setupRightImage() {
        self.tintColor = .darkTorquoise
        self.semanticContentAttribute = .forceRightToLeft
        self.setImage(showArrow ? Assets.image(named: "icnArrowTransaction") : nil, for: .normal)
    }
    
    private func setupTextAppearance() {
        self.setTitleColor(.darkTorquoise, for: .normal)
        self.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 11)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func setupMargins() {
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: edgeInset * 2, bottom: 0, right: showArrow ? edgeInset : edgeInset * 2)
    }
}
