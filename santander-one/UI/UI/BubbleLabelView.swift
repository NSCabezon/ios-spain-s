//
//  BubbleLabelVIew.swift
//  toTest
//
//  Created by alvola on 25/09/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib

public struct BubbleLabelConfiguration {
    public var fixedWidth: CGFloat
    public var frameSeparation: CGFloat
    public var peakHeight: CGFloat
    public var leftMargin: CGFloat
    
    var textWidth: CGFloat {
        return fixedWidth - 44.0
    }
    
    public init(fixedWidth: CGFloat, frameSeparation: CGFloat, peakHeight: CGFloat, leftMargin: CGFloat) {
        self.fixedWidth = fixedWidth
        self.frameSeparation = frameSeparation
        self.peakHeight = peakHeight
        self.leftMargin = leftMargin
    }
    
    public static func defaultConfiguration() -> BubbleLabelConfiguration {
        return BubbleLabelConfiguration(fixedWidth: 248.0,
                                        frameSeparation: 12.0,
                                        peakHeight: 6.0,
                                        leftMargin: 16.0)
    }
}

class CATextAccessibilityLayer: CATextLayer, UIAccessibilityIdentification {
    var accessibilityIdentifier: String?
}

final public class BubbleLabelView: UIView {
    public enum BubblePosition {
        case top
        case bottom
        case none
        case automatic
        case right
    }

    private let lineLayer: CAShapeLayer = CAShapeLayer()
    private let textLayer: CATextAccessibilityLayer = CATextAccessibilityLayer()
    private var associatedViewFrame: CGRect = CGRect.zero

    var bubbleText: String = ""
    var bubbleFont: UIFont = UIFont.santander(family: .text, type: .light, size: 13.0)
    var configuration: BubbleLabelConfiguration = BubbleLabelConfiguration.defaultConfiguration()
    var bubblePosition: BubblePosition = .none
    var accessibilityID: String?
    var labelAccessibilityID: String?
    var localizedStyleText: LocalizedStylableText?
    
    private let fixedWidthIsOn: Bool

  public static func startWith(associated: UIView, text: String, position: BubblePosition, accessibilityID: String? = nil, labelAccessibilityID: String? = nil, configuration: BubbleLabelConfiguration? = nil) {
        guard !(associated.window?.subviews.contains { $0 is BubbleLabelView } ?? false) else { return }
        guard let drawer = associated.window?.rootViewController as? BaseMenuController, let view = drawer.currentRootViewController?.view else { return }
        let bubble = BubbleLabelView(associated: associated,
                                     text: text,
                                     position: position,
                                     accessibilityID: accessibilityID,
                                     labelAccessibilityID: labelAccessibilityID,
                                     configuration: configuration)
        view.addSubview(bubble)
        bubble.addCloseCourtain(view: view)
    }

    public static func startWith(associated: UIView, localizedStyleText: LocalizedStylableText, position: BubblePosition, accessibilityID: String? = nil, labelAccessibilityID: String? = nil) {
        guard localizedStyleText.styles != nil else {
            startWith(associated: associated, text: localizedStyleText.text, position: position, accessibilityID: accessibilityID)
            return
        }
        guard !(associated.window?.subviews.contains { $0 is BubbleLabelView } ?? false) else { return }
        guard let drawer = associated.window?.rootViewController as? BaseMenuController, let view = drawer.currentRootViewController?.view else { return }
        let bubble = BubbleLabelView(associated: associated,
                                     text: localizedStyleText.text,
                                     position: position,
                                     accessibilityID: accessibilityID,
                                     labelAccessibilityID: labelAccessibilityID,
                                     localizedStyleText: localizedStyleText)
        view.addSubview(bubble)
        bubble.addCloseCourtain(view: view)
    }
    
    public static func startInSuperviewWith(associated: UIView, localizedStyleText: LocalizedStylableText, position: BubblePosition) {
        guard let view = associated.findViewController()?.view else { return }
        let bubble = BubbleLabelView(associated: associated,
                                     text: localizedStyleText.text,
                                     position: position,
                                     localizedStyleText: localizedStyleText)
        view.addSubview(bubble)
        bubble.addCloseCourtain(superview: view)
    }
    
    public static func startInSuperviewWith(associated: UIView, text: String, position: BubblePosition, accessibilityID: String? = nil, labelAccessibilityID: String? = nil, dismissDuration: Double, superview: UIView) {
        let bubble = BubbleLabelView(associated: associated,
                                     text: text,
                                     position: position,
                                     accessibilityID: accessibilityID,
                                     labelAccessibilityID: labelAccessibilityID,
                                     fixedWidthIsOn: false)
        bubble.isAccessibilityElement = false
        if position == .right {
            let associatedViewFrame = associated.convert(associated.bounds, to: superview)
            bubble.frame.origin.y = associatedViewFrame.origin.y - (bubble.frame.height / 2)
            if associatedViewFrame.origin.x - bubble.configuration.fixedWidth - bubble.configuration.frameSeparation > 0 {
                let originX = associatedViewFrame.origin.x - bubble.configuration.fixedWidth
                let spaceOriginX = originX - bubble.configuration.frameSeparation
                bubble.frame.origin.x = spaceOriginX
            } else {
                bubble.center.x = superview.center.x
            }
        }
        superview.addSubview(bubble)
        bubble.dismissAfterDuration(dismissDuration)
    }

    public init(associated: UIView,
                text: String,
                position: BubblePosition,
                accessibilityID: String? = nil,
                labelAccessibilityID: String? = nil,
                localizedStyleText: LocalizedStylableText? = nil,
                fixedWidthIsOn: Bool = true,
                configuration: BubbleLabelConfiguration? = nil,
                xPeak: CGFloat? = nil,
                yPeak: CGFloat? = nil) {
        self.localizedStyleText = localizedStyleText
        self.fixedWidthIsOn = fixedWidthIsOn
        self.configuration = configuration ?? BubbleLabelConfiguration.defaultConfiguration()
        bubbleText = text
        if position == .right { self.configuration.peakHeight = 0.0 }
        super.init(frame: associatedViewFrame)
        bubblePosition = calculatePosition(position, associated)
        self.accessibilityID = accessibilityID
        self.labelAccessibilityID = labelAccessibilityID
        associatedViewFrame = transformAssociatedFrame(associated)
        guard let xPeak = xPeak,
              let yPeak = yPeak
        else {
            commonInit()
            return
        }
        initWithPeakPosition(x: xPeak, y: yPeak)
    }

    public func dismiss() { dismissAnimated() }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - private methods

    private func calculatePosition(_ position: BubblePosition, _ associatedView: UIView) -> BubblePosition {
        guard position == .automatic else { return position }
        let estimateHeight = totalHeight() + transformAssociatedFrame(associatedView).origin.y
        
        return estimateHeight > UIScreen.main.bounds.height - 20.0 ? .top : .bottom
    }

    private func addCloseCourtain(view: UIView) {
        let curtain = CloseCourtainView(frame: UIScreen.main.bounds)
        curtain.backgroundColor = UIColor.clear
        curtain.isUserInteractionEnabled = true
        view.addSubview(curtain)
    }
    
    private func addCloseCourtain(superview: UIView) {
        let curtain = CloseCourtainView(frame: UIScreen.main.bounds)
        curtain.isFromSuperview = true
        curtain.backgroundColor = UIColor.clear
        curtain.isUserInteractionEnabled = true
        superview.addSubview(curtain)
    }

    @objc private func closeBubble(_ sender: UITapGestureRecognizer) {
        let drawer = sender.view?.window?.rootViewController as? BaseMenuController
        let view = drawer?.currentRootViewController?.view
        view?.subviews.forEach { ($0 as? BubbleLabelView)?.dismiss() }
        sender.view?.removeFromSuperview()
    }

    private func transformAssociatedFrame(_ view: UIView) -> CGRect {
        return  view.convert(view.bounds, to: nil)
    }

    private func commonInit() {
        let newFrame = calculateFrameForBubble()

        frame = newFrame

        layer.cornerRadius = 10.0
        layer.backgroundColor = UIColor.clear.cgColor

        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.white.cgColor
        lineLayer.strokeColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.frame = CGRect(origin: CGPoint.zero, size: newFrame.size)
        lineLayer.fillRule = CAShapeLayerFillRule.evenOdd

        drawBubble(CGRect(x: (associatedViewFrame.origin.x + (associatedViewFrame.size.width / 2.0) - (configuration.peakHeight)) - newFrame.origin.x,
                          y: bubblePosition == .top ? newFrame.origin.y + newFrame.height - configuration.peakHeight : bubblePosition == .bottom ? newFrame.origin.y : 0.0,
                          width: configuration.peakHeight * 2.0,
                          height: configuration.peakHeight))
        addShadow()
        layer.addSublayer(textLayer)
        textLayer.frame = CGRect(origin: CGPoint(x: 16.0, y: 7.0),
                                 size: CGSize(width: newFrame.size.width - 32,
                                              height: newFrame.size.height - 14 - configuration.peakHeight))
        drawText()
        presentAnimated(toFrame: newFrame)
        self.setAccessibility()
    }
    
    private func initWithPeakPosition(x: CGFloat, y: CGFloat) {
        let newFrame = calculateFrameForBubble()

        frame = newFrame

        layer.cornerRadius = 10.0
        layer.backgroundColor = UIColor.clear.cgColor

        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.white.cgColor
        lineLayer.strokeColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.frame = CGRect(origin: CGPoint.zero, size: newFrame.size)
        lineLayer.fillRule = CAShapeLayerFillRule.evenOdd

        drawBubble(CGRect(x: x - newFrame.origin.x - newFrame.width/4 + configuration.peakHeight + 3,
                          y: y,
                          width: configuration.peakHeight * 2.0,
                          height: configuration.peakHeight))
        addShadow()
        layer.addSublayer(textLayer)
        textLayer.frame = CGRect(origin: CGPoint(x: 16.0, y: 7.0),
                                 size: CGSize(width: newFrame.size.width - 32,
                                              height: newFrame.size.height - 14 - configuration.peakHeight))
        drawText()
        presentAnimated(toFrame: newFrame)
    }

    private func presentAnimated(toFrame frame: CGRect) {
        alpha = 0.0
        textLayer.opacity = 0.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.frame = frame
            self?.textLayer.opacity = 1.0
            self?.alpha = 1.0
        })
    }

    @objc private func dismissAnimated() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.textLayer.opacity = 0.0
            self?.alpha = 0.0
            }, completion: { _ in
                self.superview?.subviews.forEach { ($0 as? CloseCourtainView)?.removeFromSuperview() }
                self.removeFromSuperview()
        })
    }

    private func calculateFrameForBubble() -> CGRect {
        let totalH = totalHeight()
        let associatedEndX = associatedViewFrame.origin.x + associatedViewFrame.width
        let originX = associatedEndX - configuration.fixedWidth
        let correction: CGFloat = originX < configuration.leftMargin ? configuration.leftMargin - originX : 0.0
        return CGRect(x: originX + correction,
                      y: bubblePosition == .top ? associatedViewFrame.origin.y - totalH - configuration.frameSeparation : bubblePosition == .right ? associatedViewFrame.origin.y - associatedViewFrame.height : associatedViewFrame.origin.y + associatedViewFrame.height + configuration.peakHeight + configuration.frameSeparation,
                      width: configuration.fixedWidth,
                      height: totalH)
    }
    
    private func totalHeight() -> CGFloat {
        return heightWith(bubbleText,
                          bubbleFont.withSize(bubbleFont.pointSize + 0.5),
                          configuration.textWidth) + 14 + configuration.peakHeight
    }

    private func heightWith(_ text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: width,
                                          height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        if let styledStyle = self.localizedStyleText {
            label.font = font.withSize(12)
            label.configureText(withLocalizedString: styledStyle)
        } else {
            label.font = font.withSize(font.pointSize - 0.3)
            label.text = self.bubbleText
        }
        label.sizeToFit()
        if !fixedWidthIsOn {
            configuration.fixedWidth = label.frame.width + (configuration.frameSeparation * 6)
        }

        return label.frame.height
    }

    private func drawBubble(_ peakPos: CGRect) {
        let linePath = CGMutablePath()

        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.origin.y))
        if bubblePosition == .bottom {
            linePath.addLine(to: CGPoint(x: peakPos.origin.x, y: lineLayer.bounds.origin.y))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + (peakPos.width / 2.0), y: lineLayer.bounds.origin.y - peakPos.height))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + peakPos.size.width, y: lineLayer.bounds.origin.y))
        }
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width - layer.cornerRadius, y: lineLayer.bounds.origin.y))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y + layer.cornerRadius),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.origin.y))
        
        if bubblePosition == .right {
            let middleY = (lineLayer.bounds.size.height / 2) - (layer.cornerRadius / 4)
            linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: middleY - (peakPos.size.width / 2)))
            linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width + peakPos.size.height, y: middleY))
            linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: middleY + (peakPos.size.width / 2)))
        }
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - layer.cornerRadius - configuration.peakHeight))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width - layer.cornerRadius, y: lineLayer.bounds.size.height - configuration.peakHeight),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - configuration.peakHeight))
        if bubblePosition == .top {
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + peakPos.size.width, y: lineLayer.bounds.size.height - configuration.peakHeight))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + (peakPos.size.width / 2.0), y: lineLayer.bounds.size.height))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x, y: lineLayer.bounds.size.height - configuration.peakHeight))
        }
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.size.height - configuration.peakHeight))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - layer.cornerRadius - configuration.peakHeight),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - configuration.peakHeight))
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y + layer.cornerRadius))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.origin.y),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.origin.y))

        lineLayer.path = linePath
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
    
    private func drawText() {
        let supLayer = CATextLayer()

        supLayer.font = bubbleFont
        supLayer.fontSize = bubbleFont.pointSize
        supLayer.string = bubbleText
        supLayer.alignmentMode = CATextLayerAlignmentMode.left
        supLayer.foregroundColor = UIColor.lisboaGray.cgColor
        supLayer.contentsScale = UIScreen.main.scale
        supLayer.frame.size = textLayer.frame.size
        supLayer.isWrapped = true
        if let styledText = self.localizedStyleText {
            supLayer.set(localizedStylableText: styledText, font: UIFont.santander(family: .text, size: 12), fontSize: 12)
        }
        textLayer.addSublayer(supLayer)
    }
}

extension CATextLayer: StylableLocalizedView {
    func set(localizedStylableText: LocalizedStylableText) {
        set(localizedStylableText: localizedStylableText, font: .santander(family: .text, size: 12), fontSize: 12)
    }

    func set(localizedStylableText: LocalizedStylableText, font: UIFont, fontSize: CGFloat) {
        let fontField = font
        let textRange = NSRange(location: 0, length: localizedStylableText.text.count)
        let text = processAttributedTextFrom(localizedStylableText: localizedStylableText, withFont: fontField, andAlignment: .left) as? NSMutableAttributedString
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.75
        text?.enumerateAttribute(.font, in: textRange, options: .longestEffectiveRangeNotRequired, using: { (attr, range, _) in
            if let font = attr as? UIFont {
                text?.addAttribute(.font, value: font.withSize(fontSize), range: range)
                text?.addAttribute(.foregroundColor, value: UIColor.lisboaGray, range: textRange)
                text?.addAttribute(.paragraphStyle, value: paragraphStyle, range: textRange)
            } else {
                text?.addAttribute(.font, value: fontField, range: range)
                text?.addAttribute(.foregroundColor, value: UIColor.lisboaGray, range: textRange)
                text?.addAttribute(.paragraphStyle, value: paragraphStyle, range: textRange)
            }
        })
        self.string = text
    }
}

final class CloseCourtainView: UIView {
    var isFromSuperview: Bool = false
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isFromSuperview ? removeCloseCourtainFromSuperview() : remove()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isFromSuperview ? removeCloseCourtainFromSuperview() : remove()
    }
    
    func remove() {
        let drawer = window?.rootViewController as? BaseMenuController
        let view = drawer?.currentRootViewController?.view
        view?.subviews.forEach { ($0 as? BubbleLabelView)?.dismiss() }
    }
    
    func removeCloseCourtainFromSuperview() {
        self.superview?.subviews.forEach { ($0 as? BubbleLabelView)?.dismiss() }
        self.superview?.subviews.forEach { ($0 as? CloseCourtainView)?.removeFromSuperview() }
    }
}

private extension BubbleLabelView {
    func dismissAfterDuration(_ duration: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.dismiss()
        }
    }

    func setAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = accessibilityID != nil ? accessibilityID : AccessibilityToolTip.bubbleToolTip
        self.accessibilityLabel = self.bubbleText
        self.accessibilityTraits = .none
        self.textLayer.accessibilityIdentifier = labelAccessibilityID != nil ? labelAccessibilityID : AccessibilityToolTip.bubbleToolTipLabel
        UIAccessibility.post(notification: .screenChanged, argument: self)
    }
}
