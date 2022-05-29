//

import UIKit

protocol BannerShadowProtocol {
    var hasShadows: Bool { get }
    func willReuseView(viewCell: BannerTableViewCell)
}

class BannerTableViewCell: BaseViewCell {
    @IBOutlet weak var imageURLView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    public var modelView: BannerShadowProtocol?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        modelView?.willReuseView(viewCell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageURLView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerView.backgroundColor = .clear
        imageURLView.backgroundColor = .clear
    }
    
    func finishDownload() {
        setNeedsLayout()
        layoutIfNeeded()
        layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let modelView = self.modelView else { return }
        modelView.hasShadows ? formatBannerShadow() : formatBannerNoShadow()
    }
}

private extension BannerTableViewCell {
    func formatBannerShadow() {
        imageURLView.layer.cornerRadius = 5.0
        imageURLView.layer.borderWidth = 1.0
        imageURLView.layer.borderColor = UIColor.lisboaGray.cgColor
        imageURLView.clipsToBounds = true
        imageURLView.layoutIfNeeded()
        containerView.drawRoundedAndShadowed()
    }
    
    func formatBannerNoShadow() {
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32.0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -23.0).isActive = true
        imageURLView.contentMode = .scaleAspectFit
        imageURLView.layoutIfNeeded()
    }
}
