import UIKit

class StockBaseHeaderView: BaseHeader, ViewCreatable {
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceDateLabel: UILabel!
    @IBOutlet weak var priceVariationLabel: UILabel!
    @IBOutlet weak var variationLabel: UILabel!
    @IBOutlet weak var variationImageView: UIImageView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var priceLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tickerLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        priceDateLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 12.0)))
        priceVariationLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        variationLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14.0)))
        separator.backgroundColor = .lisboaGray
        priceLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 18.0)))
    }
}
