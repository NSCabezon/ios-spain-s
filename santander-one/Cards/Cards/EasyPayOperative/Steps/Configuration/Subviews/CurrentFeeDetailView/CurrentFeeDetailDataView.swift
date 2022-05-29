//
//  CurrentFeeDetailDataView.swift
//  Cards
//
//  Created by Luis Escámez Sánchez on 04/12/2020.
//

import UI
import CoreFoundationLib

final class CurrentFeeDetailDataView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var dataLabel: UILabel!
    private var tooltipInfo = TooltipInfo()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setupView()
    }
    
    func setInfo(titletext: String, dataText: String?, tooltipText: String? = nil) {
        titleLabel.text = titletext
        dataLabel.text = dataText
        configureTooltipIfNeeeded(tooltipText)
    }
    
    func setFonts(titleSize: CGFloat, dataSize: CGFloat) {
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: titleSize)
        dataLabel.font = UIFont.santander(family: .text, type: .bold, size: dataSize)
    }
    
    func setAccesibilityIds(title: String, description: String) {
        titleLabel.accessibilityIdentifier = title
        dataLabel.accessibilityIdentifier = description
        tooltipInfo.accesibilityId = title + "_tooltipButton"
    }
}

// MARK: - Private Methods
private extension CurrentFeeDetailDataView {
    
    func setupView() {
        titleLabel.textColor = .grafite
        dataLabel.textColor = .lisboaGray
    }
    
    func configureTooltipIfNeeeded(_ tooltipText: String?) {
        guard let text = tooltipText else { tooltipImageView.isHidden = true
            return
        }
        self.tooltipInfo.text = text
        tooltipImageView.isHidden = false
        tooltipImageView.image = Assets.image(named: "icnInfoRedLight")
        tooltipImageView.isAccessibilityElement = true
        tooltipImageView.isUserInteractionEnabled = true
        tooltipImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTooltip)))
    }
    
    @objc func showTooltip() {
        guard tooltipInfo.text != "" else { return }
        BubbleLabelView.startWith(associated: tooltipImageView, text: tooltipInfo.text, position: .bottom, configuration: .defaultConfiguration())
    }
}

private struct TooltipInfo {
    var text: String = ""
    var accesibilityId: String = ""
}
