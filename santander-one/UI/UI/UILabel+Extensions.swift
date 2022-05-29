//
//  UILabel+Extensions.swift
//  UI
//
//  Created by Tania Castellano Brasero on 22/10/2019.
//

import CoreFoundationLib
import UIKit

extension UILabel: StylableLocalizedView {
    @available(*, deprecated, message: "Use configureText(withKey: String, andConfiguration: LocalizedStylableTextConfiguration) instead.")
    public func set(localizedStylableText: LocalizedStylableText) {
        if localizedStylableText.styles != nil {
            guard let fontField = font ?? UIFont(name: font.fontName, size: UIFont.systemFontSize) else { return }
            let lineBreak = lineBreakMode
            let text = processAttributedTextFrom(localizedStylableText: localizedStylableText,
                                                 withFont: fontField,
                                                 andAlignment: textAlignment)
            font = UIFont(name: fontField.fontName, size: fontField.pointSize)
            attributedText = text
            lineBreakMode = lineBreak
        } else {
            text = localizedStylableText.text
        }
    }
    
    public func configureText(withLocalizedString localizedString: LocalizedStylableText,
                              andConfiguration configuration: LocalizedStylableTextConfiguration? = nil) {
        if localizedString.styles != nil || configuration != nil {
            attributedText = localizedString.asAttributedString(for: self, configuration)
        } else {
            text = localizedString.text
        }
    }
    
    public func configureText(withKey key: String,
                              andConfiguration configuration: LocalizedStylableTextConfiguration? = nil) {
        let localizedString: LocalizedStylableText = localized(key)
        self.configureText(withLocalizedString: localizedString, andConfiguration: configuration)
    }
    
    @available(*, deprecated, message: "Use configureText(withKey: String, andConfiguration: LocalizedStylableTextConfiguration) instead.")
    public func set(lineHeightMultiple: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributed = attributedText ?? NSAttributedString(string: text ?? "")
        let mutable = NSMutableAttributedString(attributedString: attributed)
        mutable.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.string.count))
        let alignment = textAlignment
        let lineBreak = lineBreakMode
        attributedText = mutable
        
        textAlignment = alignment
        lineBreakMode = lineBreak
    }
}

extension UILabel {
    public func removeBlur() { subviews.forEach { if  $0.accessibilityIdentifier == "blurredCourtine" { $0.removeFromSuperview() } } }
    public func blur(_ blurRadius: CGFloat, _ topMargin: CGFloat = 0.0) {
        guard !(text ?? "").isEmpty else { return }
        let blurred = subviews.filter { $0.accessibilityIdentifier == "blurredCourtine" }
        guard blurred.first?.frame.size != frame.size else { return }
        blurred.forEach { $0.removeFromSuperview() }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.frame.width, height: self.frame.height), false, 1)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        self.layer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return }
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        guard let result = blur.outputImage else { return }
        
        let boundingRect = rectToInt(CGRect(x: -10,
                                            y: 0.0 - topMargin,
                                            width: frame.width + 20,
                                            height: frame.height + (2 * topMargin)))
        
        guard let cgImage = ciContext.createCGImage(result, from: boundingRect) else { return }
        let filteredImage = UIImage(cgImage: cgImage)
        let blurOverlay = UIImageView()
        blurOverlay.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        blurOverlay.accessibilityIdentifier = "blurredCourtine"
        blurOverlay.image = filteredImage
        blurOverlay.contentMode = UIView.ContentMode.center
        blurOverlay.backgroundColor = UIColor.white
        blurOverlay.clipsToBounds = false
        
        addSubview(blurOverlay)
    }
    
    private func rectToInt(_ rect: CGRect) -> CGRect {
        return CGRect(x: roundDouble(rect.origin.x), y: roundDouble(rect.origin.y), width: roundDouble(rect.size.width), height: roundDouble(rect.size.height))
    }
    
    private func roundDouble(_ value: CGFloat) -> Double { return Double(round(100 * value) / 100) }
}

public extension UILabel {
    
    func setSantanderTextFont(type: FontType = .regular, size: CGFloat = 12, color: UIColor) {
        self.textColor = color
        self.font = UIFont.santander(family: .text, type: type, size: size)
    }
    
    func setHeadlineTextFont(type: FontType = .regular, size: CGFloat = 12, color: UIColor) {
        self.textColor = color
        self.font = UIFont.santander(family: .headline, type: type, size: size)
    }
    
    func setHalterRegularTextFont(size: CGFloat) {
        self.font = UIFont.halterRegular(size: size)
    }
}

@propertyWrapper public struct SantanderTextLabel<Label: UILabel> {
    
    public private(set) var label: Label?
    
    public var wrappedValue: Label? {
        get {
            label
        }
        set {
            let label = Label()
            label.font = UIFont.santander(family: .text, type: .bold, size: 20)
            self.label = label
        }
    }
    
    public init(value: Label) {
        self.label = value
    }
}

public extension UILabel {
    func refreshFont(force: Bool, margin: CGFloat = 20.0, spaceBetweenCharacters: Int? = nil) {
        guard self.frame.height > 0.0 else { if force { super.setNeedsLayout() }; return }
        let maxFont = font.pointSize
        let minFont = (maxFont * self.minimumScaleFactor).rounded()
        let availableWidth: CGFloat = self.bounds.size.width - margin + CGFloat(spaceBetweenCharacters ?? 0)
        for size in stride(from: maxFont, to: minFont, by: -0.5) {
            let proposedFont = self.font.withSize(CGFloat(size))
            let labelHeight = heightWith(getAttributedText(spaceBetweenCharacters: spaceBetweenCharacters),
                                         proposedFont,
                                         availableWidth)
            if labelHeight <= self.bounds.size.height {
                self.font = proposedFont
                setNeedsLayout()
                break
            }
        }
    }
    
    private func getAttributedText(spaceBetweenCharacters: Int? = nil) -> NSAttributedString {
        guard let spaceBetweenCharacters = spaceBetweenCharacters else {
            return self.attributedText ?? NSAttributedString(string: self.text ?? "")
        }
        
        let mutableAttributedText = {
            return self.attributedText != nil ?
                NSMutableAttributedString(attributedString: attributedText!):
                NSMutableAttributedString(string: self.text ?? "")
        }()
        mutableAttributedText.addAttribute(NSAttributedString.Key.kern,
                                           value: spaceBetweenCharacters,
                                           range: NSRange(location: 0, length: mutableAttributedText.string.count))
        return mutableAttributedText
    }
    
    func heightWith(_ text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: width,
                                          height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func heightWith(_ text: NSAttributedString, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: width,
                                          height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.attributedText = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func fontSizeWith(_ text: String) -> CGFloat {
        let maxFont = font.pointSize
        let minFont = (maxFont * self.minimumScaleFactor).rounded()
        for size in stride(from: maxFont, to: minFont, by: -0.5) {
            let proposedFont = self.font.withSize(CGFloat(size))
            
            let labelHeight = heightWith(text,
                                         proposedFont,
                                         self.bounds.size.width)
            
            if labelHeight <= self.bounds.size.height {
                return proposedFont.pointSize
            }
        }
        return maxFont
    }
    
    func scaleDecimals() {
        if let text = self.text {
            if text.isEmpty || text.contains("M") {
                self.attributedText = NSAttributedString(string: text)
            } else if let position = text.distanceFromStart(to: ",") {
                let decimalPart = text.substring(with: NSRange(location: position, length: text.count - position))!
                let builder = TextStylizer.Builder(fullText: text)
                self.attributedText = builder.addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart).setStyle(self.font.withSize(self.font.pointSize * 0.75)))
                    .build()
            }
        }
    }
}

public extension UILabel {
    @discardableResult
    func appendSpeechFromElements<T>(_ elements: [T]) -> String where T: UILabel {
        accessibilityLabel = ([self] + elements)
            .compactMap { $0.text }
            .joined(separator: ".")
        return accessibilityLabel ?? ""
    }
}

public extension UILabel {
    var scaledFont: UIFont {
        set {
            self.adjustsFontForContentSizeCategory = true
            self.font = .scaledFont(with: newValue)
        }
        get {
            self.font
        }
    }
}
