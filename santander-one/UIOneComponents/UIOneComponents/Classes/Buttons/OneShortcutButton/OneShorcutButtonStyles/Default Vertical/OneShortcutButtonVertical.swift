//
//  OneShortcutButtonVertical.swift
//  UIOneComponents
//
//  Created by Laura Gonzalez Salvador on 15/2/22.
//

import UI
import CoreFoundationLib

// MARK: - OneShortcutButtonVertical

public final class OneShortcutButtonVertical: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dragIcon: UIImageView!
    @IBOutlet private weak var backgroundImage: UIImageView!
    
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

public extension OneShortcutButtonVertical {
    func configureView(viewModel: OneShortcutButtonConfiguration) {
        setupTitle(viewModel.title)
        setupIcon(viewModel.icon, iconTintColor: viewModel.iconTintColor)
        setupBackgroundImage(viewModel.backgroundImage)
        setupBackgroundColor(viewModel.backgroundColor)
        self.contentView.setOneCornerRadius(type: .oneShRadius4)
        if viewModel.isDisabled && viewModel.backgroundColor == .oneWhite {
            self.setDisabledStyle()
        }
    }
    
    func setAccessibilitySuffix(_ suffix: String? = nil) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

// MARK: - Private Functions

private extension OneShortcutButtonVertical {
    func setupView() {
        self.contentView.backgroundColor = .clear
        self.setupLabel()
        self.setupRadius()
        self.setupDragIcon()
    }
    
    func setupRadius() {
        self.contentView.setOneCornerRadius(type: .oneShRadius4)
    }
    
    func setupLabel() {
        self.titleLabel.textColor = .white
        self.titleLabel.font = UIFont.typography(fontName: .oneB200Regular)
    }
    
    func setupDragIcon() {
        self.dragIcon.image = Assets.image(named: "icnDrag")
        self.dragIcon.isHidden = true
    }
    
    func setupTitle(_ title: String?) {
        guard let title = title else { return }
        titleLabel.text = localized(title)
        titleLabel.textColor = .oneBlack
        titleLabel.numberOfLines = 2
    }
    
    func setupIcon(_ icon: String?, iconTintColor: UIColor?) {
        guard let icon = icon else { return }
        let image = Assets.image(named: icon)
        self.imageIcon.image = image?.withRenderingMode(.automatic)
        guard let iconTintColor = iconTintColor else { return }
        imageIcon.image = image?.withRenderingMode(.alwaysTemplate)
        imageIcon.tintColor = iconTintColor
    }
    
    func setupBackgroundImage(_ image: String?) {
        guard let image = image else { return self.backgroundImage.isHidden = true }
        backgroundImage.isHidden = false
        backgroundImage.image = Assets.image(named: image)
    }
    
    func setupBackgroundColor(_ color: UIColor?) {
        guard let color = color else {
            self.contentView.backgroundColor = .clear
            return
        }
        if color != .oneWhite {
            self.contentView.backgroundColor = color
            self.titleLabel.textColor = .oneWhite
            self.imageIcon.changeImageTintColor(tintedWith: .oneWhite)
        }
    }
    
    func setDisabledStyle() {
        self.titleLabel.textColor = .oneBrownGray
        self.imageIcon.changeImageTintColor(tintedWith: .oneBrownGray)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.imageIcon.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonIcn + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonLabel + (suffix ?? "")
        self.backgroundImage.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonBackgroundImage + (suffix ?? "")
    }
    
    func setDragIconVisibility(isHidden: Bool) {
        self.dragIcon.isHidden = isHidden
    }
}
