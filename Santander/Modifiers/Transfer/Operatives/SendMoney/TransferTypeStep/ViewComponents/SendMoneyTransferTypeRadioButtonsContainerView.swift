//
//  SendMoneyTransferTypeRadioButtonsContainerView.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SendMoneyTransferTypeRadioButtonsContainerViewDelegate: AnyObject {
    func didSelectRadioButton(at index: Int)
    func didSelectOptionFromCostView(at index: Int)
    func didTapTooltip()
}

final class SendMoneyTransferTypeRadioButtonsContainerView: UIView {
    private enum Constants {
        static let defaultIndex: Int = .zero
        enum HorizontalStackView {
            static let spacing: CGFloat = 16.0
        }
        enum CommissionsSubtitle {
            enum Margins {
                static let top: CGFloat = -12.0
                static let leading: CGFloat = 31.0
                static let trailing: CGFloat = -65.0
                static let bottom: CGFloat = .zero
            }
            static let bottomSpace: CGFloat = 16.0
        }
        enum SeparatorView {
            static let height: CGFloat = 1.0
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: SendMoneyTransferTypeRadioButtonsContainerViewDelegate?
    private var selectedIndex: Int = Constants.defaultIndex
    private var view: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: SendMoneyTransferTypeRadioButtonsContainerViewModel) {
        guard !viewModel.viewModels.isEmpty else { return }
        self.stackView.removeAllArrangedSubviews()
        self.setViews(viewModel.viewModels)
        self.selectedIndex = viewModel.selectedIndex
        self.didSelectTransferType(at: self.selectedIndex)
    }
    
    func selectItem(at index: Int) {
        self.didSelectTransferType(at: index)
    }
}

private extension SendMoneyTransferTypeRadioButtonsContainerView {
    func setupView() {
        self.xibSetup()
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view ?? UIView())
        self.view?.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle.main)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setViews(_ viewModels: [SendMoneyTransferTypeRadioButtonViewModel]) {
        guard !viewModels.isEmpty else { return }
        self.addSeparatorView()
        for (index, viewModel) in viewModels.enumerated() {
            self.addRadioButton(viewModel, index: index, total: viewModels.count)
            self.addCommissionsSubtitleLabel(viewModel, index: index)
            self.addSeparatorView()
        }
    }
    
    func addRadioButton(_ viewModel: SendMoneyTransferTypeRadioButtonViewModel, index: Int, total: Int) {
        var subviews: [UIView] = []
        let viewModelWithPosition = self.setOneRadioButtonPosition(viewModel, (index + 1 , total))
        subviews.append(self.getOneRadioButton(viewModelWithPosition, index: index))
        if let feeViewModel = viewModel.feeViewModel {
            subviews.append(self.getFeeView(feeViewModel, index: index))
        }
        let horizontalStackView = self.getHorizontalStackView(with: subviews)
        self.stackView.addArrangedSubview(horizontalStackView)
    }
    
    func getHorizontalStackView(with subviews: [UIView]) -> UIStackView {
        let horizontalStackView = UIStackView(arrangedSubviews: subviews)
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .top
        horizontalStackView.spacing = Constants.HorizontalStackView.spacing
        return horizontalStackView
    }
    
    func getOneRadioButton(_ viewModel: OneRadioButtonViewModel, index: Int) -> OneRadioButtonView {
        let oneRadioButtonView = OneRadioButtonView()
        oneRadioButtonView.delegate = self
        if let bottomSheetView = viewModel.bottomSheetView as? SendMoneyTransferTypeCostView {
            bottomSheetView.setIndex(index: index)
            bottomSheetView.delegate = self
        }
        oneRadioButtonView.setViewModel(viewModel, index: index)
        return oneRadioButtonView
    }
    
    func getFeeView(_ viewModel: SendMoneyTransferTypeFeeViewModel, index: Int) -> SendMoneyTransferTypeFeeView {
        let feeView = SendMoneyTransferTypeFeeView()
        feeView.delegate = self
        feeView.setViewModel(viewModel, index: index)
        return feeView
    }
    
    func addCommissionsSubtitleLabel(_ viewModel: SendMoneyTransferTypeRadioButtonViewModel, index: Int) {
        guard viewModel.feeViewModel == nil else { return }
        let container = UIView()
        let tapGesture = CommissionsSubtitleTapGesture(target: self, action: #selector(didTapCommissionsSubtitle))
        tapGesture.index = index
        container.addGestureRecognizer(tapGesture)
        let commissionsSubtitleLabel = self.getCommissionsLabel(viewModel)
        container.addSubview(commissionsSubtitleLabel)
        NSLayoutConstraint.activate([
            commissionsSubtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                                              constant: Constants.CommissionsSubtitle.Margins.leading),
            commissionsSubtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                                                               constant: Constants.CommissionsSubtitle.Margins.trailing),
            commissionsSubtitleLabel.topAnchor.constraint(equalTo: container.topAnchor,
                                                          constant: Constants.CommissionsSubtitle.Margins.top),
            commissionsSubtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                                                             constant: Constants.CommissionsSubtitle.Margins.bottom)
        ])
        self.stackView.addArrangedSubview(container)
        self.addSpacingView(spacing: Constants.CommissionsSubtitle.bottomSpace)
    }
    
    func getCommissionsLabel(_ viewModel: SendMoneyTransferTypeRadioButtonViewModel) -> UILabel {
        let commissionsSubtitleLabel = UILabel()
        commissionsSubtitleLabel.numberOfLines = 0
        commissionsSubtitleLabel.font = .typography(fontName: .oneB100Regular)
        commissionsSubtitleLabel.textColor = .oneLisboaGray
        commissionsSubtitleLabel.configureText(withKey: viewModel.commissionsInfoKey ?? "")
        commissionsSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        commissionsSubtitleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        commissionsSubtitleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonComission + (viewModel.accessibilitySuffix ?? "")
        return commissionsSubtitleLabel
    }
    
    @objc func didTapCommissionsSubtitle(recognizer: CommissionsSubtitleTapGesture) {
        self.didSelectTransferType(at: recognizer.index)
    }
    
    func addSeparatorView() {
        let separatorView = UIView()
        separatorView.backgroundColor = .oneMediumSkyGray
        separatorView.heightAnchor.constraint(equalToConstant: Constants.SeparatorView.height).isActive = true
        self.stackView.addArrangedSubview(separatorView)
    }
    
    func addSpacingView(spacing: CGFloat) {
        let spacingView = UIView()
        spacingView.backgroundColor = .clear
        spacingView.heightAnchor.constraint(equalToConstant: spacing).isActive = true
        self.stackView.addArrangedSubview(spacingView)
    }
    
    func changeViewsStatus() {
        self.stackView.subviews.forEach {
            guard let horizontalStackView = $0 as? UIStackView else { return }
            horizontalStackView.subviews.forEach {
                self.setOneRadioButtonStatus($0)
                self.setFeeViewStatus($0)
            }
        }
    }
    
    func setOneRadioButtonStatus(_ view: UIView) {
        guard let view = view as? OneRadioButtonView,
              view.getStatus() != .disabled else { return }
        view.setByStatus(view.index == self.selectedIndex ? .activated : .inactive)
    }
    
    func setFeeViewStatus(_ view: UIView) {
        guard let view = view as? SendMoneyTransferTypeFeeView else { return }
        view.changeStatus(to: view.index == self.selectedIndex ? .activated : .inactive)
    }
    
    func didSelectTransferType(at index: Int) {
        guard index >= .zero else { return }
        self.selectedIndex = index
        self.changeViewsStatus()
        self.delegate?.didSelectRadioButton(at: index)
    }
    
    func setOneRadioButtonPosition(_ viewModel: SendMoneyTransferTypeRadioButtonViewModel,
                                   _ position: (Int, Int)) -> OneRadioButtonViewModel {
        let viewModelWithiPosition = viewModel
        viewModelWithiPosition.oneRadioButtonViewModel.titleAccessibilityLabel = localized(viewModel.oneRadioButtonViewModel.titleAccessibilityLabel ?? "",
                                                                                           [StringPlaceholder(.number, "\(position.0)"),
                                                                                            StringPlaceholder(.number, "\(position.1)")]).text
        return viewModelWithiPosition.oneRadioButtonViewModel
    }
}

extension SendMoneyTransferTypeRadioButtonsContainerView: OneRadioButtonViewDelegate {
    public func didSelectOneRadioButton(_ index: Int) {
        self.didSelectTransferType(at: index)
    }
    
    public func didTapTooltip() {
        self.delegate?.didTapTooltip()
    }
}

extension SendMoneyTransferTypeRadioButtonsContainerView: SendMoneyTransferTypeFeeViewDelegate {
    func didSelectFeeView(at index: Int) {
        self.didSelectTransferType(at: index)
    }
}

extension SendMoneyTransferTypeRadioButtonsContainerView: SendMoneyTransferTypeCostViewDelegate {
    func didTapSelectOptionButton(at index: Int) {
        self.delegate?.didSelectOptionFromCostView(at: index)
    }
}

fileprivate class CommissionsSubtitleTapGesture: UITapGestureRecognizer {
    var index: Int = 0
}
