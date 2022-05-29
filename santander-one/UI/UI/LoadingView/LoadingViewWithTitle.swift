import Foundation

public final class LoadingViewWithTitle: XibView {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func configView(_ title: String) {
        titleLabel.text = title
    }
}

private extension LoadingViewWithTitle {
    func setupView() {
        backgroundColor = .clear
        imageView.setPointsLoader()
        titleLabel.font = .santander(family: .micro, type: .regular, size: 14)
    }
}
