//
//  DialogMultiLabelView.swift
//  UI
//
//  Created by Ignacio González Miró on 18/05/2020.
//

import Foundation
import UIKit
import CoreFoundationLib

final public class ExpensePredictiveView: UIView {
    public enum BubblePosition {
        case top
        case bottom
        case none
        case automatic
    }

    private let lineLayer: CAShapeLayer = CAShapeLayer()
    private let textLayer: CATextLayer = CATextLayer()
    private let subTextLayer: CATextLayer = CATextLayer()
    
    private var associatedViewFrame: CGRect = CGRect.zero

    var bubbleText: String = ""
    var bubbleSubText: String = ""
    var leftTextFont: UIFont = UIFont.santander(family: .text, type: .light, size: 12.0)
    var rightTextFont: UIFont = UIFont.santander(family: .text, type: .bold, size: 16.2)

    var fixedWidth: CGFloat = UIScreen.main.bounds.size.width - (22.0 * 2)
    var frameSeparation: CGFloat = 5.0
    var peakHeight: CGFloat = 6.0
    var bubblePosition: BubblePosition = .none
    var localizedStyleText: LocalizedStylableText?
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public init(associated: UIView, leftText: String, rightText: String, position: BubblePosition) {
        bubbleText = leftText
        bubbleSubText = rightText
        super.init(frame: associatedViewFrame)
        bubblePosition = calculatePosition(position, associated)
        associatedViewFrame = transformAssociatedFrame(associated)
        commonInit()
    }
    
    public static func startWith(associated: UIView, leftText: String, rightText: String) {
        guard let drawer = associated.window?.rootViewController as? BaseMenuController, let view = drawer.currentRootViewController?.view else { return }
        let bubble = ExpensePredictiveView(associated: associated,
                                           leftText: leftText,
                                           rightText: rightText,
                                           position: .automatic)
        view.addSubview(bubble)
        bubble.addCloseCourtain(view: view)
    }

    public func dismiss() { dismissAnimated() }

    // MARK: - private methods

    private func calculatePosition(_ position: BubblePosition, _ associatedView: UIView) -> BubblePosition {
        guard position == .automatic else { return position }
        let estimateHeight = totalHeight() + transformAssociatedFrame(associatedView).origin.y
        
        return estimateHeight > UIScreen.main.bounds.height - 20.0 ? .top : .bottom
    }

    private func addCloseCourtain(view: UIView) {
        let curtain = CloseDialogMultiLabelView(frame: UIScreen.main.bounds)
        curtain.backgroundColor = UIColor.clear
        curtain.isUserInteractionEnabled = true
        view.addSubview(curtain)
    }

    @objc private func closeBubble(_ sender: UITapGestureRecognizer) {
        let drawer = sender.view?.window?.rootViewController as? BaseMenuController
        let view = drawer?.currentRootViewController?.view
        view?.subviews.forEach { ($0 as? ExpensePredictiveView)?.dismiss() }
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
        lineLayer.fillColor = UIColor.lightPink.cgColor
        lineLayer.strokeColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.frame = CGRect(origin: CGPoint.zero, size: newFrame.size)
        lineLayer.fillRule = CAShapeLayerFillRule.evenOdd

        drawBubble(CGRect(x: (associatedViewFrame.origin.x + (associatedViewFrame.size.width / 2.0) - ( peakHeight)) - newFrame.origin.x,
                          y: bubblePosition == .top ? newFrame.origin.y + newFrame.height - peakHeight : bubblePosition == .bottom ? newFrame.origin.y : 0.0,
                          width: peakHeight * 2.0,
                          height: peakHeight))
        addShadow()
        layer.addSublayer(textLayer)
        layer.addSublayer(subTextLayer)
        textLayer.frame = CGRect(origin: CGPoint(x: 16.0, y: 7.0),
                                 size: CGSize(width: 2 * (newFrame.size.width / 3),
                                              height: newFrame.size.height - 14 - peakHeight))
        subTextLayer.frame = CGRect(origin: CGPoint(x: self.frame.size.width - (newFrame.size.width / 3), y: 15.0),
                                    size: CGSize(width: (newFrame.size.width / 3) - (14 - peakHeight),
                                                height: newFrame.size.height - 14 - peakHeight))
        drawText()
        drawSubText()
        presentAnimated(toFrame: newFrame)
    }

    private func presentAnimated(toFrame frame: CGRect) {
        alpha = 0.0
        textLayer.opacity = 0.0
        subTextLayer.opacity = 0.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.frame = frame
            self?.textLayer.opacity = 1.0
            self?.subTextLayer.opacity = 1.0
            self?.alpha = 1.0
        })
    }

    @objc private func dismissAnimated() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.textLayer.opacity = 0.0
            self?.subTextLayer.opacity = 0.0
            self?.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }

    private func calculateFrameForBubble() -> CGRect {
        return CGRect(x: 22.0,
                      y: associatedViewFrame.origin.y + associatedViewFrame.height + peakHeight + frameSeparation,
                      width: fixedWidth,
                      height: totalHeight())
    }
    
    private func totalHeight() -> CGFloat {
        return 56.0
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
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - layer.cornerRadius - peakHeight))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.size.width - layer.cornerRadius, y: lineLayer.bounds.size.height - peakHeight),
                              control: CGPoint(x: lineLayer.bounds.size.width, y: lineLayer.bounds.size.height - peakHeight))
        if bubblePosition == .top {
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + peakPos.size.width, y: lineLayer.bounds.size.height - peakHeight))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + (peakPos.size.width / 2.0), y: lineLayer.bounds.size.height))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x, y: lineLayer.bounds.size.height - peakHeight))
        }
        linePath.addLine(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.size.height - peakHeight))
        linePath.addQuadCurve(to: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - layer.cornerRadius - peakHeight),
                              control: CGPoint(x: lineLayer.bounds.origin.x, y: lineLayer.bounds.size.height - peakHeight))
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
        supLayer.font = leftTextFont
        supLayer.fontSize = leftTextFont.pointSize
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
    
    private func drawSubText() {
        let supLayer = CATextLayer()
        supLayer.font = rightTextFont
        supLayer.fontSize = rightTextFont.pointSize
        supLayer.string = bubbleSubText
        supLayer.alignmentMode = CATextLayerAlignmentMode.right
        supLayer.foregroundColor = UIColor.black.cgColor
        supLayer.contentsScale = UIScreen.main.scale
        supLayer.frame.size = subTextLayer.frame.size
        supLayer.isWrapped = true
        if let styledText = self.localizedStyleText {
            supLayer.set(localizedStylableText: styledText, font: UIFont.santander(family: .text, size: 16), fontSize: 16)
        }
        subTextLayer.addSublayer(supLayer)
    }
}

class CloseDialogMultiLabelView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        remove()
        return super.hitTest(point, with: event)
    }

    func remove() {
        let drawer = window?.rootViewController as? BaseMenuController
        let view = drawer?.currentRootViewController?.view
        view?.subviews.forEach { ($0 as? ExpensePredictiveView)?.dismiss() }
        removeFromSuperview()
    }
}
