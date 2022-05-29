//
//  DragButton.swift
//  UI
//
//  Created by David Gálvez Alonso on 23/01/2020.
//

import Foundation

public protocol DragButtonDelegate: AnyObject {
    func createdCopy(_ copy: UIView, actionButton: DragButton)
    func handleButtonGesture(sender: UIGestureRecognizer, actionButton: DragButton)
}

public final class DragButton: ActionButton {
    public var isDragDisabled = true
    private var shadow = UIView()

    private var isOnLongGesture = false
    private var isOnPanGesture = false
    private var isWiggling = false
    
    weak var delegate: DragButtonDelegate?
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isWiggling else { return }
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isWiggling else { return }
        super.touchesEnded(touches, with: event)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isWiggling else { return }
        super.touchesCancelled(touches, with: event)
    }
    
    public func createCopy() -> UIView {
        let copyView = self.copyView() ?? UIView()
        
        copyView.subviews.first?.removeFromSuperview()
        copyView.translatesAutoresizingMaskIntoConstraints = false
        copyView.autoresizesSubviews = false
        (copyView as? DragButton)?.setViewModel(self.getViewModel(), isDragDisabled: isDragDisabled)
        (copyView as? DragButton)?.setDragDisabled(isDragDisabled)
        (copyView as? DragButton)?.setExtraLabelContent(highlightedInfo)
        (copyView as? DragButton)?.extraTopLabelContainer.isHidden = true
        (copyView as? DragButton)?.buttonContainer.layer.cornerRadius = 5
        (copyView as? DragButton)?.enableDrag()
        (copyView as? DragButton)?.setAppearance(withStyle: self.style)
        
        return copyView
    }

    public func resetView() {
        shadow.removeFromSuperview()
        buttonContainer.alpha = 1
        extraTopLabelContainer.isHidden = extraTopLabel.text == ""
        isOnLongGesture = false
        isOnPanGesture = false
    }
    
    public func swapButton(actionButton: ActionButton) {
        self.setViewModel(actionButton.getViewModel())
        self.setExtraLabelContent(actionButton.highlightedInfo)
        self.setAppearance(withStyle: actionButton.style)
        self.enableDrag()
        extraTopLabelContainer.isHidden = true
    }
    
    public func copyView() -> UIView? {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView
    }
    
    func setDragDisabled(_ disabled: Bool) {
        self.isDragDisabled = disabled
    }
    
    func configureDraggable(delegate: DragButtonDelegate?) {
        self.delegate = delegate
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.2
        self.addGestureRecognizer(longPress)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleButtonGesture))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
    }
    
    func enableDrag() {
        guard !isDragDisabled else { return }
        self.fillView?.setDragIconVisibility(isHidden: false)
        startWiggle()
    }
    
    public func handlePanBegan() {
        extraTopLabelContainer.isHidden = true
        buttonContainer.alpha = 0
        addShadow()
        isOnLongGesture = true
    }
    
    // MARK: - Gestures
    
    @objc func handleLongGesture(_ sender: UILongPressGestureRecognizer) {
        
        guard !isDragDisabled else { return }
        
        if !isOnLongGesture {
            delegate?.createdCopy(createCopy(), actionButton: self)
        }
        if (sender.state == .ended || sender.state == .cancelled || sender.state == .failed) && !isOnPanGesture {
            delegate?.handleButtonGesture(sender: sender, actionButton: self)
        }
    }
    
    @objc func handleButtonGesture(sender: UIPanGestureRecognizer) {
        guard isOnLongGesture else { return }
        guard !isDragDisabled else { return }
        
        if !isOnPanGesture { isOnPanGesture = true }
        
        delegate?.handleButtonGesture(sender: sender, actionButton: self)
    }
    
    // MARK: Private funcs
    
    private func addShadow() {
        shadow = UIView(frame: buttonContainer.frame)
        shadow.layer.backgroundColor = style.emptyShadow.cgColor
        shadow.layer.cornerRadius = 5
        shadow.layer.masksToBounds = true
        
        addSubview(shadow)
        addBorderShadow()
    }
    
    private func addBorderShadow() {
        
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        
        let frameSize = self.shadow.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = style.borderColor.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.shadow.layer.masksToBounds = false
        self.shadow.layer.addSublayer(shapeLayer)
    }
    
    private func startWiggle() {
        
        isWiggling = true
        
        let wiggleRotateAngle = 0.06
        let wiggleRotateDuration = 0.155
        let wiggleRotateDurationVariance = 0.025
        
        let rotationAnim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnim.values = [-wiggleRotateAngle, wiggleRotateAngle]
        rotationAnim.autoreverses = true
        rotationAnim.duration = randomize(interval: wiggleRotateDuration, withVariance: wiggleRotateDurationVariance)
        rotationAnim.repeatCount = HUGE
        
        UIView.animate(withDuration: 0) {
            self.buttonContainer.layer.add(rotationAnim, forKey: "rotation")
            self.buttonContainer.transform = .identity
        }
    }
    
    private func randomize(interval: TimeInterval, withVariance variance: Double) -> Double {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
}

extension DragButton: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
