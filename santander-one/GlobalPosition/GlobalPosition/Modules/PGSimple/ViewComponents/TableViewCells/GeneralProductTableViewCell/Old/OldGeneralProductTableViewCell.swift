import UIKit
import UI
import CoreFoundationLib

class OldGeneralProductTableViewCell: UITableViewCell, GeneralPGCellProtocol, RoundedCellProtocol, DiscretePGCellProtocol {
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet private weak var bottomSeparationView: UIView?
    @IBOutlet private weak var movementsSeparationView: UIView!
    @IBOutlet private weak var movementsSeparationLeading: NSLayoutConstraint!
    @IBOutlet private weak var movementsSeparationTrailing: NSLayoutConstraint!
    @IBOutlet private weak var movementsNumLabel: UILabel!
    @IBOutlet private weak var movementsLabel: UILabel!
    @IBOutlet private weak var piggyBankImage: UIImageView?
    @IBOutlet private weak var piggyBankImageWidthConstraint: NSLayoutConstraint!

    private var discreteMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureLabels()
        bottomSeparationView?.isHidden = true
        discreteMode = false
        valueLabel?.removeBlur()
        onlySideFrame()
        piggyBankImage?.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if discreteMode {
            guard !(valueLabel?.text?.isEmpty ?? true) else {
                valueLabel?.removeBlur()
                return
            }
            valueLabel?.blur(5.0)
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 82.0)
    }
    
    func setCellInfo(_ info: Any?) {
        if let info = info as? PGGeneralCellViewModelProtocol {
            if let accountEntity = info.elem as? AccountEntity {
                showsPiggyBankImage(accountEntity)
                titleLabel?.numberOfLines = 1
                titleLabel?.lineBreakMode = .byTruncatingTail
            }
            set(info.title, info.subtitle, info.ammount)
            setAccessibilityIdentifiers(info: info)
            guard let number = info.notification, number != 0 else { return hideMovementsViews(true) }
            hideMovementsViews(false)
            movementsNumLabel.text = "\(number)"
            let localizedKey = number == 1 ? "pgBasket_label_transaction_one" : "pgBasket_label_transaction_other"
            movementsLabel.configureText(withKey: localizedKey)
        }
    }
    
    func roundTopCorners() {
        layer.shadowOffset = CGSize(width: 1.0, height: 0.0); layer.shadowRadius = 1
        frameView?.roundTopCorners()
        bottomSeparationView?.isHidden = false
    }
    
    func roundBottomCorners() {
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0); layer.shadowRadius = 2
        frameView?.roundBottomCorners()
        bottomSeparationView?.isHidden = true
    }
    
    func roundCorners() {
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 2
        frameView?.roundAllCorners()
        bottomSeparationView?.isHidden = true
    }
    
    func removeCorners() {
        frameView?.removeCorners()
    }
    
    func onlySideFrame() {
        frameView?.onlySideFrame()
    }

    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
    }
    
    func configureView() {
        selectionStyle = .none
        clipsToBounds = false
        setConfigureView()
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.7
        layer.shadowColor = UIColor.mediumSkyGray.cgColor
    }
}

private extension OldGeneralProductTableViewCell {
    func setConfigureView() {
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        bottomSeparationView?.backgroundColor = UIColor.lightSanGray.withAlphaComponent(0.9)
        movementsSeparationView.backgroundColor = UIColor.brownGray
    }
    
    func set(_ title: String?, _ subtitle: String?, _ value: NSAttributedString?) {
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        valueLabel?.attributedText = value
    }
    
    func commonInit() {
        configureLabels()
        configureView()
    }
    
    func configureLabels() {
        configure(titleLabel, 18.0, .bold)
        titleLabel?.numberOfLines = 2
        configure(subtitleLabel, 15.0, .regular)
        configure(valueLabel, 22.0, .regular)
        configure(movementsLabel, 14.0, .regular)
        configure(movementsNumLabel, 14.0, .bold)
        movementsLabel.textColor = .brownGray
        movementsNumLabel.textColor = .santanderRed
    }
    
    func hideMovementsViews(_ hide: Bool) {
        movementsLabel.isHidden = hide
        movementsNumLabel.isHidden = hide
        movementsSeparationView.isHidden = hide
        movementsSeparationTrailing.constant = hide ? 0.0 : 8.0
        movementsSeparationLeading.constant = hide ? 0.0 : 8.0
    }
    
    func configure(_ label: UILabel?, _ size: CGFloat, _ weight: FontType) {
        label?.text = ""
        label?.textColor = UIColor.lisboaGray
        label?.font = UIFont.santander(family: .text, type: weight, size: size)
    }
    
    func showsPiggyBankImage(_ accountEntity: AccountEntity) {
        guard self.piggyBankImageWidthConstraint != nil else { return }
        if accountEntity.isPiggyBankAccount {
            self.piggyBankImage?.image = Assets.image(named: "imgPgPiggyBank")
            self.piggyBankImage?.isHidden = false
            NSLayoutConstraint.activate([self.piggyBankImageWidthConstraint])
        } else {
            self.piggyBankImage?.isHidden = true
            NSLayoutConstraint.deactivate([self.piggyBankImageWidthConstraint])
        }
    }
    
    private func setAccessibilityIdentifiers(info: PGGeneralCellViewModelProtocol) {
        if let elem = info.elem as? GlobalPositionProduct {
            self.accessibilityIdentifier = "pgSimple_\(elem.productId)"
            self.piggyBankImage?.accessibilityIdentifier = AccessibilityGlobalPosition.imgPGPiggyBank
            self.titleLabel?.accessibilityIdentifier = "pgSimple_\(elem.productId)_title"
            self.subtitleLabel?.accessibilityIdentifier = "pgSimple_\(elem.productId)_subtitle"
            self.valueLabel?.accessibilityIdentifier = "pgSimple_\(elem.productId)_value"
            self.movementsLabel.accessibilityIdentifier = "pgSimple_\(elem.productId)_movements"
            self.movementsNumLabel.accessibilityIdentifier = "pgSimple_\(elem.productId)_movementsNum"
        }
    }
}
