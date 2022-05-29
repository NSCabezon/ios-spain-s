import Foundation
import CoreFoundationLib

public struct LeftIconLisboaViewModel {
    let image: String
    let title: String
    
    public init(image: String, title: String) {
        self.image = image
        self.title = title
    }
}

public class LeftIconLisboaButton: LisboaButton {
    private var viewModel: LeftIconLisboaViewModel?

    public convenience init(_ viewModel: LeftIconLisboaViewModel) {
        self.init(frame: .zero)
        self.viewModel = viewModel
        self.setImage(Assets.image(named: viewModel.image), for: .normal)
        self.set(localizedStylableText: localized(viewModel.title), state: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        self.setTitleColor(.white, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = .bostonRed
        self.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.titleLabel?.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel?.textColor = .white
    }

    @objc
    override func didPressButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.backgroundColor = UIColor.bostonRed.withAlphaComponent(0.5)
            self.borderColor = UIColor.bostonRed.withAlphaComponent(0.5)
        } else if gestureRecognizer.state == .ended {
            self.backgroundColor = .bostonRed
            self.borderColor = .bostonRed
        }
    }
}
