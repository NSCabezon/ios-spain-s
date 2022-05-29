import Foundation
import CoreFoundationLib
import UI

public protocol ContactsFlipViewViewDelegate: AnyObject {
    func didSelectFlipView(_ viewModel: ContactsFlipViewViewModel)
}

public final class ContactsFlipView: XibView {
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet private weak var phoneView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var hoursLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var phoneImageView: UIImageView!
    @IBOutlet private weak var flipButton: UIButton!
    @IBOutlet private weak var containerView: UIView!
    private let callView = ContactsFlipCallView()
    private var flipTimer: Timer?
    private var descript: String?
    private var phoneNumbers: String?
    public weak var delegate: ContactsFlipViewViewDelegate?
    private var viewModel: ContactsFlipViewViewModel?
    
    @IBAction func callNowViewPressed(_ sender: Any) {
        if let viewModel = self.viewModel {
            delegate?.didSelectFlipView(viewModel)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    private func configureView() {
        phoneImageView?.image = Assets.image(named: "icnCornerPhone3")
        titleLabel.font = .santander(family: .text, type: .regular, size: 20.0)
        titleLabel.textColor = .lisboaGray
        hoursLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        hoursLabel.textColor = .lisboaGray
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        containerView.layer.cornerRadius = 4.0
        
        phoneView.drawShadow(offset: (x: 0, y: 2), opacity: 0.05, color: UIColor.black, radius: 0.0)
        phoneView.drawBorder(cornerRadius: 5.0, color: UIColor.clear, width: 1.0)
        phoneView.layer.masksToBounds = false
    }
    
    public func setModel(viewModel: ContactsFlipViewViewModel) {
        self.viewModel = viewModel
        if let title = viewModel.title {
            titleLabel.text = title
        }
        
        if let description = viewModel.subtitle {
            hoursLabel.configureText(withLocalizedString: description)
        }
        
        iconImageView?.image = Assets.image(named: viewModel.icon)
        phoneImageView?.image = Assets.image(named: viewModel.phoneIcon)
        phoneNumbers = viewModel.phoneNumbers?.first
        setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        if let type = viewModel?.flipViewType {
            self.accessibilityIdentifier = "helpCenter_contactFlip_View_\(type)"
            phoneView.accessibilityIdentifier = "helpCenter_contactFlip_phoneView_\(type)"
            titleLabel.accessibilityIdentifier = "helpCenter_contactFlip_titleLabel_\(type)"
            hoursLabel.accessibilityIdentifier = "helpCenter_contactFlip_hoursLabel_\(type)"
            iconImageView.accessibilityIdentifier = "helpCenter_contactFlip_iconImage_\(type)"
            phoneImageView.accessibilityIdentifier = "helpCenter_contactFlip_phoneImage_\(type)"
        }
    }
}

extension ContactsFlipView: AccessibilityCapable { }
