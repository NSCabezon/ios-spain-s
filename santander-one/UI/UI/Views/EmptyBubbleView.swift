//
//  EmptyBubbleView.swift
//  UI
//
//  Created by David Gálvez Alonso on 12/03/2020.
//

import Foundation

import UIKit
import CoreFoundationLib

final public class EmptyBubbleView: UIView {
    
    private let lineLayer: CAShapeLayer = CAShapeLayer()
    private var associatedViewFrame: CGRect = CGRect.zero
    
    private var fixedWidth: CGFloat = 268.0
    private var peakHeight: CGFloat = 6.0
    private var leftMargin: CGFloat = 40.0
    
    private var addedViewFrame: CGRect = CGRect.zero

    private weak var superwindow: UIWindow?
    
    private var curtain: UIView?
    private var bottomViewWithKeyboard: UIView?
    private var originPoint: CGPoint?
    
    private var isPeakTopPosition: Bool = true
    
    public init(associated: UIView, addedView: UIView) {
        super.init(frame: associatedViewFrame)
        associatedViewFrame = transformAssociatedFrame(associated)
        addedViewFrame = addedView.frame
        commonInit()
        self.addSubview(addedView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func dismiss() {
        dismissAnimated()
    }
    
    public func addCloseCourtain(view: UIView?) {
        curtain = UIView(frame: UIScreen.main.bounds)
        guard let curtain = curtain else { return }
        curtain.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.56)
        curtain.isUserInteractionEnabled = true
        curtain.isAccessibilityElement = true
        curtain.accessibilityLabel = localized("siri_voiceover_close")
        view?.addSubview(curtain)
    }
    
    public func getCloseAction() -> (() -> Void)? {
        let closeAction: () -> Void = { [weak self] in
            self?.closeBubble()
        }
        return closeAction
    }
    
    public func setBottomViewWithKeyboard(_ view: UIView) {
        self.bottomViewWithKeyboard = view
    }
}

// MARK: - Private methods

private extension EmptyBubbleView {
    
    func transformAssociatedFrame(_ view: UIView) -> CGRect {
        return  view.convert(view.bounds, to: nil)
    }
    
    func getFrameInsideScreenBounds(newFrame: CGRect) -> CGRect {
        let mainScreenBounds = UIScreen.main.bounds
        var newCGRect = newFrame
        let borderSpace: CGFloat = 5.0
        
        if newCGRect.origin.y + newFrame.size.height > mainScreenBounds.size.height - borderSpace {
            newCGRect.origin.y += -newFrame.size.height - peakHeight - associatedViewFrame.height
            newCGRect.origin.y += newCGRect.origin.y + newFrame.size.height > mainScreenBounds.size.height - borderSpace ? mainScreenBounds.size.height - borderSpace - newFrame.size.height - newCGRect.origin.y : 0

            isPeakTopPosition = false
        }
        newCGRect.origin.x += newCGRect.origin.x + newFrame.size.width > mainScreenBounds.size.width - borderSpace ? mainScreenBounds.size.width - borderSpace - newFrame.size.width - newCGRect.origin.x : 0
        
        return newCGRect
    }
    
    func commonInit() {
        let newFrame = calculateFrameForBubble()
        frame = getFrameInsideScreenBounds(newFrame: newFrame)
        layer.backgroundColor = UIColor.clear.cgColor
        addLineLayer(frame)
        drawBubble(CGRect(x: (associatedViewFrame.origin.x + (associatedViewFrame.size.width / 2.0) - (peakHeight)) - frame.origin.x,
                          y: frame.origin.y,
                          width: peakHeight * 2.0,
                          height: peakHeight))
        addShadow()
        presentAnimated(toFrame: frame)
    }
    
    func addLineLayer(_ newFrame: CGRect) {
        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.white.cgColor
        lineLayer.strokeColor = UIColor.paleSanGray.cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.frame = CGRect(origin: CGPoint.zero, size: newFrame.size)
        lineLayer.fillRule = CAShapeLayerFillRule.evenOdd
    }
    
    func presentAnimated(toFrame frame: CGRect) {
        alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.frame = frame
            self?.alpha = 1.0
        })
    }
    
    @objc func dismissAnimated() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 0.0
            self?.curtain?.removeFromSuperview()
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
    
    func calculateFrameForBubble() -> CGRect {
        let totalHeight: CGFloat = addedViewFrame.height + peakHeight
        let associatedEndX = associatedViewFrame.origin.x + associatedViewFrame.width
        let originX = associatedEndX - fixedWidth
        let correction: CGFloat = originX < leftMargin ? leftMargin - originX : 0.0
        let initialPosition = originX + correction > associatedViewFrame.origin.x ? associatedViewFrame.origin.x : originX + correction
        
        return CGRect(x: initialPosition,
                      y: associatedViewFrame.origin.y + associatedViewFrame.height + peakHeight,
                      width: addedViewFrame.width,
                      height: totalHeight)
    }
    
    func drawBubble(_ peakPos: CGRect) {
        let linePath = CGMutablePath()

        linePath.move(to: CGPoint(x: lineLayer.bounds.origin.x + layer.cornerRadius, y: lineLayer.bounds.origin.y))
        
        if isPeakTopPosition {
            linePath.addLine(to: CGPoint(x: peakPos.origin.x, y: lineLayer.bounds.origin.y))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + (peakPos.width / 2.0), y: lineLayer.bounds.origin.y - peakPos.height))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + peakPos.size.width, y: lineLayer.bounds.origin.y))
        } else {
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + peakPos.size.width, y: lineLayer.bounds.size.height - peakHeight))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x + (peakPos.size.width / 2.0), y: lineLayer.bounds.size.height))
            linePath.addLine(to: CGPoint(x: peakPos.origin.x, y: lineLayer.bounds.size.height - peakHeight))
        }
        
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
        
    func addShadow() {
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
    
    @objc func closeBubble() {
        window?.subviews.forEach { ($0 as? EmptyBubbleView)?.dismiss() }
    }
}

extension EmptyBubbleView {

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let bottomViewWithKeyboard = bottomViewWithKeyboard else { return }
        guard let viewPosition = bottomViewWithKeyboard.superview?.convert(bottomViewWithKeyboard.frame.origin, to: nil) else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let differencePosition = keyboardFrame.height - (UIScreen.main.bounds.height - viewPosition.y - bottomViewWithKeyboard.frame.height*1.2)
        
        if differencePosition > 0 {
            self.originPoint = self.frame.origin
            UIView.animate(withDuration: TimeInterval(truncating: duration), delay: 0, options: [UIView.AnimationOptions(rawValue: UInt(truncating: curve))], animations: {
                self.frame.origin.y -= differencePosition
            }, completion: nil)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let originPoint = self.originPoint else { return }
        guard bottomViewWithKeyboard != nil else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        
        UIView.animate(withDuration: TimeInterval(truncating: duration), delay: 0, options: [UIView.AnimationOptions(rawValue: UInt(truncating: curve))], animations: {
            self.frame.origin = originPoint
        }, completion: nil)
    }
}
