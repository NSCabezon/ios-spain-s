import UIKit
import UI
import CoreFoundationLib
import UIOneComponents
import OpenCombine

class SavingsCollectionViewDetailsView: UIView {
    let detailTitleLabel: UILabel = UILabel()
    let toolTipIcon: UIImageView = UIImageView()
    let detailValueLabel: UILabel = UILabel()
    var detailValueLabelTapAction: (() -> Void)?
    let loaderPendingView: UIImageView = UIImageView()
    var isPending = false
    let toolTipIconTappedSubject = PassthroughSubject<Void, Never>()

    init(detailTitleLabelText: String, detailValueLabelText: String, isPending: Bool = false, detailValueLabelFont: UIFont = UIFont.typography(fontName: .oneB300Regular), detailValueLabelFontColor: UIColor = .brownishGray, withToolTip: Bool = false) {
        self.isPending = isPending
        super.init(frame: .zero)
        self.configureView(detailTitleLabelText: detailTitleLabelText, detailValueLabelText: detailValueLabelText, detailValueLabelfont: detailValueLabelFont, detailValueLabelFontColor: detailValueLabelFontColor, withToolTip: withToolTip)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SavingsCollectionViewDetailsView {
    func configureDetailLabel(detailTitleLabelText: String) {
        self.addSubview(detailTitleLabel)
        detailTitleLabel.text = localized(detailTitleLabelText)
        detailTitleLabel.scaledFont = UIFont.santander(family: .micro, type: .regular, size: 14)
        detailTitleLabel.textAlignment = .left
        detailTitleLabel.numberOfLines = 1
        detailTitleLabel.textColor = .brownishGray
        self.setDetailTitleLabelConstraints()
    }

    func configureToolTip() {
        addSubview(toolTipIcon)
        toolTipIcon.image = Assets.image(named: "oneIcnHelp")
        toolTipIcon.accessibilityIdentifier = "toolTipIconBtn"
        setToolTipImageConstraints()
        setupInterestRateToolTipTap()
    }
    
    func configureValueLabel(detailValueLabelText: String, font: UIFont, fontColor: UIColor) {
        self.addSubview(detailValueLabel)
        detailValueLabel.text = detailValueLabelText
        detailValueLabel.scaledFont = font
        detailValueLabel.textAlignment = .left
        detailValueLabel.numberOfLines = 1
        detailValueLabel.textColor = fontColor
        self.setValueTitleLabelConstraints()
        self.setupLabelTap(label: detailValueLabel)
    }
    
    func setDetailTitleLabelConstraints() {
        detailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTitleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        detailTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        detailTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        detailTitleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func setToolTipImageConstraints() {
        toolTipIcon.translatesAutoresizingMaskIntoConstraints = false
        toolTipIcon.leadingAnchor.constraint(equalTo: detailTitleLabel.trailingAnchor, constant: 6).isActive = true
        toolTipIcon.heightAnchor.constraint(equalToConstant: 17).isActive = true
        toolTipIcon.widthAnchor.constraint(equalToConstant: 17).isActive = true
        toolTipIcon.centerYAnchor.constraint(equalTo: detailTitleLabel.centerYAnchor).isActive = true
    }
    
    func setValueTitleLabelConstraints() {
        detailValueLabel.translatesAutoresizingMaskIntoConstraints = false
        detailValueLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        detailValueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        detailValueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        detailValueLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func setLoaderPendingView() {
        if isPending {
            self.addSubview(loaderPendingView)
            loaderPendingView.setNewJumpingLoader()
            loaderPendingViewConstraints()
        }
    }
    
    func loaderPendingViewConstraints() {
        loaderPendingView.translatesAutoresizingMaskIntoConstraints = false
        loaderPendingView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        loaderPendingView.trailingAnchor.constraint(equalTo: detailValueLabel.leadingAnchor, constant: 10).isActive = true
        loaderPendingView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        loaderPendingView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        loaderPendingView.widthAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func configureView(detailTitleLabelText: String, detailValueLabelText: String, detailValueLabelfont: UIFont, detailValueLabelFontColor: UIColor, withToolTip: Bool) {
        self.configureDetailLabel(detailTitleLabelText: detailTitleLabelText)
        if withToolTip {
            configureToolTip()
        }
        self.configureValueLabel(detailValueLabelText: detailValueLabelText, font: detailValueLabelfont, fontColor: detailValueLabelFontColor)
        self.setLoaderPendingView()
    }

    func setupLabelTap(label: UILabel) {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(labelTap)
    }

    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        detailValueLabelTapAction?()
    }

    func setupInterestRateToolTipTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toolTipIconTapped))
        toolTipIcon.isUserInteractionEnabled = true
        toolTipIcon.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func toolTipIconTapped() {
        toolTipIconTappedSubject.send()
    }
}
