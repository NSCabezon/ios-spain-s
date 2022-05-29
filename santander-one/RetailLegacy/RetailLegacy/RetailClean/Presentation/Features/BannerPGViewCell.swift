import UIKit

public protocol OnBannerSelectedProtocol {
    func onBannerSelected()
}

class BannerPGViewCell: BaseViewCell {
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bannerImage: UIImageView!    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTrailingConstraint: NSLayoutConstraint!
    
    var lastItem: Bool = false
    private var mProtocol: OnBannerSelectedProtocol?
    public var modelView: BannerPGModelView?
    var insets: UIEdgeInsets? {
        didSet {
            if let insets = insets {
                //LOS +1 LATERALES ES PARA MANTENER EL ALINEADO CON LAS OTRAS CELDAS
                imageLeadingConstraint.constant = insets.left+1
                imageTrailingConstraint.constant = insets.right+1
                imageTopConstraint.constant = insets.top
                imageBottomConstraint.constant = insets.bottom
                
                layoutSubviews()
            }
        }
    }
    
    var isClosable: Bool = false {
        didSet {
            closeButton.isHidden = !isClosable
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        modelView?.willReuseView(viewCell: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        content.backgroundColor = .uiBackground
        bannerImage.superview?.backgroundColor = .clear
        bannerImage.backgroundColor = .clear
        bannerImage.contentMode = .scaleAspectFit

        selectionStyle = .none
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if lastItem {
            StylizerPGViewCells.applyBottomViewCellStyle(view: containerView)
        } else {
            StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
        }
    }
    
    public func onImageLoadFinished() {
        if let imageSize = bannerImage.image?.size {
            let deviceWidth = bannerImage.frame.width
            let imageAspectRatio = imageSize.height / imageSize.width
            var newHeight = imageAspectRatio * deviceWidth
            if let bottom = self.insets?.bottom {
                newHeight += bottom
            }
            if let top = self.insets?.top {
                newHeight += top
            }
            //EL +6 ES PARA COMPENSAR EL PADDING NECESARIO PARA CREAR LA SOMBRA REDONDEADA DE ABAJO
            newHeight += 6
            
            bannerImage.clipsToBounds = true
            bannerImage.layer.masksToBounds = true
            bannerImage.layer.cornerRadius = 5
            
            modelView?.onImageLoadFinished(newHeight: newHeight)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setOnBannerSelectProtocol(_ mProtocol: OnBannerSelectedProtocol) {
        self.mProtocol = mProtocol
    }
    
    func setBackgroundColorCell(color: UIColor) {
        content.backgroundColor = color
    }
    
    @IBAction func touchUpInsideCloseButton(_ sender: Any) {
        modelView?.didCloseButton()
    }
}
