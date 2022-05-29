//
//  GlobalSearchEmptyView.swift
//  GlobalSearch
//
//  Created by alvola on 05/03/2020.
//

import CoreFoundationLib

public struct LabelAttributes {
    let localizedText: LocalizedStylableText
    let font: UIFont
    let textColor: UIColor
    public init(localizedText: LocalizedStylableText, font: UIFont, textColor: UIColor ) {
        self.localizedText = localizedText
        self.font = font
        self.textColor = textColor
    }
}

public protocol SearchEmptyViewDelegate: AnyObject {
    func maybeYouWantedToSayAction()
    func touchAction()
}

final public class SearchEmptyView: UIView {
    
    public weak var delegate: SearchEmptyViewDelegate?
    private var titleTopConstraint: NSLayoutConstraint?
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.touchAction()
    }
    
    public var searchTerm = "" {
        didSet {
            titleLabel.configureText(withLocalizedString: localized("globalSearch_title_empty",
                                                                    [StringPlaceholder(.value, searchTerm)]))
        }
    }
    
    public func updateSuggestedSearchTermWith(_ term: String?) {
        guard let term = term else { return }
        maybeYouWantedToSayView.isHidden = term.isEmpty
        maybeYouWantedToSayView.updateTitle(term)
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: Assets.image(named: "imgLeaves"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var maybeYouWantedToSayView: MaybeYouWantedToSayView = {
        let view = MaybeYouWantedToSayView()
        view.drawRoundedAndShadowedNew(radius: 4.0, borderColor: UIColor.mediumSkyGray)
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

public extension SearchEmptyView {
    func configureAttributes(_ title: LabelAttributes) {
        self.titleLabel.font = title.font
        self.titleLabel.textColor = title.textColor
        self.titleLabel.configureText(withLocalizedString: title.localizedText)
    }
    
    func configureSingleTitle(_ title: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: title)
    }
}

private extension SearchEmptyView {
    func commonInit() {
        backgroundColor = .white
        isUserInteractionEnabled = true
        heightAnchor.constraint(equalToConstant: 210.0).isActive = true
        addSubview(imageView)
        imageView.fullFit()
        
        addSubview(titleLabel)
        titleTopConstraint = titleLabel.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: 44.0)
        titleTopConstraint?.isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20.0).isActive = true
        titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor).isActive = true
        addSubview(maybeYouWantedToSayView)
        maybeYouWantedToSayView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        maybeYouWantedToSayView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        self.trailingAnchor.constraint(equalTo: maybeYouWantedToSayView.trailingAnchor, constant: 20.0).isActive = true
        maybeYouWantedToSayView.heightAnchor.constraint(greaterThanOrEqualToConstant: 42).isActive = true
        maybeYouWantedToSayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maybeYouWantedToSayViewAction)))
        defaultAttributes()
    }
    
    func defaultAttributes() {
        self.configureAttributes(LabelAttributes(localizedText: .empty,
                                                 font: UIFont.santander(family: .headline, size: 20.0),
                                                 textColor: .lisboaGray))
    }
    
    @objc func maybeYouWantedToSayViewAction() {
        delegate?.maybeYouWantedToSayAction()
    }
}

fileprivate final class MaybeYouWantedToSayView: UIView {
    
    private let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        addSubview(title)
        title.textAlignment = .center
        title.font = UIFont.santander(family: .text, type: .regular, size: 16)
        title.textColor = UIColor.lisboaGray
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.fullFit()
    }
    
    func updateTitle(_ title: String) {
        self.title.configureText(withLocalizedString: localized("globalSearch_button_wantedSay",
                                                                [StringPlaceholder(.value, title)]))
    }
}
