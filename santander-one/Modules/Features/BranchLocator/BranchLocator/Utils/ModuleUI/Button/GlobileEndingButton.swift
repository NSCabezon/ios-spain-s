//
//  GlobileEndingButton.swift
//  BranchLocator
//
//  Created by Hernán Villamil on 24/9/21.
//

import Foundation

enum GlobileEndingButtonStyle {
    case primary, secondary
}

class GlobileEndingButton: GlobileButton {
    
    var style: GlobileEndingButtonStyle = .primary
    
    @IBInspectable public var isPrimary: Bool = true {
        didSet {
            style = isPrimary ? .primary : .secondary
            setup()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            setup()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

//MARK: Override methods
extension GlobileEndingButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300.0, height: 44.0)
    }
}

extension GlobileEndingButton {
    
    override func setup() {
        super.setup()
        let colors = getColors(style: style)
        backgroundColor = colors.background
        setTitleColor(colors.title, for: .normal)
        if isEnabled {
            if style == .primary{
                titleLabel?.font = .santander(family: .text, type: .bold, size: fontSize)
            } else {
                titleLabel?.font = .santander(family: .text, type: .regular, size: fontSize)
            }
        } else {
            titleLabel?.font = .santander(family: .text, type: .regular, size: fontSize)
        }
        
        addTarget(self, action: #selector(actionSelectorEndEditing), for: .touchUpInside)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        let colors = getColors(style: style)
        clipsToBounds = true
        layer.borderColor = colors.border
        layer.borderWidth = 1.0
        layer.cornerRadius = (frame.height / 2)
        imageView?.tintColor = colors.title
    }
    
    private func getColors(style: GlobileEndingButtonStyle) -> (background: UIColor, title: UIColor, border: CGColor) {
        
        var backColor = UIColor.santanderRed
        var titleColor = UIColor.white
        var borderColor = UIColor.santanderRed.cgColor
        
        if isEnabled {
            if style == .secondary {
                backColor = .clear
                titleColor = .santanderRed
            }
        } else {
            backColor = .clear
            titleColor = .lisboaGray
            borderColor = UIColor.lisboaGray.cgColor
        }
        return (backColor, titleColor, borderColor)
    }
    
    @objc private func actionSelectorEndEditing() {
        self.parentViewController?.view.endEditing(true)
    }
}

extension GlobileEndingButton {
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
