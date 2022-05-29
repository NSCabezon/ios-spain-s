//
//  SpotImageView.swift
//  RetailClean
//
//  Created by Boris Chirino Fernandez on 22/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit

public enum ButtonType: Int {
    case red = 0
    case black
}

/// custom UIView subclass that draw a spot in the middle of the view
public class SpotImageView: UIView {
    
    public var buttonType: ButtonType = .red
    
    private let bezelImage: UIImage = Assets.image(named: "borderColorPicker") ?? UIImage()
    
    private var selectedRingImageView: UIImageView?

    private lazy var singleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    public var fillColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// this property add a ring on the outside of the colored spot
    public var isActive: Bool = false {
        willSet {
            if newValue {
                selectedRingImageView?.image = bezelImage
            } else {
                selectedRingImageView?.image = nil
            }
        }
    }
    
    public var didTap: ((SpotImageView, Bool) -> Void)?
        
    override public func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: 4, dy: 4) )
        fillColor?.setFill()
        path.fill()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commontInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commontInit()
    }
    
    override public func updateConstraints() {
        super.updateConstraints()
        guard self.selectedRingImageView != nil else { return }
        selectedRingImageView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        selectedRingImageView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selectedRingImageView?.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 4).isActive = true
        selectedRingImageView?.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 4).isActive = true
    }
    
    public func setAccesibilityIdentifiers(_ id: String) {
        self.bezelImage.accessibilityIdentifier = id
    }
        
    private func commontInit() {
        self.clipsToBounds = false
        if self.selectedRingImageView == nil {
            self.selectedRingImageView = UIImageView()
            self.selectedRingImageView?.translatesAutoresizingMaskIntoConstraints = false
            self.selectedRingImageView?.isUserInteractionEnabled = true
            self.selectedRingImageView?.addGestureRecognizer(self.singleTap)
            guard let optionalRingView = self.selectedRingImageView else { return }
            self.addSubview(optionalRingView)
            self.setNeedsUpdateConstraints()
        }
    }
    
    deinit {
        self.selectedRingImageView?.removeGestureRecognizer(singleTap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        didTap?(self, !isActive)
    }
}
