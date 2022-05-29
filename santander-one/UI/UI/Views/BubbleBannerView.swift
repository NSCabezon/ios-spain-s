//
//  BubbleBannerView.swift
//  UI
//
//  Created by Iván Estévez on 27/04/2020.
//

public final class BubbleBannerView: XibView {
    
    @IBOutlet private weak var bubbleImageView: UIImageView!
    private var action: (() -> Void)?
    private var closeTimeInterval = TimeInterval(4)
    private var timer: Timer?
    public weak var bottomRelativeView: UIView?
    public weak var delegate: FloatingBannerCloseDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupConstraints()
    }
    
    public func setImageUrl(_ url: String) {
        self.bubbleImageView.loadImage(urlString: url, placeholder: nil)
    }
    
    public func addAction(_ action : (() -> Void)?) {
        self.action = action
    }
    
    public func setAutomaticallyCloseInterval(_ value: Int) {
        self.closeTimeInterval = TimeInterval(value)
    }
    
    public func startAnimation() {
        self.scheduleAutomaticallyClose()
        transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { [weak self] completed in
                guard completed else { return }
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.transform = .identity
                })
        })
    }
    
    @objc public func close() {
        timer?.invalidate()
        removeFromSuperview()
        delegate?.didCloseFloatingBanner()
    }
}

private extension BubbleBannerView {
    func setupView() {
        bubbleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBanner)))
    }
    
    @objc func didSelectBanner() {
        action?()
    }
    
    func setupConstraints() {
        guard let parentView = self.superview, let view = self.view else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint: NSLayoutConstraint
        if let bottomRelativeView = bottomRelativeView {
            bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottomMargin, relatedBy: .equal, toItem: bottomRelativeView, attribute: .topMargin, multiplier: 1, constant: -11)
        } else {
            bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: -30)
        }
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: -15),
            bottomConstraint
        ])
    }
    
    func scheduleAutomaticallyClose() {
        self.timer = Timer.scheduledTimer(timeInterval: closeTimeInterval, target: self, selector: #selector(close), userInfo: nil, repeats: false)
    }
}
