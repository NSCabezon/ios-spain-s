//
//  EmbassyExpandableView.swift
//  PersonalArea
//
//  Created by alvola on 20/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol EmbassyExpandableViewDelegate: AnyObject {
    func heightDidChange()
}

final class EmbassyExpandableView: DesignableView {
    
    enum State {
        case expanded
        case contracted
        
        mutating func switchState() {
            switch self {
            case .expanded:
                self = .contracted
            case .contracted:
                self = .expanded
            }
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var embassyDetailLabel: UILabel!
    
    private var height: NSLayoutConstraint?
    private var contentHeight: NSLayoutConstraint?
    private var expandedHeight: CGFloat = 88.0
    private var contractedHeight: CGFloat = 88.0
    private var currentCountry: String = ""
    weak var delegate: EmbassyExpandableViewDelegate?
    
    private var state: State = .contracted {
        didSet {
            rotateArrow()
            updateHeight()
            embassyDetailLabel.isHidden = state == .contracted
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.layoutSubviews()
        contentView?.subviews.forEach({ $0.layoutSubviews() })
        refreshTitle()
        refreshHeight()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setEmbassyInfo(_ info: EmbassyViewModel) {
        currentCountry = info.country
        setEmbassyDescription(info)
        setCountry(info.country)
        setNeedsLayout()
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabel()
        configureImage()
        configureArrow()
    }
    
    private func configureView() {
        guard let contentView = contentView else { return }
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -0.0),
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0)
        ])
        contentView.backgroundColor = UIColor.white
        contentView.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSky, widthOffSet: 1, heightOffSet: 2)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                 action: #selector(arrowDidPressed)))
        contentView.isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentHeight = contentView.heightAnchor.constraint(equalToConstant: contractedHeight)
        contentHeight?.isActive = true
        height = heightAnchor.constraint(equalToConstant: contractedHeight)
        height?.isActive = true
    }
    
    private func configureImage() {
        iconImageView?.image = Assets.image(named: "icnEmbassy")
        iconImageView?.contentMode = .scaleAspectFill
    }
    
    private func configureLabel() {
        titleLabel?.textColor = .lisboaGray
        titleLabel?.minimumScaleFactor = 0.5
        setCountry("")
    }
    
    private func configureArrow() {
        arrowIcon?.image = Assets.image(named: "icnArrowDownGreen")
    }
    
    private func setCountry(_ country: String) {
        titleLabel?.configureText(withLocalizedString: localized("yourTrips_button_embassy",
                                                         [StringPlaceholder(.value, country)]),
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20.0)))
    }
    
    private func refreshTitle() {
        titleLabel?.refreshFont(force: true)
        setCountry(currentCountry)
    }
    
    private func refreshHeight() {
        expandedHeight = heightWith(embassyDetailLabel?.text ?? "",
                                    UIFont.santander(type: .bold, size: 14.0),
                                    embassyDetailLabel?.frame.width ?? 0.0) + contractedHeight
    }
    
    private func updateHeight() {
        let completion = { [weak self] in
            guard let self = self else { return }
            self.height?.constant = self.state == .contracted ? self.contractedHeight : self.expandedHeight
            self.delegate?.heightDidChange()
        }
        
        contentHeight?.constant = state == .contracted ? contractedHeight : expandedHeight
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
            completion()
        })
    }
    
    private func setEmbassyDescription(_ info: EmbassyViewModel) {
        let detail = NSMutableAttributedString()
        detail.append(boldAttributedDescription(info.title))
        detail.append(regularAttributedDescription(info.address))
        detail.append(boldAttributedDescription(info.titleTelephone))
        detail.append(regularAttributedDescription(info.telephone))
        detail.append(boldAttributedDescription(info.titleConsular))
        detail.append(regularAttributedDescription(info.telephoneConsularEmergency))
        
        embassyDetailLabel?.attributedText = detail
        embassyDetailLabel?.isHidden = state == .contracted
    }
    
    private func boldAttributedDescription(_ text: String) -> NSAttributedString {
        return NSAttributedString(string: text + "\n",
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lisboaGray,
                                               NSAttributedString.Key.font: UIFont.santander(type: .bold, size: 14.0)])
    }
    
    private func regularAttributedDescription(_ text: String) -> NSAttributedString {
        return NSAttributedString(string: text + "\n",
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.grafite,
                                               NSAttributedString.Key.font: UIFont.santander(size: 14.0)])
    }
    
    private func rotateArrow() {
        if let rotation = state == .expanded ? arrowIcon?.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.arrowIcon?.transform = rotation
            }
        }
    }
    
    @objc private func arrowDidPressed() {
        self.state.switchState()
    }
    
    private func heightWith(_ text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: width,
                                          height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}
