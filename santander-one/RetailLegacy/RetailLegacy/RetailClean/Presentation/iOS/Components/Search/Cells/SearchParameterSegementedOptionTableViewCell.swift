import UIKit

class SearchParameterSegementedOptionTableViewCell: BaseViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var didSelectOptionCompletion: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.addTarget(self, action: #selector(didSelectOption), for: .valueChanged)
        setSegmentStyle()
    }
    
    func setSegmentStyle() {
        let segmentGrayColor = UIColor.lisboaGray
        let backgroundColor = UIColor.uiWhite
        let tintColor = UIColor.sanRed
        segmentedControl.setBackgroundImage(imageWithColor(color: backgroundColor), for: .normal, barMetrics: .default)
        segmentedControl.setBackgroundImage(imageWithColor(color: tintColor), for: .selected, barMetrics: .default)
        segmentedControl.setDividerImage(imageWithColor(color: segmentGrayColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        let segAttributes = [NSAttributedString.Key.font: UIFont.latoMedium(size: 14.0), .foregroundColor: UIColor.sanGreyMedium]
        segmentedControl.setTitleTextAttributes(segAttributes, for: .normal)
        let segAttributesExtra = [NSAttributedString.Key.font: UIFont.latoBold(size: 14.0), .foregroundColor: UIColor.uiWhite]
        segmentedControl.setTitleTextAttributes(segAttributesExtra, for: .selected)
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.layer.borderColor = segmentGrayColor.cgColor
        segmentedControl.layer.masksToBounds = true
        segmentedControl.clipsToBounds = true
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc
    func didSelectOption() {
        didSelectOptionCompletion?(segmentedControl.selectedSegmentIndex)
    }
    
    func selectOption(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
 
    func options(_ options: [String]) {
        segmentedControl.removeAllSegments()
        for (index, option) in options.enumerated() {
            segmentedControl.insertSegment(withTitle: option, at: index, animated: false)
        }
    }
}
