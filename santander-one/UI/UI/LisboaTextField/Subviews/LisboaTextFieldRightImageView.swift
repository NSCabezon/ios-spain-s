//
//  LisboaTextFieldRightImageView.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 22/06/2020.
//

import Foundation

public final class LisboaTextFieldRightImageView: UIView {
    
    private var imageView: UIImageView
    private let action: () -> Void
    private var imageName: String?
    private var identifier: String?
    
    init(imageName: String, action: @escaping () -> Void) {
        self.imageView = UIImageView(image: Assets.image(named: imageName))
        self.imageName = imageName
        self.action = action
        super.init(frame: .zero)
        self.setup()
    }
    
    init(image: UIImage?, action: @escaping () -> Void) {
        self.imageView = UIImageView(image: image)
        self.action = action
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFit
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectImage)))
        self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc func didSelectImage() {
        self.action()
    }
    
    func changeImage(_ imageName: String?) {
        guard let imageName = imageName else { return }
        self.imageView.image = Assets.image(named: imageName)
        self.imageName = imageName
        setAccessibilityIdentifier(identifier: self.identifier)
        self.imageView.setNeedsDisplay()
    }
    
    func setAccessibilityIdentifier(identifier: String? = nil) {
        self.identifier = identifier ?? ""
        self.imageView.accessibilityIdentifier = "\(self.identifier ?? "")_\(imageName ?? "")"
    }
}
