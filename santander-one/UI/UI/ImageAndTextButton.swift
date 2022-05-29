import UIKit

public class ImageAndTextButton: XibView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var button: UIButton!
    private var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }
    
    public func set(title: String, image: String, target: Any, action: Selector?, tintColor: UIColor, template: Bool) {
        setup(title: title, image: image, tintColor: tintColor, template: template)
        if let actionUnwrapped = action {
            self.button.addTarget(target, action: actionUnwrapped, for: UIControl.Event.touchUpInside)
        }
    }
    
    public func set(title: String, image: String, action: @escaping () -> Void, tintColor: UIColor, template: Bool) {
        setup(title: title, image: image, tintColor: tintColor, template: template)
        self.action = action
        self.button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
}

private extension ImageAndTextButton {
    func configureViews() {
        self.backgroundColor = UIColor.clear
        self.view?.backgroundColor = UIColor.clear
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 10)
        self.titleLabel.textColor = UIColor.mediumSanGray
    }
    
    func setup(title: String, image: String, tintColor: UIColor, template: Bool) {
        if tintColor == UIColor.white {
            self.titleLabel.textColor = UIColor.white
        }
        self.titleLabel.text = title
        if template {
            self.imageView.image = Assets.image(named: image)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        } else {
            self.imageView.image = Assets.image(named: image)
        }
        self.imageView.tintColor = tintColor
        self.accessibilityLabel = title
        self.titleLabel.accessibilityElementsHidden = true
        self.button.accessibilityElementsHidden = true
        self.isAccessibilityElement = true
    }
    
    @objc func didTap() {
        self.action?()
    }
}
