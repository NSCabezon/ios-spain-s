import UI
import CoreDomain

final class FlipBackButtonView: UIView {
    
    var principal: UIView?
    var secondary: UIView?
    var time: Double = 6
        
    func configure(principalView: UIView, secondaryView: UIView, time: Double) {
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.time = time
        secondaryView.isHidden = true
        principalView.isHidden = false
        self.addSubview(secondaryView)
        secondaryView.fullFit()
        self.addSubview(principalView)
        principalView.fullFit()
        self.fullFit()
        self.principal = principalView
        self.secondary = secondaryView
        setNeedsLayout()
        addGesture()
    }
}

private extension FlipBackButtonView {
    
    func addGesture() {
        self.principal?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectFlipButton)))
        self.principal?.isUserInteractionEnabled = true
    }
    
    @objc func didSelectFlipButton() {
        guard let principal = self.principal,
              let secondary = self.secondary else { return }
        UIView.flipView(viewToShow: secondary,
                        viewToHide: principal,
                        flipBackIn: time)
    }
}
