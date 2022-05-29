//
//  MapView.swift
//  UI
//
//  Created by Juan Carlos López Robles on 12/5/19.
//

import UIKit
import CoreFoundationLib

public class MapView: UIView {
    private lazy var button: UIButton = {
        let mapButton = UIButton()
        mapButton.addTarget(self, action: #selector(mapSelected), for: .touchUpInside)
        mapButton.contentMode = .scaleAspectFill
        return mapButton
    }()
    
    private lazy var imageView: UIImageView = {
        let mapImageView = UIImageView()
        let image = Assets.image(named: "imgMap")
        mapImageView.image = image
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.clipsToBounds = true
        return mapImageView
    }()
    private var action: (() -> Void)?
    
    public convenience init(action: @escaping () -> Void) {
        self.init(frame: .zero)
        self.action = action
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setup()
    }
    
    private func setup() {
        self.addViewConstraints()
        self.addSubview(imageView)
        self.imageView.fullFit()
        self.addSubview(button)
        self.button.fullFit()
        self.addSubview(BlueLineView(position: .boottom))
        self.addShadow()
    }
    
    private func addShadow() {
        self.layer.shadowColor = UIColor.mediumSky.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    private func addViewConstraints() {
        guard let container = superview else { return }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 88),
            widthAnchor.constraint(equalTo: container.widthAnchor)
        ])
    }
    
    @objc
    private func mapSelected() {
        self.action?()
    }
}
