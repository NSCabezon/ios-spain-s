//
//  OneToastView.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 29/3/22.
//

import UI
import CoreFoundationLib
import OpenCombine

public enum ReactiveOneToastViewState: State {
    case didPresent(_ view: OneToastView)
    case didDismiss(_ view: OneToastView)
    case didPressOptionalLink(_ view: OneToastView)
}

public protocol ReactiveOneToastView {
    var publisher: AnyPublisher<ReactiveOneToastViewState, Never> { get }
}

public final class OneToastView: XibView {
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var leftImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var bottomLink: OneAppLink!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var optionalLinkContainer: UIView!
    
    private let stateSubject = PassthroughSubject<ReactiveOneToastViewState, Never>()
    private var bottomConstraint: NSLayoutConstraint?
    private var viewModel: OneToastViewModel? {
        didSet {
            self.setLeftIconImage()
            self.setLabelTexts()
            self.setBottomLink()
            self.setAppearance()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setViewModel(_ viewModel: OneToastViewModel) {
        self.viewModel = viewModel
    }
    
    public func present() {
        self.setConstraints()
        self.bottomConstraint?.constant = viewModel?.position == .top ? frame.height : -frame.height
        self.setNeedsLayout()
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: .zero,
                       options: .curveEaseOut,
                       animations: { [weak self] in
            self?.superview?.layoutIfNeeded()
        },
                       completion: { [weak self] _ in
            guard let self = self else { return }
            self.stateSubject.send(.didPresent(self))
            self.setTimerToDismiss()
        })
    }
    
    public func dismiss() {
        self.bottomConstraint?.constant = .zero
        self.setNeedsLayout()
        UIView.animate(withDuration: Constants.animationDuration,
                       animations: { [weak self] in
            self?.superview?.layoutIfNeeded()
        },
                       completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
            self.stateSubject.send(.didDismiss(self))
        })
    }
}

private extension OneToastView {
    enum Constants {
        static let animationDuration: TimeInterval = 0.3
        enum CloseButton {
            static let text: String = ""
            static let image: String = "oneIcnClose"
        }
    }
    
    func configureView() {
        self.configureLabels()
        self.configureCloseButton()
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.font = .typography(fontName: .oneB300Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
    }
    
    func configureCloseButton() {
        self.closeButton.setImage(Assets.image(named: Constants.CloseButton.image)?.withRenderingMode(.alwaysTemplate).tinted(WithColor: .oneLisboaGray, scale: .zero), for: .normal)
        self.closeButton.setTitle(Constants.CloseButton.text, for: .normal)
        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    func setLeftIconImage() {
        guard let viewModel = viewModel else { return }
        self.leftImageView.image = Assets.image(named: viewModel.leftIconKey)
    }
    
    func setLabelTexts() {
        guard let viewModel = viewModel else { return }
        self.titleLabel.text = localized(viewModel.titleKey ?? "")
        self.subtitleLabel.text = localized(viewModel.subtitleKey)
    }
    
    func setBottomLink() {
        guard let viewModel = self.viewModel else { return }
        self.bottomLink.configureButton(type: .primary,
                                        style: OneAppLink.ButtonContent(text: viewModel.linkKey ?? "",
                                                                        icons: .none))
        self.bottomLink.setAlignment(.left)
        self.bottomLink.addTarget(self, action: #selector(didTapBottomLink), for: .touchUpInside)
    }
    
    func setAppearance() {
        guard let viewModel = self.viewModel else { return }
        self.titleLabel.isHidden = viewModel.type.isTitleHidden
        self.leftImageHeightConstraint.constant = viewModel.type.leftIconHeight
        self.optionalLinkContainer.isHidden = viewModel.linkKey?.isEmpty ?? true
        self.setOneShadows(type: viewModel.position == .top ? .oneShadowLargeBottom : .oneShadowLargeTop)
    }
    
    func setConstraints() {
        guard let superView = self.superview ?? UIApplication.shared.windows.first,
              let viewModel = self.viewModel else { return }
        superView.addSubview(self)
        self.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: superView.widthAnchor).isActive = true
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: viewModel.position == .top ? .bottom : .top, relatedBy: .equal, toItem: superView, attribute: viewModel.position == .top ? .top : .bottom, multiplier: 1.0, constant: .zero)
        self.bottomConstraint = bottomConstraint
        superView.addConstraint(bottomConstraint)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        superView.layoutSubviews()
        self.superview?.layoutIfNeeded()
    }
    
    func setTimerToDismiss() {
        guard let duration = self.viewModel?.duration,
              case .custom(let interval) = duration  else { return }
        Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] in
            $0.invalidate()
            self?.dismiss()
        }
    }
    
    @objc func didTapCloseButton() {
        self.dismiss()
    }
    
    @objc func didTapBottomLink() {
        self.stateSubject.send(.didPressOptionalLink(self))
    }
}

extension OneToastView: ReactiveOneToastView {
    public var publisher: AnyPublisher<ReactiveOneToastViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
