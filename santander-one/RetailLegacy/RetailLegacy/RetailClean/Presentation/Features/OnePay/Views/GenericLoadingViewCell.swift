import UIKit
import UI

class GenericLoadingViewCell: BaseViewCell {

    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var skeletonImagesStackView: UIStackView!
    private let indexLabel = "[index]"
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else {
            titleLabel.text = nil
            return
        }
        titleLabel.set(localizedStylableText: title)
    }

    func setSubtitle(_ title: LocalizedStylableText?) {
        guard let title = title else {
            subtitleLabel.text = nil
            return
        }
        subtitleLabel.set(localizedStylableText: title)
    }
    
    func setSkeletonImageKey(_ keyName: String?, times: Int = 2) {
        for view in skeletonImagesStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        guard let keyName = keyName else { return }
        
        for _ in 0..<times {
            let imageView = UIImageView(image: Assets.image(named: keyName))
            imageView.alpha = 0.5
            skeletonImagesStackView.addArrangedSubview(imageView)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 22), textAlignment: .center))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 15), textAlignment: .center))
        loadingView.setSecondaryLoader(scale: 2.0)
        selectionStyle = .none
        adjustConstraintForIPhone5()
    }
    
    func adjustConstraintForIPhone5() {
        if UIScreen.main.isIphone4or5 {
            topConstraint.constant = 15
        } else {
            topConstraint.constant = 50
        }
    }
    
    func startAnimation() {
        loadingView.setSecondaryLoader(scale: 2.0)
    }
}
