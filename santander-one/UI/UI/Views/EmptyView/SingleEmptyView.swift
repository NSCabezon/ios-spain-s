//
//  SingleTitleEmptyView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 22/06/2020.
//

import Foundation
import CoreFoundationLib

enum SingleEmptyAligmentViewStatus {
    case center
    case customConstraints(imageView: [NSLayoutConstraint], titleLabel: [NSLayoutConstraint])
}

final public class SingleEmptyView: UIView {

    private var viewConstraints: [NSLayoutConstraint] = []
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: Assets.image(named: "imgLeaves"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public func centerView() {
        self.configureConstraints(aligment: .center)
        self.titleLabel.numberOfLines = 0
    }
}

public extension SingleEmptyView {
    func updateTitle(_ title: LocalizedStylableText, styleConfig: LocalizedStylableTextConfiguration? = nil) {
        let localizedConfig = styleConfig ?? LocalizedStylableTextConfiguration(lineHeightMultiple: 0.70)

        self.titleLabel.configureText(withLocalizedString: title,
                                      andConfiguration: localizedConfig)
    }
    
    func imageIsHidden(_ hidden: Bool) {
        imageView.isHidden = hidden
    }
    
    func titleFont(_ font: UIFont, color: UIColor = .lisboaGray) {
        titleLabel.font = font
        titleLabel.textColor = color
    }
}

private extension SingleEmptyView {
    func commonInit() {
        backgroundColor = .white
        addSubview(imageView)
        viewConstraints.append(contentsOf: [
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 210.0)
        ])
        addSubview(titleLabel)
        viewConstraints.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 84.0),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 46.0),
            self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 46.0)
        ])
        NSLayoutConstraint.activate(viewConstraints)
        titleLabel.font = .santander(family: .headline, size: 20.0)
        titleLabel.textColor = .lisboaGray
        setAccessibilityIdentifiers()
    }

    func configureConstraints(aligment: SingleEmptyAligmentViewStatus) {
        NSLayoutConstraint.deactivate(viewConstraints)
        switch aligment {
        case .center:
            viewConstraints = [
                self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 46.0),
                self.imageView.heightAnchor.constraint(equalToConstant: 210.0),
                self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ]
        case .customConstraints(imageView: let imageConstraints, titleLabel: let titleConstraints):
            viewConstraints.append(contentsOf: imageConstraints)
            viewConstraints.append(contentsOf: titleConstraints)
        }
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityEmptyView.emptyViewView
        titleLabel.accessibilityIdentifier = AccessibilityEmptyView.emptyViewTitle
        imageView.accessibilityIdentifier = AccessibilityEmptyView.emptyViewImage
    }
}
