import Foundation

public protocol BannerViewDelegate: AnyObject {
    func ratioToResize(_ ratio: CGFloat)
}

public final class BannerView: XibView {
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var closeImageView: UIImageView!
    private var action: (() -> Void)?
    public weak var delegate: BannerViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func didSelectBannerAction(_ sender: Any) {
        self.action?()
    }
    
    @IBAction func didSelectClose(_ sender: Any) {
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addConstraints()
    }
    
    public func addAction(_ action : (() -> Void)?) {
        self.action = action
    }
    
    public func setTransparentClosure(_ transparentClosure: Bool) {
        closeImageView.image = !transparentClosure ? Assets.image(named: "icnXOffer") : nil
    }
    
    public func setImageUrl(_ url: String) {
        self.bannerImageView.loadImage(urlString: url, placeholder: nil) {
            guard let image = self.bannerImageView.image else { return }
            let ratio = image.size.height / image.size.width
            self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio).isActive = true
            self.layoutIfNeeded()
            self.delegate?.ratioToResize(ratio)
        }
    }
}

private extension BannerView {
    private func addConstraints() {
        guard let parentView = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
    }
}
