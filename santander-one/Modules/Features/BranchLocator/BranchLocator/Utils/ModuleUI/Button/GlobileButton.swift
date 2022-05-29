//
//  GlobileButton.swift
//  Account
//
//  Created by Hernán Villamil on 24/9/21.
//

import UIKit

enum GlobileButtonPosition {
    case left, top, right, bottom
}

class GlobileButton: UIButton {
    
    fileprivate var imagePadding: CGFloat = 0.0
    fileprivate var imagePosition: GlobileButtonPosition = .right
    fileprivate var action: (() -> ())?
    @IBInspectable public var fontSize: CGFloat = 16.0 {
        didSet {
            setup()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupSubviews()
    }
    
    public func setImage(_ image: UIImage?, position: GlobileButtonPosition, withPadding padding: CGFloat = 8.0) {
        imagePadding = padding
        imagePosition = position
        if position == .right {
            semanticContentAttribute = .forceRightToLeft
        } else if position == .left {
            semanticContentAttribute = .forceLeftToRight
        }
        if #available(iOS 12.0, *) {
            let imageToSet = resizeImage(image: image!, targetSize: CGSize(width: 24.0, height: 24.0))
            setImage(imageToSet, for: .normal)
        } else {
            setImage(image, for: .normal)
        }
    }
    
    public func onClick(_ action: (() -> Void)?) {
        self.action = action
    }
}

extension GlobileButton {
    @objc func setup() {
        titleLabel?.textAlignment = .center
        addTarget(self, action: #selector(actionSelector), for: .touchUpInside)
    }
    
    @objc func setupSubviews(){
        if imageView?.image != nil {
            if imagePosition == .left {
                imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imagePadding)
            } else if imagePosition == .right {
                imageEdgeInsets = UIEdgeInsets(top: 0, left: imagePadding, bottom: 0, right: 0)
            } else {
                alignVertical(withSpacing: imagePadding, position: imagePosition)
            }
        }
        titleLabel?.numberOfLines = 2
    }
    
    @objc private func actionSelector() {
        action?()
    }
    
    func alignVertical(withSpacing spacing: CGFloat, position: GlobileButtonPosition) {
        self.imageView?.contentMode = .scaleAspectFit
        guard let imageSize = self.imageView?.image?.size,
            let text = self.titleLabel?.text,
            let font = self.titleLabel?.font
            else { return }
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: font])
        if position == .top {
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
            let buttonWidth = self.frame.width
            let imageWidth = self.imageView!.frame.width
            imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: (buttonWidth - imageWidth)/2, bottom: 0, right: (buttonWidth - imageWidth)/2)
        } else {
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: titleSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
            titleEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: imageSize.width)
        }
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
