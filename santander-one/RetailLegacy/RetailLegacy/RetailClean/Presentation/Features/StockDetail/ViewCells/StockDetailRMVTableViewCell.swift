//

import UIKit

class StockDetailRMVTableViewCell: BaseViewCell {
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var fifthLabel: UILabel!

    var firstLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = firstLabelString {
                firstLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var secondLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = secondLabelString {
                secondLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var thirdLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = thirdLabelString {
                thirdLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var fourthLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = fourthLabelString {
                fourthLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var fifthLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = fifthLabelString {
                fifthLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var isHeader: Bool {
        set {
            self.backgroundColor = newValue ? .lisboaGray : .clear
        } get {
          return self.backgroundColor == .lisboaGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        firstLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium,
                                           font: UIFont.latoRegular(size: UIScreen.main.isIphone4or5 ? 8 : 10),
                                           textAlignment: .left))
        
        secondLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoLight(size: 10),
                                           textAlignment: .center))
        
        thirdLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                            font: UIFont.latoLight(size: 10),
                                            textAlignment: .center))
        
        fourthLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                            font: UIFont.latoLight(size: 10),
                                            textAlignment: .center))
        
        fifthLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                            font: UIFont.latoLight(size: 10),
                                            textAlignment: .center))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
