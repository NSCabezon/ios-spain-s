//
//  OneShortcutButtonOfferImage.swift
//  UIOneComponents
//
//  Created by Laura Gonzalez Salvador on 15/2/22.
//

import UI
import CoreFoundationLib

// MARK: - OfferImageViewActionButton

public final class OneShortcutButtonOfferImage: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var offerImageView: UIImageView!
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

public extension OneShortcutButtonOfferImage {
    func configureView(viewModel: OneShortcutButtonConfiguration) {
        self.setViewModel(viewModel.offerImage)
        self.contentView.setOneCornerRadius(type: .oneShRadius4)
    }
    
    func setAccessibilitySuffix(_ suffix: String? = nil) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

// MARK: - Private Functions

private extension OneShortcutButtonOfferImage {
    func setupView() {
        self.contentView.backgroundColor = .clear
    }
    
    func setViewModel(_ offerImage: OfferImageViewActionButtonViewModel?) {
        switch offerImage?.image {
        case .image(let image):
            offerImageView.image = image
        case .imageURL(let url):
            offerImageView.loadImage(urlString: url)
        case .none:
            break
        }
    }
    
    func setDragIcon() {
        self.dragIcon.image = Assets.image(named: "icnDrag")
        self.dragIcon.isHidden = isHidden
    }
    
    func setDragIconVisibility(isHidden: Bool) {
        self.dragIcon.isHidden = isHidden
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.offerImageView.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonOfferImage + (suffix ?? "")
    }
}
