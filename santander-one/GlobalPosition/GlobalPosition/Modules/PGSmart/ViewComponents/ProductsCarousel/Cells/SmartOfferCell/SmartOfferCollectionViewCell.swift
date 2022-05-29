import UI
import CoreFoundationLib
import OfferCarousel

protocol PullOfferCollectionCellDelegate: AnyObject {
    func pullOfferCloseDidPressed(_ elem: Any?)
}

class SmartOfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var contentViewCell: UIView?
    @IBOutlet weak private var offerImage: UIImageView?
    @IBOutlet weak private var closeImage: UIImageView?
    @IBOutlet weak var closeButton: UIButton!
    private var currentTask: CancelableTask?
    private var offer: Any?
    weak var delegate: PullOfferCollectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        offer = nil
        offerImage?.image = nil
        currentTask?.cancel()
    }
    
    func setCellDelegate(_ delegate: PullOfferCollectionCellDelegate?) {
        self.delegate = delegate
    }
}

extension SmartOfferCollectionViewCell: GeneralPGCellProtocol {
    func setCellInfo(_ info: Any?) {
        guard let info = info as? CarouselOfferViewModel, let image = info.imgURL else { return }
        offer = info.elem
        currentTask = self.offerImage?.loadImage(urlString: image)
        self.offerImage?.contentMode = .scaleAspectFill
        closeImage?.image = !info.transparentClosure ? Assets.image(named: "icnXPullofferCopy") : nil
        self.closeButton.accessibilityIdentifier = AccessibilityGlobalPositionSmart.icnCloseOffer.rawValue
        self.accessibilityIdentifier = AccessibilityGlobalPositionSmart.imgOffer.rawValue
        self.setAccessibility(setViewAccessibility: self.setAccessibilityLabel)
    }
    
    @IBAction func closeDidPressed(_ sender: UIButton) {
        self.delegate?.pullOfferCloseDidPressed(offer)
    }
}

private extension SmartOfferCollectionViewCell {
    func setAppearance() {
        self.contentViewCell?.layer.cornerRadius = 5
        self.contentViewCell?.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.offerImage?.layer.cornerRadius = 5
    }
    
    func setAccessibilityLabel() {
        self.offerImage?.accessibilityLabel = localized("voiceover_commercialOffer")
        self.offerImage?.accessibilityTraits = .button
        self.offerImage?.isAccessibilityElement = true
        self.closeButton?.accessibilityLabel = localized("siri_voiceover_close")
        self.closeButton?.isAccessibilityElement = true
    }
}

extension SmartOfferCollectionViewCell: AccessibilityCapable { }
