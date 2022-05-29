import CoreFoundationLib
import UIKit
import UI
import OpenCombine

final class SelectOptionButtonView: UIView {
    var contentView: UIView?
    
    var data: [SelectOptionButtonModelRepresentable]?
    var model: PublicMenuOptionRepresentable?
    let onTouchButtonSubject = PassthroughSubject<PublicMenuAction, Never>()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .mediumSkyGray
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(withModel model: PublicMenuOptionRepresentable, options: [SelectOptionButtonModelRepresentable]) {
        self.model = model
        self.data = options
        let optionsLocalized: [LocalizedStylableText] = options.map { localized($0.titleKey) }
        if let identifierSetted = model.accessibilityIdentifier {
            self.accessibilityIdentifier = "\(identifierSetted)View"
        }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, option) in optionsLocalized.enumerated() {
            let identifier = self.composePrefixIdentifier(index: index)
            let view = createView(model: option, identifier: identifier)
            view.tag = index
            stackView.addArrangedSubview(view)
        }
    }
}

private extension SelectOptionButtonView {
    func setupView() {
        contentView = UIView()
        guard let contentView = contentView else { return }
        addSubview(contentView)
        contentView.fullFit()
        contentView.clipsToBounds = true
        contentView.drawRoundedAndShadowedNew(radius: 4,
                                        borderColor: .mediumSky,
                                        widthOffSet: 1,
                                        heightOffSet: 2)
        contentView.addSubview(stackView)
        stackView.fullFit()
    }
    
    func createView(model: LocalizedStylableText, identifier: String?) -> UIView {
        let view = UIView()
        view.backgroundColor = .darkTorquoise
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = createLabel(text: model)
        view.addSubview(label)
        let imageView = createImage()
        view.addSubview(imageView)
        if let identifierSetted = identifier {
            label.accessibilityIdentifier = "\(identifierSetted)Title"
            imageView.accessibilityIdentifier = "\(identifierSetted)Icon"
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressView(sender:))))
        view.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14).isActive = true
        label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -4).isActive = true
        view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0).isActive = true
        label.sizeToFit()
        return view
    }
    
    @objc func didPressView(sender: UITapGestureRecognizer) {
        guard let data = self.data,
              data.indices.contains(tag),
              let tag = sender.view?.tag else { return }
        let item = data[tag]
        self.onTouchButtonSubject.send(item.action)
    }
    
    func createLabel(text: LocalizedStylableText) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = .white
        label.configureText(withLocalizedString: text,
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16),
                                                                                 lineHeightMultiple: 0.75,
                                                                                 lineBreakMode: .byWordWrapping))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.baselineAdjustment = .alignCenters
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createImage() -> UIView {
        let imageView = UIImageView(image: Assets.image(named: "icnArrowWhite"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        return imageView
    }
    
    func composePrefixIdentifier(index: Int) -> String? {
        guard let modelIdentifier = self.model?.accessibilityIdentifier else { return nil }
        var identifier: String?
        switch index {
        case 0: identifier = "\(modelIdentifier)Top"
        case 1: identifier = "\(modelIdentifier)Bottom"
        default: break
        }
        return identifier
    }
}
