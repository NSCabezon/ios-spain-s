//
//  BubbleMultipleLabelView.swift
//
//  Created by Carlos Monfort Gómez on 27/11/2019.
//

import UIKit
import CoreFoundationLib

final public class BubbleMultipleLabelView: UIView {
    
    private let lineLayer: CAShapeLayer = CAShapeLayer()
    private let textLayer: CATextLayer = CATextLayer()
    private let subTextLayer: CATextLayer = CATextLayer()
    private let separatorLayer: CAShapeLayer = CAShapeLayer()
    private var associatedViewFrame: CGRect = CGRect.zero
    
    var bubbleText: String = ""
    var bubbleSubText: String = ""
    var bubbleFont: UIFont = UIFont.santander(family: .text, type: .light, size: 13.0)
    var bubbleSubTextFont: UIFont = UIFont.santander(family: .text, type: .light, size: 11.0)
    var fixedWidth: CGFloat = 268.0
    var peakHeight: CGFloat = 6.0
    var leftMargin: CGFloat = 40.0
    var localizedStyleText: LocalizedStylableText!
    public let bubbleId: BubbleMultipleLabelViewType

    private weak var superwindow: UIWindow?
    
    public init(associated: UIView, localizedStyleText: LocalizedStylableText, subText: String, bubbleId: BubbleMultipleLabelViewType, window: UIWindow) {
        self.localizedStyleText = localizedStyleText
        bubbleText = localizedStyleText.text
        bubbleSubText = subText
        self.bubbleId = bubbleId
        super.init(frame: associatedViewFrame)
        associatedViewFrame = transformAssociatedFrame(associated)
        self.setAccessibility()
        commonInit(window: window)
    }
    
    public func dismiss() { dismissAnimated() }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - private methods
    
    private func addCloseCourtain(window: UIWindow) {
        let curtain = UIView(frame: UIScreen.main.bounds)
        curtain.backgroundColor = UIColor.clear
        curtain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeBubble(_:))))
        curtain.isUserInteractionEnabled = true
        curtain.isAccessibilityElement = true
        curtain.accessibilityLabel = localized("siri_voiceover_close")
        window.addSubview(curtain)
    }
    
    @objc private func closeBubble(_ sender: UITapGestureRecognizer) {
        window?.subviews.forEach { ($0 as? BubbleMultipleLabelView)?.dismiss() }
        sender.view?.removeFromSuperview()
    }
    
    private func transformAssociatedFrame(_ view: UIView) -> CGRect {
        return  view.convert(view.bounds, to: nil)
    }
    
    private func commonInit(window: UIWindow) {
        let newFrame = calculateFrameForBubble()
        frame = newFrame
        layer.cornerRadius = 10.0
        layer.backgroundColor = UIColor.clear.cgColor
        addLineLayer(newFrame)
        drawBubble(CGRect(x: (associatedViewFrame.origin.x + (associatedViewFrame.size.width / 2.0) - (peakHeight)) - newFrame.origin.x,
                          y: newFrame.origin.y,
                          width: peakHeight * 2.0,
                          height: peakHeight))
        let textHeight = heightWith(bubbleText, bubbleFont.withSize(bubbleFont.pointSize + 1.0), 220)
        addTextLayer(textHeight, newFrame)
        addSeparatorLayer(textHeight, newFrame)
        addSubTextLayer(textHeight, newFrame)
        addShadow()
        presentAnimated(toFrame: newFrame)
        self.addCloseCourtain(window: window)
    }
    
    private func addLineLayer(_ newFrame: CGRect) {
        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.white.cgColor
        lineLayer.strokeColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.frame = CGRect(origin: CGPoint.zero, size: newFrame.size)
        lineLayer.fillRule = CAShapeLayerFillRule.evenOdd
    }
    
    private func addTextLayer(_ textHeight: CGFloat, _ newFrame: CGRect) {
        layer.addSublayer(textLayer)
        textLayer.frame = CGRect(origin: CGPoint(x: 16, y: 12),
                                 size: CGSize(width: newFrame.size.width - 32,
                                              height: textHeight))
        drawText(in: textLayer, text: bubbleText, font: bubbleFont, localizedText: localizedStyleText)
    }
    
    private func addSeparatorLayer(_ textHeight: CGFloat, _ newFrame: CGRect) {
        layer.addSublayer(separatorLayer)
        separatorLayer.fillColor = UIColor.mediumSkyGray.cgColor
        separatorLayer.path = UIBezierPath(roundedRect: CGRect(x: 16, y: textHeight + 4, width: newFrame.size.width - 32, height: 1), cornerRadius: 0).cgPath
    }
    
    private func addSubTextLayer(_ textHeight: CGFloat, _ newFrame: CGRect) {
        layer.addSublayer(subTextLayer)
        let subTextHeight = heightWith(bubbleSubText,
                                       bubbleSubTextFont.withSize(bubbleSubTextFont.pointSize + 1.0),
                                       220)
        subTextLayer.frame = CGRect(origin: CGPoint(x: 16, y: textHeight + 16),
                                    size: CGSize(width: newFrame.size.width - 32,
                                                 height: subTextHeight))
        drawText(in: subTextLayer, text: bubbleSubText, font: bubbleSubTextFont)
    }
    
    private func presentAnimated(toFrame frame: CGRect) {
        alpha = 0.0
        textLayer.opacity = 0.0
        separatorLayer.opacity = 0.0
        subTextLayer.opacity = 0.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.frame = frame
            self?.textLayer.opacity = 1.0
            self?.separatorLayer.opacity = 1.0
            self?.subTextLayer.opacity = 1.0
            self?.alpha = 1.0
        })
    }
    private func setAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = AccessibilityGlobalPosition.bubbleYourBalanceToolTip
        self.accessibilityLabel = self.bubbleText + "\n" + self.bubbleSubText
        UIAccessibility.post(notification: .screenChanged, argument: self)
    }
    
    @objc private func dismissAnimated() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.textLayer.opacity = 0.0
            self?.separatorLayer.opacity = 0.0
            self?.subTextLayer.opacity = 0.0
            self?.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
    
    private func calculateFrameForBubble() -> CGRect {
        let textHeight = heightWith(bubbleText,
                                        bubbleFont.withSize(bubbleFont.pointSize + 1.0),
                                        220) + 14 + peakHeight
        let subTextHeight = heightWith(bubbleSubText,
                                          bubbleSubTextFont.withSize(bubbleSubTextFont.pointSize + 1.0),
                                          220)
        let totalHeight = textHeight + subTextHeight
        let associatedEndX = associatedViewFrame.origin.x + associatedViewFrame.width
        let originX = associatedEndX - fixedWidth
        let correction: CGFloat = originX < leftMargin ? leftMargin - originX : 0.0
        
        return CGRect(x: originX + correction,
                      y: associatedViewFrame.origin.y + associatedViewFrame.height + peakHeight,
                      width: fixedWidth,
                      height: totalHeight)
    }
    
    private func heightWith(_ text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
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
    
    private func drawBubble(_ peakPos: CGRect) {
        let linePath = CGMutablePath()
        
        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.origin.y))
        
        linePath.addLine(to: CGPoint(x: peakPos.origin.x, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: peakPos.origin.x + (peakPos.width / 2.0), y: lineLayer.bounds.origin.y - peakPos.height))
        linePath.addLine(to: CGPoint(x: peakPos.origin.x + peakPos.size.width, y: lineLayer.bounds.origin.y))
        
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width - layer.cornerRadius, y: lineLayer.bounds.origin.y))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y + layer.cornerRadius),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - layer.cornerRadius - peakHeight))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width - layer.cornerRadius, y: lineLayer.bounds.size.height - peakHeight),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - peakHeight))
        
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.size.height - peakHeight))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - layer.cornerRadius - peakHeight),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - peakHeight))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y + layer.cornerRadius))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.origin.y),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))
        
        lineLayer.path = linePath
    }
    
    private func drawText(in layer: CATextLayer, text: String, font: UIFont, localizedText: LocalizedStylableText? = nil) {
        let supLayer = CATextLayer()
        
        supLayer.font = font
        supLayer.fontSize = font.pointSize
        supLayer.string = text
        supLayer.alignmentMode = CATextLayerAlignmentMode.left
        supLayer.foregroundColor = UIColor.lisboaGray.cgColor
        supLayer.contentsScale = UIScreen.main.scale
        supLayer.frame.size = layer.frame.size
        supLayer.isWrapped = true
        if let styledText = localizedText {
            supLayer.set(localizedStylableText: styledText, font: font, fontSize: 13)
        }
        
        layer.addSublayer(supLayer)
    }
    
    private func addShadow() {        
        lineLayer.masksToBounds = false
        lineLayer.shadowColor = UIColor.grafite.cgColor
        lineLayer.shadowOpacity = 0.3
        lineLayer.shadowOffset = CGSize(width: 0, height: 3)
        lineLayer.shadowRadius = 2

        let shadowLayer = CAShapeLayer()
        shadowLayer.masksToBounds = false
        shadowLayer.path = lineLayer.path
        shadowLayer.shadowColor = UIColor.grafite.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.10

        layer.insertSublayer(shadowLayer, at: 0)
    }
}

public enum BubbleMultipleLabelViewType: String {
    case yourMoneyBubble
    
    func getBubbleId() -> Int {
        return self.hashValue
    }
}
