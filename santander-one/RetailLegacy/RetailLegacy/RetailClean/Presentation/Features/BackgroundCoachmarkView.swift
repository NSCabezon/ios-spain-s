import UI

class BackgroundCoachmarkView: UIView, TopWindowViewProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }

    private func setupViews() {
        backgroundColor = UIColor.shadowGray.withAlphaComponent(0.57)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        removeFromSuperview()
    }
    
}
