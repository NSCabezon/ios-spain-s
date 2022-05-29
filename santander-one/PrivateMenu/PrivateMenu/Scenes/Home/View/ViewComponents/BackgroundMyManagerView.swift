import UI

class BackgroundMyManagerView: UIView, TopWindowViewProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        removeFromSuperview()
    }
}

private extension BackgroundMyManagerView {
    func setupViews() {
        backgroundColor = UIColor.shadowGray.withAlphaComponent(0.57)
    }
}

