//
//  TrickCollectionViewCell.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 09/07/2020.
//

import UIKit
import CoreFoundationLib

public class TrickCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrickCollectionViewCell"
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var frameView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppareance()
    }
    
    public func setViewModel(_ viewModel: TrickViewModel) {
        self.textLabel?.configureText(withKey: viewModel.textButton)
        guard let imageUrl = viewModel.imageUrl else { return }
        self.iconImageView.loadImage(urlString: imageUrl)
    }
    
    public func setAccessibilityIdentifier(_ accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

private extension TrickCollectionViewCell {
    
    func setAppareance() {
        self.setLabel()
        self.setView()
    }
    
    func setView() {
        self.frameView?.layer.cornerRadius = 5.0
        self.frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.frameView?.layer.borderWidth = 1.0
        self.frameView?.backgroundColor = .white
    }
    
    func setLabel() {
        self.textLabel?.font = .santander(family: .text, type: .regular, size: 20.0)
        self.textLabel?.textColor = .lisboaGray
    }
}
