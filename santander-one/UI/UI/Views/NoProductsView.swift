//
//  NoProductsView.swift
//  UI
//
//  Created by alvola on 10/01/2020.
//

import UIKit
import CoreFoundationLib

public enum NoProductsMode {
    case black
    case white
}
public final class NoProductsView: UIView {
    
    var backgroundImage: UIImageView?
    var noResultsLabel: UILabel?
    
    var mode: NoProductsMode = .white {
        didSet {
            noResultsLabel?.textColor = mode == .black ? UIColor.white : UIColor(red: 109.0/255.0, green: 109.0/255.0, blue: 109.0/255.0, alpha: 1.0)
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImage?.frame = frame
        noResultsLabel?.frame = frame
    }
    
    public func setMode( _ mode: NoProductsMode) {
        self.mode = mode
    }
    
    private func commonInit() {
        configureBackground()
        configureLabel()
        setAccessibilityIdentifiers()
    }
    
    private func configureBackground() {
        backgroundImage = UIImageView(frame: frame)
        guard let backgroundImage = backgroundImage else { return }
        backgroundImage.backgroundColor = UIColor.clear
        addSubview(backgroundImage)
        backgroundImage.image = Assets.image(named: "imgLeaves")
        backgroundImage.translatesAutoresizingMaskIntoConstraints = true
        backgroundImage.center = CGPoint(x: bounds.midX, y: bounds.midY)
        backgroundImage.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
    }
    
    private func configureLabel() {
        noResultsLabel = UILabel(frame: frame)
        guard let noResultsLabel = noResultsLabel else { return }
        addSubview(noResultsLabel)

        noResultsLabel.translatesAutoresizingMaskIntoConstraints = true
        noResultsLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
        noResultsLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        noResultsLabel.backgroundColor = UIColor.clear
        noResultsLabel.textColor = mode == .black ? UIColor.white : UIColor.mediumSanGray
        noResultsLabel.configureText(withKey: "pg_label_emptyView", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, size: 20.0), alignment: .center))
        noResultsLabel.numberOfLines = 0
    }
    
    private func setAccessibilityIdentifiers() {
        noResultsLabel?.accessibilityIdentifier = "pg_label_emptyView"
        backgroundImage?.accessibilityIdentifier = "pg_image_background"
    }
}

extension NoProductsView {
    public func setLabelWithLocalizedText(_ localizedText: LocalizedStylableText) {
        self.noResultsLabel?.configureText(withLocalizedString: localizedText)
    }
}
