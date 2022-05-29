//

import UIKit

protocol PersonalManagerPageControlDelegate: class {
    func didSelected(at index: Int) -> Bool
}

class PersonalManagerPageControl: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleOneLabel: UIButton!
    @IBOutlet weak var titleTwoLabel: UIButton!
    @IBOutlet weak var managerPageControl: PillPageControl!
    
    weak var delegate: PersonalManagerPageControlDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        managerPageControl.pillSize = CGSize(width: bounds.size.width / 2, height: 3)
    }
    
    // MARK: - Publics
    func setupTitleOne(with titleOne: LocalizedStylableText, titleTwo: LocalizedStylableText) {
        var one = titleOne
        one.text = titleOne.text.uppercased()
        var two = titleTwo
        two.text = titleTwo.text.uppercased()
        titleOneLabel.set(localizedStylableText: one, state: .normal)
        titleTwoLabel.set(localizedStylableText: two, state: .normal)
    }
    
    func pageIndicator(at index: Int) {
        managerPageControl.layoutPageIndicator(index)
        switch index {
        case 0:
            titleOneLabel.applyStyle(activeButtonStyle())
            titleTwoLabel.applyStyle(inactiveButtonStyle())
        default:
            titleOneLabel.applyStyle(inactiveButtonStyle())
            titleTwoLabel.applyStyle(activeButtonStyle())
        }
    }
    
    // MARK: - Privates
    private func setupViews() {
        Bundle.module?.loadNibNamed("PersonalManagerPageControl", owner: self)
        addSubview(contentView)
        contentView.frame = self.frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        initialSetup()
    }
    
    private func initialSetup() {
        titleOneLabel.applyStyle(activeButtonStyle())
        titleTwoLabel.applyStyle(inactiveButtonStyle())
        titleOneLabel.tag = 0
        titleTwoLabel.tag = 1
        managerPageControl.pageCount = 2
        //managerPageControl.pillSize = CGSize(width: bounds.size.width / 2, height: 3)
        managerPageControl.activeTint = .sanRed
        managerPageControl.inactiveTint = UIColor.clear
        managerPageControl.indicatorPadding = 0
    }
    
    private func activeButtonStyle() -> ButtonStylist {
        return ButtonStylist(textColor: .sanRed, font: UIFont.latoBold(size: UIScreen.main.isIphone4or5 ? 12 : 14))
    }
    
    private func inactiveButtonStyle() -> ButtonStylist {
        return ButtonStylist(textColor: .sanGreyMedium, font: UIFont.latoRegular(size: UIScreen.main.isIphone4or5 ? 12 : 14))
    }
    
    // MARK: - IBActions
    @IBAction func titleOneAction(_ sender: UIButton) {
        if delegate?.didSelected(at: sender.tag) == true {
            pageIndicator(at: sender.tag)
            titleOneLabel.applyStyle(activeButtonStyle())
            titleTwoLabel.applyStyle(inactiveButtonStyle())
        }
    }
    
    @IBAction func titleTwoAction(_ sender: UIButton) {
        if delegate?.didSelected(at: sender.tag) == true {
            pageIndicator(at: sender.tag)
            titleOneLabel.applyStyle(inactiveButtonStyle())
            titleTwoLabel.applyStyle(activeButtonStyle())
        }
    }
    
}
