import UIKit
import CoreFoundationLib

typealias ImageTitleCollectionCellItem = CollectionCellConfigurator<ImageTitleCollectionViewCell, ImageTitleCollectionViewModel>

class ImageTitleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15.0)))
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        StylizerNonCollapsibleViewCells.applyAllCornersViewCellStyle(view: backView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backView.layer.cornerRadius = 5.0
        StylizerNonCollapsibleViewCells.applyAllCornersViewCellStyle(view: backView)
    }
    
}

extension ImageTitleCollectionViewCell: ConfigurableCell {
    func configure(data: ImageTitleCollectionViewModel) {
        titleLabel.text = localized(data.title ?? "")
        titleLabel.textAlignment = .center
        
        if let relativeURL = data.imageRelativeURL {
            if let placeHolder = data.imagePlaceholder {
                data.imageLoader.load(relativeUrl: relativeURL, imageView: iconImageView, placeholder: placeHolder)
            } else {
                data.imageLoader.load(relativeUrl: relativeURL, imageView: iconImageView, placeholderIfDoesntExist: "icnSanRedMenu")
            }
        }
    }
}
