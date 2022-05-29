//
//  GlobileInitialButton.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

enum GlobileInitialButtonIconStyle {
    case red, darksky, accesibleSky, grey, white
}

class GlobileInitialButton: GlobileButton {
    
    var iconTintColor: GlobileInitialButtonIconStyle = .red
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - Override methods
extension GlobileInitialButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300.0, height: 88.0)
    }
}

extension GlobileInitialButton {
    
    override func setup() {
        super.setup()
        backgroundColor = .white
        setTitleColor(.darkGray, for: .normal)
        titleLabel?.font = .santanderText(type: .regular, with: fontSize)
        titleLabel?.numberOfLines = 2
        titleLabel?.lineBreakMode = .byTruncatingTail
        addShadow()
        addTarget(self, action: #selector(actionSelectorEndEditing), for: .touchUpInside)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        layer.borderColor = UIColor.mediumSky.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        
        //Defaul case
        imageView?.tintColor = .santanderRed
        
        switch iconTintColor {
        case .red:
            imageView?.tintColor = .santanderRed
        case .darksky:
            imageView?.tintColor = .darkSky
        case .accesibleSky:
            imageView?.tintColor = .accessibleDarkSky
        case .grey:
            imageView?.tintColor = .darkGray
        case .white:
            imageView?.tintColor = .white
        }
    }
    
    private func addShadow() {
        clipsToBounds = false
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
    }
    
    @objc fileprivate func actionSelectorEndEditing() {
        self.parentViewController?.view.endEditing(true)
    }
    
}

extension GlobileInitialButton {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
