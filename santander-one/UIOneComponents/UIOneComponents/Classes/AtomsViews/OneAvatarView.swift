//
//  OneAvatarView.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 06/09/2021.
//

import UI
import CoreFoundationLib

public final class OneAvatarView: XibView {
    
    @IBOutlet private weak var avatarLabel: UILabel!
    @IBOutlet private weak var avatarImage: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setupAvatar(_ viewModel: OneAvatarViewModel) {
        self.avatarLabel.text = viewModel.initials
        self.avatarLabel.backgroundColor = viewModel.color
        self.avatarImage.contentMode = .scaleAspectFill
        if let urlString = viewModel.imageUrlString {
            self.avatarImage.loadImage(urlString: urlString) { [weak self] in
                self?.avatarImage.isHidden = self?.avatarImage.image == nil
                self?.configureBorder()
            }
        } else {
            self.avatarImage.image = viewModel.image
            self.avatarImage.isHidden = self.avatarImage.image == nil
            self.configureBorder()
        }
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

private extension OneAvatarView {
    func configureView() {
        self.configureLabel()
        self.configureRadius()
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabel() {
        self.avatarLabel.textColor = .white
        switch self.frame.height {
        case 64:
            self.avatarLabel.font = UIFont.typography(fontName: .oneH400Bold)
        case 48:
            self.avatarLabel.font = UIFont.typography(fontName: .oneH100Bold)
        case 40:
            self.avatarLabel.font = UIFont.typography(fontName: .oneH100Bold)
        case 32:
            self.avatarLabel.font = UIFont.typography(fontName: .oneB200Bold)
        default:
            self.avatarLabel.font = UIFont.typography(fontName: .oneB200Bold)
        }
    }
    
    func configureRadius() {
        self.layer.masksToBounds = true
        self.setOneCornerRadius(type: .oneShRadiusCircle)
    }

    func configureBorder() {
        if self.avatarImage.isHidden { // Show border
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 1.0
        } else { // Hide border
            self.layer.borderWidth = 0.0
        }
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneAvatarView + (suffix ?? "")
        self.avatarLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAvatarTitle + (suffix ?? "")
        self.avatarImage.accessibilityIdentifier = AccessibilityOneComponents.oneAvatarImg + (suffix ?? "")
    }
}
