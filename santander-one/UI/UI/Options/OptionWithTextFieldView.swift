//
//  CardBlockReasonView.swift
//  UI
//
//  Created by Iván Estévez Nieto on 27/5/21.
//

import Foundation

public protocol OptionWithTextFieldViewDelegate: AnyObject {
    func didTapOnView(_ view: OptionWithTextFieldView)
    func textFieldUpdated(text: String, view: OptionWithTextFieldView)
}

public final class OptionWithTextFieldView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var selectedView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var expandableStackView: UIStackView!
    private var isSelected: Bool = false {
        didSet {
            self.changeAppearance()
        }
    }
    private var expandableModel: OptionWithTextFieldReasonViewModel?
    private let reasonView = OptionWithTextFieldReasonView()
    private weak var delegate: OptionWithTextFieldViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setDelegate(_ delegate: OptionWithTextFieldViewDelegate) {
        self.delegate = delegate
    }
    
    public func setViewModel(_ viewModel: OptionWithTextFieldViewModel) {
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
        if let expandable = viewModel.expandable {
            self.expandableModel = expandable
            self.reasonView.setViewModel(expandable)
            self.reasonView.setDelegate(self)
        }
    }
    
    public func selectView() {
        self.isSelected = true
    }
    
    public func deselectView() {
        self.isSelected = false
    }
}

private extension OptionWithTextFieldView {
    func setAppearance() {
        self.setupViews()
        self.setupLabels()
    }
    
    func setupViews() {
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.borderColor = UIColor.silverLight.cgColor
        self.containerView.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.containerView.layer.shadowOpacity = 0.7
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.containerView.layer.shadowRadius = 5
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewDidPressed)))
        self.expandableStackView.isHidden = true
        self.expandableStackView.addArrangedSubview(reasonView)
        self.selectedView.roundCorners(corners: .allCorners, radius: 5)
    }
    
    func setupLabels() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.titleLabel.textColor = .lisboaGray
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.subtitleLabel.textColor = .lisboaGray
    }
    
    @objc func viewDidPressed() {
        guard !isSelected else { return }
        self.delegate?.didTapOnView(self)
    }
    
    @objc func changeAppearance() {
        self.selectedView.backgroundColor = isSelected ? .darkTorquoise : .white
        self.titleLabel.textColor = isSelected ? .white : .lisboaGray
        self.subtitleLabel.textColor = isSelected ? .white : .lisboaGray
        self.selectedView.roundCorners(corners: .allCorners, radius: 5)
        self.expandViewIfNeeded()
    }
    
    func expandViewIfNeeded() {
        if expandableModel != nil {
            self.selectedView.roundCorners(corners: [.topLeft, .topRight], radius: 5)
            self.animateExpandableStackView()
        }
    }
    
    func animateExpandableStackView() {
        self.view?.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            if self.isSelected {
                self.expandableStackView.isHidden = false
            } else if !self.expandableStackView.isHidden {
                self.expandableStackView.isHidden = true
            }
            self.view?.layoutIfNeeded()
        }
    }
}

extension OptionWithTextFieldView: OptionWithTextFieldReasonViewDelegate {
    func textFieldUpdated(text: String) {
        self.delegate?.textFieldUpdated(text: text, view: self)
    }
}
