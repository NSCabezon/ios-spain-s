//
//  HeaderFXView.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 20/1/22.
//

import UIKit
import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

struct PrivateMenuHeaderOption {
    var titleKey: String
    var imageName: String
    var accessibilityIdentifier: String
    
    init(titleKey: String,
         imageName: String,
         accessibilityIdentifier: String) {
        self.titleKey = titleKey
        self.imageName = imageName
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

final class HeaderFXView: UIView {
    private struct Constants {
        static let zero: CGFloat = 0
        static let labelNumberOfLines = 2
        static let badgeBorderWidth: CGFloat = 1.0
        static let badgeCornerRadius: CGFloat = 5.5
        static let badgeSize: CGFloat = 11.0
        static let badgeYAnchor: CGFloat = 2.0
        static let pressViewCornerRadius: CGFloat = 4.0
        static let iconSize: CGFloat = 32.0
        static let iconCornerRadius = Constants.iconSize / 2
        static let containerTopAnchor: CGFloat = 2.0
        static let fontSize: CGFloat = 14.0
        static let lineHeightMultiple: CGFloat = 0.75
    }
    
    private var roundedIcon: Bool?
    private var anySubscriptions = Set<AnyCancellable>()
    private var option: PrivateMenuHeaderOption?
    let optionSubject = PassthroughSubject<PrivateMenuHeaderOption, Never>()

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = Constants.zero
        
        return stack
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        return image
    }()
    
    private let labelContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = Constants.labelNumberOfLines
        label.textColor = .lisboaGray
        return label
    }()
    
    private lazy var pressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.santanderRed
        view.layer.borderColor = UIColor.bg.cgColor
        view.layer.borderWidth = Constants.badgeBorderWidth
        view.isHidden = true
        addSubview(view)
        view.layer.cornerRadius = Constants.badgeCornerRadius
        view.heightAnchor.constraint(equalToConstant: Constants.badgeSize).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.badgeSize).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.zero).isActive = true
        view.centerYAnchor.constraint(equalTo: imageView.topAnchor, constant: Constants.badgeYAnchor).isActive = true
        view.accessibilityIdentifier = "PrivateMenuViewNotificationBadge"
        return view
    }()
    
    var pressFXColor: UIColor = .lightSky {
        didSet {
            pressView.backgroundColor = pressFXColor
        }
    }
    
    var contentTopAnchor: NSLayoutYAxisAnchor {
        return containerStackView.topAnchor
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    func showNotificationBadge(_ show: Bool) {
        badgeView.isHidden = !show
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressView.isHidden = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pressView.isHidden = true
        guard let option = self.option else { return }
        self.optionSubject.send(option)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pressView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pressView.layer.cornerRadius = Constants.pressViewCornerRadius
        if roundedIcon == true {
            imageView.layer.cornerRadius = Constants.iconSize / Constants.iconCornerRadius
        }
    }
}

private extension HeaderFXView {
    func setupViews() {
        pressView.embedInto(container: self)
        addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])
        label.widthAnchor.constraint(equalTo: pressView.widthAnchor).isActive = true
        clipsToBounds = false
        bind()
    }
    func setTitle(_ titleKey: String) {
        let font = UIFont.santander(family: .text,
                                    type: .regular,
                                    size: Constants.fontSize)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .center,
                                                               lineHeightMultiple: Constants.lineHeightMultiple,
                                                               lineBreakMode: .byWordWrapping)
        label.configureText(withKey: titleKey, andConfiguration: configuration)
    }
    
    func setIcon(_ iconKey: String?) {
        guard let iconKey = iconKey else {
            return
        }
        imageView.image = Assets.image(named: iconKey)
    }
    
    func setAccessibilityIdentifiers(_ option: PrivateMenuHeaderOption) {
        self.label.accessibilityIdentifier = option.titleKey
        self.imageView.accessibilityIdentifier = option.imageName
    }
    
    func bind() {
        optionSubject.sink { [unowned self] option in
            self.option = option
            self.setTitle(option.titleKey)
            self.setIcon(option.imageName)
            self.setAccessibilityIdentifiers(option)
        }.store(in: &anySubscriptions)
    }
}

