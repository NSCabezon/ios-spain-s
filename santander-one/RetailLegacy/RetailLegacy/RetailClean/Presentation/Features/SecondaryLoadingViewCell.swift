import UIKit

class SecondaryLoadingViewCell: BaseViewCell {
    
    @IBOutlet weak var loadingView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadingView.setSecondaryLoader(scale: 2.0)
        backgroundColor = UIColor.clear
        
    }
    
    override func prepareForReuse() {
        loadingView.startAnimating()
    }
}
