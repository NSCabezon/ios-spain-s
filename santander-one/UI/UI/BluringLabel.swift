//
//  BluringLabel.swift
//  BluredLabel
//
//  Created by Boris Chirino Fernandez on 15/01/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import CoreFoundationLib
/**
     Blur any UILabel text by removing the current text and adding a CALayer object to the existint Layer. To apply blur correctly textcolor property must be set and if used throught attributed text foreground key must be present.
  
    - Important: Prior to set isBlured the label must have text or attributed text setted in order to render correctly the CALayer object. Also if the instance is not refered by a xib or storyboard call initializeCanvas after allocation happens
 */
open class BluringLabel: UILabel {
    
    // MARK: Properties
    
    /// The maximum blur radius that is applied to the text
    open var blurRadius: CGFloat = 20.0
    
    /// layer for drawing the resulting images
    private var blurLayer: CALayer!
    
    /// string when setting text Property
    private var textToRender: String?
    
    /// string when setting attributedText property
    private var attributedTextToRender: NSAttributedString?

    /// rendered text without blur
    private var renderedTextImage: UIImage?
    
    /// rendered text with blur
    private var blurredTextImage: UIImage?
    
    private var adjustedTextAlignment: Bool = false
    
    open var renderMargin: CGFloat = 0.0
    /// Setting this to true cause that **textalignment** property will be added to paragraph style in case attributed string does not include it. This is a must have if the attributed string does not contain **NSAttributedString.Key.paragraphStyle**
    open var applyTextAlignmentToAttributedText: Bool = false
    
    private enum Constants {
        static let decimalsRatio: CGFloat = 0.70
        static let charactersRatio: CGFloat = 2.1
    }
    // context for rendering images
    private lazy var context: CIContext = {
         let instance = CIContext(options: nil)
         return instance
     }()
    
    private lazy var blurFilter: CIFilter = {
        return CIFilter(name: "CIGaussianBlur") ?? CIFilter()
    }()
    
    /// set if the component will be blured or not
    open var isBlured: Bool = false {
        didSet {
            self.renderImages()
            self.setAccessibility()
        }
    }
    
    // MARK: - Initializers
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    /**
     Prepare the instance to draw correclty. Call this method only if is created with the init() constructor
     - Important: Ignoring this method if the instance is not created in storyboard or xib may cause undesired behaviour
     */
    open func initializeCanvas() {
        commonInit()
    }
    
    deinit {
        renderedTextImage = nil
        blurredTextImage = nil
    }
    
    private func commonInit() {
        super.text = nil
        if self.blurLayer != nil {
            self.blurLayer.removeFromSuperlayer()
        }
        self.blurLayer = self.setupBlurLayer()
        self.layer.addSublayer(self.blurLayer)
    }
    
        // MARK: - Overrides
    
    open override var text: String? {
        get {
            return textToRender
        }
        set(newValue) {
            textToRender = newValue
            attributedTextToRender = nil
        }
    }
    
    open override var attributedText: NSAttributedString? {
        get {
            return attributedTextToRender
        }
        set(newValue) {
            attributedTextToRender = newValue
            textToRender = nil
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        if let renderedTextImage = renderedTextImage {
                   return renderedTextImage.size
               }
        return CGSize.zero
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.equalTo(blurLayer.bounds) == false {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.blurLayer.frame = bounds
            
            // Text Alignment
            if  adjustedTextAlignment == false {
                setTextAlignmentFrame()
            }
            CATransaction.setDisableActions(false)
            CATransaction.commit()
        }
    }
    
    open func redraw() {
        renderImages()
    }
}

private extension BluringLabel {
    
    /// Add the specified alignment to existing NSAttributedString
    /// - Parameters:
    ///   - alignment: the alignment passed will be added to the paragraphStyle key
    ///   - attrString: instance of NSAttributedString that need modifications
    func addTextAlignment(_ alignment: NSTextAlignment, toAttributedString attrString: inout NSAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        attrString = scaleDecimals(attrString, paragraphStyle)
    }
    
    func setTextAlignmentFrame() {
        guard let renderedTextImage = renderedTextImage, hasAlignment(.center) == false else { return }
        var newX = (bounds.size.width - renderedTextImage.size.width) / 2
        newX = textAlignment == .right ? newX : (newX * -1)
        blurLayer.frame = blurLayer.frame.offsetBy(dx: newX, dy: 0)
    }
    
    private func scaleDecimals(_ attributedString: NSAttributedString, _ paragraphStyle: NSMutableParagraphStyle) -> NSAttributedString {
        let currentAttributes = attributedString.attributes(at: 0, effectiveRange: nil)
        let range = NSRange(location: 0, length: attributedString.string.count)
        let mutableAttributed = NSMutableAttributedString(string: attributedString.string, attributes: currentAttributes)
        
        if attributedString.string.isEmpty {
            let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: textColor]
            mutableAttributed.addAttributes(attributes as [NSAttributedString.Key: Any], range: range)
            return mutableAttributed
        } else if attributedString.string.contains("M") {
            let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: self.font]
            mutableAttributed.addAttributes(attributes as [NSAttributedString.Key: Any], range: range)
            return mutableAttributed
        } else if let position = attributedString.string.distanceFromStart(to: ",") {
            return makeAttributeString(with: attributedString, at: position, paragraphStyle: paragraphStyle) ?? mutableAttributed
        }
        return mutableAttributed
    }
    
    private func makeAttributeString(with text: NSAttributedString, at position: Int, paragraphStyle: NSMutableParagraphStyle) -> NSAttributedString? {
        
        let attFont:UIFont? = text.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        let attColor:UIColor? = text.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        
        let mainFont:UIFont! = attFont ?? self.font
        let mainColor:UIColor! = attColor ?? self.textColor

        let fitSize = min(CGFloat(self.frame.width) / CGFloat(text.string.count) * Constants.charactersRatio, mainFont.pointSize)
        let finalSize = max(mainFont.pointSize*self.minimumScaleFactor, fitSize)
        let finalFont = mainFont.withSize(finalSize)
        let range = NSRange(location: position, length: text.string.count - position)
        guard
            let decimalPart = text.string.substring(with: range),
            let nonDecimalPart = text.string.substring(0, position)
            else {
                return NSAttributedString(string: text.string)
        }
        let fontDecimal = text.attribute(NSAttributedString.Key.font, at: position, effectiveRange: nil) as? UIFont
        let decimalFontSize: CGFloat = fontDecimal?.pointSize ?? finalFont.pointSize * Constants.decimalsRatio
        let builder = TextStylizer.Builder(fullText: text.string)
        _ = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: nonDecimalPart).setStyle(finalFont))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart).setStyle(finalFont.withSize(decimalFontSize)))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text.string).setColor(mainColor))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text.string).setParagraphStyle(paragraphStyle))
        return builder.build()
    }

    // MARK: - Private functions
    
    /// Render both, blured and not blured images
    private func renderImages() {
        var text: NSAttributedString?
        if var attributedTextToRenderVar = attributedTextToRender {
            if self.applyTextAlignmentToAttributedText {
                addTextAlignment(textAlignment, toAttributedString: &attributedTextToRenderVar)
                text = attributedTextToRenderVar
            } else {
                text = attributedTextToRenderVar
            }
        } else if let textToRender = textToRender {
            text = NSAttributedString(string: textToRender, attributes: defaultAttributes())
        }
        let maxWidth = preferredMaxLayoutWidth > 0 ? preferredMaxLayoutWidth : bounds.size.width + renderMargin
        let maxHeight = preferredMaxLayoutWidth > 0 ? UIScreen.main.bounds.size.height : bounds.size.height
        renderedTextImage = text?.imageFromText(CGSize(width: maxWidth, height: maxHeight))
        if self.isBlured {
            self.renderBlurredTextImage()
        }
        self.finishRenderImages()
    }
    
    private func renderBlurredTextImage() {
        if let renderedTextImage = renderedTextImage, let cgImage = CIImage(image: renderedTextImage) {
            blurredTextImage = applyBlurEffect(cgImage, blurLevel: Double(blurRadius))
        }
    }
    
    private func finishRenderImages() {
        self.blurLayer.frame = bounds
        self.setBlurred(self.isBlured)
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
    
    /// apply blur effect
    /// - Parameters:
    ///   - image: the image without blur from the text
    ///   - blurLevel: the radius to apply
    private func applyBlurEffect(_ image: CIImage, blurLevel: Double) -> UIImage {
        var resultImage: CIImage = image
        if blurLevel > 0 {
            blurFilter.setValue(blurLevel, forKey: kCIInputRadiusKey)
            blurFilter.setValue(image, forKey: kCIInputImageKey)
            resultImage = blurFilter.outputImage ?? image
        }
        
        let offset: CGFloat = CGFloat(blurLevel * 2)
        guard let cgImage = context.createCGImage(resultImage,
                                            from: CGRect(x: -offset,
                                                         y: -offset,
                                                         width: image.extent.size.width + (offset*2),
                                                         height: image.extent.size.height + (offset*2))) else {
                                                            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
    
    /// assign the resulting image blured or not to the layer, also correct the frame according to the text alignment
    /// - Parameter blurred: if true draw the blured one, not blured otherwise
    private func setBlurred(_ blurred: Bool) {
        setTextAlignmentFrame()
        if blurred {
            blurLayer.contents = blurredTextImage?.cgImage
        } else {
            blurLayer.contents = renderedTextImage?.cgImage
        }
    }
    
    private func setupBlurLayer() -> CALayer {
        let layer = CALayer()
        layer.contentsGravity = .center
        layer.bounds = bounds
        layer.position = center
        layer.contentsScale = UIScreen.main.scale
        return layer
    }
    
    private func hasAlignment(_ alignment: NSTextAlignment) -> Bool {
        var hasAlignment = false
        if let text = attributedTextToRender {
            let textRange = NSRange(location: 0, length: text.length)
            text.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: textRange, options: [], using: { value, _, stop in
                let paragraphStyle = value as? NSParagraphStyle
                hasAlignment = paragraphStyle?.alignment == alignment
                stop.pointee = true
            })
        } else if textToRender != nil {
            hasAlignment = textAlignment == alignment
        }
        return hasAlignment
    }
    
    /// default attributes to use when no attributed text are setted. This class always render attributed text to take into account text alignment
    private func defaultAttributes() -> [NSAttributedString.Key: AnyObject]? {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = lineBreakMode
        paragraph.alignment = textAlignment
        
        return [NSAttributedString.Key.paragraphStyle: paragraph,
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.ligature: NSNumber(value: 0 as Int),
                NSAttributedString.Key.kern: NSNumber(value: 0.0 as Float)]
    }
    
    func setAccessibility() {
        self.isAccessibilityElement = !self.isBlured
    }
}

private extension NSAttributedString {
    func sizeToFit(_ maxSize: CGSize) -> CGSize {
        return boundingRect(with: maxSize, options: (NSStringDrawingOptions.usesLineFragmentOrigin), context: nil).size
    }
    
    func imageFromText(_ maxSize: CGSize) -> UIImage {
        let padding: CGFloat = 1
        let size = sizeToFit(maxSize)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width + padding*2, height: size.height + padding*2), false, 0.0)
        self.draw(in: CGRect(x: padding, y: padding, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
