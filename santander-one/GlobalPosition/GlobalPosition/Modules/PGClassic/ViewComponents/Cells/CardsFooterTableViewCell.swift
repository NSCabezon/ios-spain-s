//
//  CardsFooterTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 27/11/2019.
//

import UI
import CoreFoundationLib

final class CardsFooterTableViewCell: UITableViewCell, GeneralPGCellProtocol {
    
    @IBOutlet private weak var frameView: RoundedView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak private var cardsContainer: UIStackView?
    private var cardsImgUrl: [String] = [String]()
    private var currentTask: CancelableTask?
    private lazy var threeDotsLabel: UILabel = {
       let label = ThreeDotsView()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = ""
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? GeneralFooterInfo else { return }
        if let imgurls = info.cardsStringURL, imgurls != cardsImgUrl {
            cardsImgUrl.removeAll(keepingCapacity: true)
            currentTask?.cancel()
            cardsImgUrl.append(contentsOf: imgurls)
            setCardsImages()
        }
        titleLabel?.configureText(withLocalizedString: info.title)
    }
        
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 35.0)
    }
    
    func setAccessibilityIdentifier(identifier: String? = nil) {
        if let identifier = identifier?.lowercased() {
            self.titleLabel?.accessibilityIdentifier = "pgClassic_\(identifier)_footer_titleLabel"
            self.cardsContainer?.accessibilityIdentifier = "pgClassic_\(identifier)_footer_cardsContainer"
            self.accessibilityIdentifier = "pgClassic_\(identifier)_footer"
            self.threeDotsLabel.accessibilityIdentifier = "threeDotsLabel"
        }
    }
}

private extension CardsFooterTableViewCell {
    func commonInit() {
        configureView()
        configureLabels()
    }
    
    func configureView() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.skyGray
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        frameView?.roundBottomCorners()
    }
    
    func configureLabels() {
        titleLabel?.setHeadlineTextFont(type: .regular, size: 16.0, color: .grafite)
    }
    
    func setCardsImages() {
        removeCardsImages()
        let maxImages: Int = Screen.isScreenSizeBiggerThanIphone5() ? 5 : 4
        for (idx, stringUrl) in cardsImgUrl.enumerated() where idx < maxImages {
            let cardImgView = makeCardImageViewWithUrl(stringUrl)
            cardsContainer?.addArrangedSubview(cardImgView)
        }
        if cardsImgUrl.count > maxImages {
            cardsContainer?.addArrangedSubview(threeDotsLabel)
        }
    }
    
    func makeCardImageViewWithUrl(_ stringUrl: String) -> UIImageView {
        let imgview = CardView()
        imgview.contentMode = .scaleAspectFit
        currentTask = imgview.loadImage(urlString: stringUrl, placeholder: Assets.image(named: "defaultCard"))
        imgview.isAccessibilityElement = true
        setAccessibility { imgview.isAccessibilityElement = false }
        imgview.accessibilityIdentifier = "pgClassic_card_footer_cardImage"
        return imgview
    }
    
    func removeCardsImages() {
        guard let stack = cardsContainer else { return }
        for view in stack.arrangedSubviews {
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension CardsFooterTableViewCell: FooterTableViewCellProtocol {}

extension CardsFooterTableViewCell: AccessibilityCapable { }
