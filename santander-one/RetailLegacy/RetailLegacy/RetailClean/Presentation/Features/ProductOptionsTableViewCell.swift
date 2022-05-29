
import UIKit
import UI

protocol ProductOptionsTableViewCellDelegate: class {
    func getIndex(_ index: Int)
}

final class ProductOptionsTableViewCell: BaseViewCell {

    weak var delegate: ProductOptionsTableViewCellDelegate?
    var cellColor: BackgroundColor?
    
    @IBOutlet private weak var productImageOne: UIImageView!
    @IBOutlet private weak var productTitleOne: UILabel!
    @IBOutlet weak var productViewOne: UIView!
    var firstSeparator: CoachmarkBaseUIView!
    
    @IBOutlet private weak var productImageTwo: UIImageView!
    @IBOutlet private weak var productTitleTwo: UILabel!
    @IBOutlet weak var productViewTwo: UIView!
    var secondSeparator: CoachmarkBaseUIView!

    @IBOutlet private weak var productImageThree: UIImageView!
    @IBOutlet private weak var productTitleThree: UILabel!
    @IBOutlet weak var productViewThree: UIView!
    
    @IBOutlet private weak var productImageFour: UIImageView!
    @IBOutlet private weak var productTitleFour: UILabel!
    @IBOutlet weak var productViewFour: UIView!
    
    @IBOutlet weak var bottomSeparator: UIView!
    
    var firstSeparatorCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.firstSeparator.coachmarkId
        } set {
            self.firstSeparator.coachmarkId = newValue
        }
    }
    
    var secondSeparatorCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.secondSeparator.coachmarkId
        } set {
            self.secondSeparator.coachmarkId = newValue
        }
    }

    // MARK: - Awake
    override func awakeFromNib() {
        super.awakeFromNib()
        bottomSeparator.backgroundColor = .lisboaGray
        contentView.backgroundColor = cellColor?.getColor() ?? .sanGreyLight
        
        firstSeparator = CoachmarkBaseUIView(frame: CGRect(x: productViewTwo.frame.origin.x,
                                                           y: productViewTwo.frame.origin.y,
                                                           width: 1,
                                                           height: productViewTwo.frame.height))
        secondSeparator = CoachmarkBaseUIView(frame: CGRect(x: productViewThree.frame.origin.x,
                                                            y: productViewThree.frame.origin.y,
                                                            width: 1,
                                                            height: productViewThree.frame.height))
        firstSeparator.backgroundColor = .clear
        secondSeparator.backgroundColor = .clear
        self.addSubview(firstSeparator)
        self.addSubview(secondSeparator)
    }
    
    override func draw(_ rect: CGRect) {        
        contentView.backgroundColor = cellColor?.getColor() ?? .sanGreyLight
        firstSeparator.frame = CGRect(x: productViewTwo.frame.origin.x,
                                      y: productViewTwo.frame.origin.y,
                                      width: 1,
                                      height: productViewTwo.frame.height)
        secondSeparator.frame = CGRect(x: productViewThree.frame.origin.x,
                                       y: productViewThree.frame.origin.y,
                                       width: 1,
                                       height: productViewThree.frame.height)
    }
    
    func configureFirstButton(with option: ProductOption, firstSeparatorCoachmarkId: CoachmarkIdentifier?) {
        productViewOne.isHidden = false
        productImageOne.image = Assets.image(named: option.imageKey)?.withRenderingMode(.alwaysTemplate)
        productImageOne.tintColor = .santanderRed
        productTitleOne.applyStyle(LabelStylist.productHomeMenuOptions)
        productViewOne.tag = 0
        productTitleOne.set(localizedStylableText: option.title)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        productViewOne.addGestureRecognizer(tapGesture)
        self.firstSeparatorCoachmarkId = firstSeparatorCoachmarkId
    }
    
    func configureSecondButton(with option: ProductOption, secondSeparatorCoachmarkId: CoachmarkIdentifier?) {
        productViewTwo.isHidden = false
        productImageTwo.image = Assets.image(named: option.imageKey)?.withRenderingMode(.alwaysTemplate)
        productImageTwo.tintColor = .santanderRed
        productViewTwo.tag = 1
        productTitleTwo.applyStyle(LabelStylist.productHomeMenuOptions)
        productTitleTwo.set(localizedStylableText: option.title)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        productViewTwo.addGestureRecognizer(tapGesture)
        self.secondSeparatorCoachmarkId = secondSeparatorCoachmarkId
    }
    
    func configureThirdButton(with option: ProductOption) {
        productViewThree.isHidden = false
        productImageThree.image = Assets.image(named: option.imageKey)?.withRenderingMode(.alwaysTemplate)
        productImageThree.tintColor = .santanderRed
        productViewThree.tag = 2
        productTitleThree.applyStyle(LabelStylist.productHomeMenuOptions)
        productTitleThree.set(localizedStylableText: option.title)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        productViewThree.addGestureRecognizer(tapGesture)
    }
    
    func configureFourthButton(with option: ProductOption) {
        productViewFour.isHidden = false
        productImageFour.image = Assets.image(named: option.imageKey)?.withRenderingMode(.alwaysTemplate)
        productImageFour.tintColor = .santanderRed
        productViewFour.tag = 3
        productTitleFour.applyStyle(LabelStylist.productHomeMenuOptions)
        productTitleFour.set(localizedStylableText: option.title)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        productViewFour.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func optionAction(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        delegate?.getIndex(tag)
    }
}
