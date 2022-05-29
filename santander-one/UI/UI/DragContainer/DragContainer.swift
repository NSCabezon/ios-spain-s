//
//  DragContainer.swift
//  UI
//
//  Created by David Gálvez Alonso on 05/08/2020.
//

import Foundation

public final class DragContainer: UIView {
    
    public var copyView: UIView?
    
    private var originCenter = CGPoint.zero
    private var differenceScroll: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        isUserInteractionEnabled = false
    }
    
    public func moveCopyToOrigin(actionButton: ActionButton) {
        let newCoor = self.convert(originCenter, to: actionButton)
        self.copyView?.center = CGPoint(x: originCenter.x - newCoor.x, y: originCenter.y - newCoor.y)
    }

    public func swapButton(pointedButton: DragButton) {
        (copyView as? DragButton)?.swapButton(actionButton: pointedButton)
    }
    
    public func addSubviewCopy(_ copy: UIView, actionButton: DragButton) {
        guard copyView == nil else { return }
        
        actionButton.handlePanBegan()
        
        isUserInteractionEnabled = true
        
        self.copyView = copy
        self.originCenter = copy.center

        addSubview(copy)
        layoutIfNeeded()
        
        self.moveCopyToOrigin(actionButton: actionButton)
        
        animationTouchBegan()
    }
    
    public func handleButtonGesture(sender: UIGestureRecognizer, actionButton: ActionButton) {
        if let translationPoint = (sender as? UIPanGestureRecognizer)?.translation(in: self) {
            moveCopyView(translationPoint, actionButton: actionButton)
        }
    }

    public func resetView() {
        copyView?.removeFromSuperview()
        isUserInteractionEnabled = false
        differenceScroll = 0
        copyView = nil
    }
    
    public func updateCopyView(position: CGFloat) {
        self.differenceScroll += position
    }
}

private extension DragContainer {
    
    func animationTouchBegan() {
        UIView.animate(withDuration: 0.3, animations: {
            self.copyView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
    }
    
    func moveCopyView(_ translationPoint: CGPoint, actionButton: ActionButton) {
        let newCoor = self.convert(originCenter, to: actionButton)
        let verticalPoint = originCenter.y - newCoor.y + translationPoint.y + differenceScroll
        guard verticalPoint >= 0 else { return }
        
        copyView?.center = CGPoint(x: originCenter.x - newCoor.x + translationPoint.x, y: verticalPoint)
    }
}
