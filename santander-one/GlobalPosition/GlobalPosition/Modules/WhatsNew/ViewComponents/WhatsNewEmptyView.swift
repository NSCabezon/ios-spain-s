//
//  WhatsNewEmptyView.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 24/07/2020.
//

import Foundation
import CoreFoundationLib
import UI

final public class WhatsNewEmptyView: UIView {

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
}

public extension WhatsNewEmptyView {
    func updateTitle(_ title: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: title,
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20.0),
                                                                                           lineHeightMultiple: 0.7))
    }
}

private extension WhatsNewEmptyView {
    func commonInit() {
        backgroundColor = .white
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        imageView.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 70.0).isActive = true
        self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 70.0).isActive = true
        titleLabel.textColor = .lisboaGray
    }
}
