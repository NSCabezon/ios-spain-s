import UIKit
import CoreFoundationLib

public protocol GlobalSearchActionViewDelegate: AnyObject {
    func didSeletSearchAction(_ identifier: String?, type: GlobalSearchActionViewType)
}

public final class GlobalSearchActionView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    public weak var delegate: GlobalSearchActionViewDelegate?
    private let accIdenfier: String = "GlogalSearchListActions"
    public var isEmpty: Bool {
        return self.stackView.arrangedSubviews.isEmpty
    }
    private let heightForHeaderSection: CGFloat = 51.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupVieModels(_ viewModels: [GlobalSearchActionViewModel]?) {
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        guard let viewModelsUnwrapped = viewModels, viewModelsUnwrapped.count > 0 else { return }
         addHeader(num: viewModelsUnwrapped.count)
        for (index, viewModel) in viewModelsUnwrapped.enumerated() {
            self.add(viewModel, accessibilityIdentifier: "\(self.accIdenfier)\(index)")
        }
    }
}

private extension GlobalSearchActionView {
    func setupView() {
        self.accessibilityIdentifier = self.accIdenfier
    }
    
    func add(_ viewModel: GlobalSearchActionViewModel, accessibilityIdentifier: String) {
        let actionView = GlobalSearchActionItemView()
        actionView.configure(viewModel, accessibilityIdentifier: accessibilityIdentifier, action: { [weak self] identifier in
            self?.delegate?.didSeletSearchAction(identifier, type: viewModel.type)
        })
        self.stackView.addArrangedSubview(actionView)
    }
    
    func addHeader(num: Int) {
        let header = GlobalSearchHeaderSectionView(headerTitle: localized("search_title_actions", [StringPlaceholder(.number, String(num))]))
        stackView.addArrangedSubview(header)
        header.heightAnchor.constraint(equalToConstant: heightForHeaderSection).isActive = true
        header.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
}

final class GlobalSearchActionItemView: XibView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    private var tapAction: ((String?) -> Void)?
    private var identifier: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(_ viewModel: GlobalSearchActionViewModel, accessibilityIdentifier: String, action: @escaping (String?) -> Void) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        if viewModel.isHighlighted() {
            self.titleLabel.attributedText = viewModel.highlight(self.titleLabel.attributedText)
        }
        self.iconImageView.loadImage(urlString: viewModel.iconName)
        self.tapAction = action
        self.identifier = viewModel.identifier
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

private extension GlobalSearchActionItemView {
    func setupView() {
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 4.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowColor = UIColor.atmsShadowGray.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.masksToBounds = false
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .regular, size: 16.0)
    }
    
    @IBAction func didTap() {
        self.tapAction?(self.identifier)
    }
}
