//

import UIKit

class OrderHeaderStatusTableViewCell: BaseViewCell {
    
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var tickerNameLabel: UILabel!
    @IBOutlet weak var numberOfOrderLabel: UILabel!
    @IBOutlet weak var statusOrderContentView: UIView!
    @IBOutlet weak var statusOrderLabel: UILabel!
    
    var orderColor: String? {
        didSet {
            statusOrderContentView.backgroundColor = UIColor.fromHex(orderColor ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        tickerNameLabel.numberOfLines = 2
        orderDateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                               font: UIFont.latoRegular(size: 14),
                                               textAlignment: .center))
        
        tickerNameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: UIFont.latoSemibold(size: 20),
                                                textAlignment: .center))
        
        numberOfOrderLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                   font: UIFont.latoLight(size: 14),
                                                   textAlignment: .center))
        
        statusOrderLabel.applyStyle(LabelStylist(textColor: .uiWhite,
                                                 font: UIFont.latoMedium(size: 14),
                                                 textAlignment: .center))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
