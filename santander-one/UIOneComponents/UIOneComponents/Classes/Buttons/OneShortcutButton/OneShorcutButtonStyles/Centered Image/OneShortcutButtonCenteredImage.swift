//
//  OneShortcutButtonCenteredImage.swift
//  UIOneComponents
//
//  Created by Laura Gonzalez Salvador on 15/2/22.
//

import UI
import CoreFoundationLib

// MARK: - OneShortcutButtonCenteredImage

public final class OneShortcutButtonCenteredImage: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var dragIcon: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
}

// MARK: - Public Functions

public extension OneShortcutButtonCenteredImage {
    func configureView(viewModel: OneShortcutButtonConfiguration) {
        guard let imageKey = viewModel.backgroundImage else { return }
        setImageIcon(imageKey: imageKey, iconTintColor: viewModel.iconTintColor)
    }
    
    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

// MARK: - Private Functions

private extension OneShortcutButtonCenteredImage {
    func setupView() {
        self.contentView.backgroundColor = .clear
        self.setupDragIcon()
    }
    
    func setImageIcon(imageKey: String, iconTintColor: UIColor?) {
        let image = Assets.image(named: imageKey)
        imageIcon.image = image?.withRenderingMode(.alwaysTemplate)
        guard let iconTintColor = iconTintColor else { return }
        imageIcon.tintColor = iconTintColor
    }
    
    func setupDragIcon() {
        self.dragIcon.image = Assets.image(named: "icnDrag")
        self.dragIcon.isHidden = true
    }
    
    func setDragIconVisibility(isHidden: Bool) {
        self.dragIcon.isHidden = isHidden
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.imageIcon.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonImage + (suffix ?? "")
    }
}
