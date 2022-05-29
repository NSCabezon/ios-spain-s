import UIKit

public final class ProgressBar: UIView {
    private var view: UIView!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var progressWidth: NSLayoutConstraint!

    private var isAnimatingProgress: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
      
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        xibSetup()
        setCornerRadius()
        setEmptyBackgroundColor()
        self.progressView.backgroundColor = UIColor.darkTorquoise
        self.view.backgroundColor = .silverDark
        self.progressWidth.constant = 0.0
    }
    
    private func setCornerRadius() {
        self.view.layer.cornerRadius = self.view.frame.height / 2.0
        self.progressView.layer.cornerRadius = self.view.frame.height / 2.0
        self.layer.cornerRadius = self.view.frame.height / 2.0
    }
    
    private func setEmptyBackgroundColor() {
        self.view.backgroundColor = UIColor.lightSanGray
    }
    
    private func xibSetup() {
       view = loadViewFromNib()
       view.frame = bounds
       addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
       let bundle = Bundle.module
       let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
       return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    public func setProgressPercentage(_ percentage: CGFloat) {
        let progress = percentage / 100
        self.progressWidth.constant = progress * self.view.frame.width
        setNeedsLayout()
    }
    
    public func setProgressPercentageAnimated(_ percentage: CGFloat) {
        if percentage > 100 {
            self.animateProgress(1)
        } else {
            let progress = percentage / 100
            self.animateProgress(progress)
        }
    }
    
    private func animateProgress(_ percentage: CGFloat) {
        guard !isAnimatingProgress else { return }
        self.progressWidth.constant = 0
        self.view.layoutIfNeeded()
        isAnimatingProgress = true
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseInOut) {
            self.progressWidth.constant = percentage * self.view.frame.width
            self.view.layoutIfNeeded()
        } completion: { finished in
            if finished {
                self.isAnimatingProgress = false
            }
        }
    }
    
    public func setProgressBackgroundColor(_ color: UIColor) {
        self.view.backgroundColor = color
    }
    
    public func setProgresColor(_ color: UIColor) {
        self.progressView.backgroundColor = color
    }
    
    public func setProgressAlpha(_ alpha: CGFloat) {
        self.progressView.alpha = alpha
    }
}
