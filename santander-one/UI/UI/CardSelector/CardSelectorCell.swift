//
//  CardSelectorCell.swift
//  UI
//
//  Created by Ignacio González Miró on 19/10/2020.
//

import UIKit
import CoreFoundationLib

final public class CardSelectorCell: UITableViewCell {
    @IBOutlet weak private var cardImage: UIImageView!
    @IBOutlet weak private var cardTitle: UILabel!
    @IBOutlet weak private var cardNumber: UILabel!
    
    public static var identifier: String {
        String(describing: self)
    }
    public static var bundle: Bundle? {
        return .module
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.setupView()
    }
    
    public func setup(_ imageUrl: String, title: String, number: LocalizedStylableText) {
        self.cardImage.loadImage(urlString: imageUrl, placeholder: Assets.image(named: "defaultCard"))
        self.cardTitle.text = title
        self.cardNumber.configureText(withLocalizedString: number)
    }
}

private extension CardSelectorCell {
    func setupView() {
        self.configureSelectedBackground()
        self.setAccessibilityIds()
        self.selectionStyle = .gray
        self.cardTitle.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        self.cardNumber.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
    }
    
    func setAccessibilityIds() {
        self.cardImage.accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.cardImage.rawValue
        self.cardTitle.accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.pickerTitle.rawValue
        self.cardNumber.accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.pickerNumber.rawValue
    }
    
    func configureSelectedBackground() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightSanGray.withAlphaComponent(0.7)
        self.selectedBackgroundView = backgroundView
    }
}
