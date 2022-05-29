import UIKit
import UI

class SliderStackView: StackItemView {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var minimumLabel: UILabel!
    @IBOutlet weak var maximumLabel: UILabel!
    
    var didChangeValue: ((_ value: Float) -> Void)?
    lazy var setNewValue: ((Float) -> Void) = { [weak self] value in
        self?.slider.value = value
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        slider.setThumbImage(Assets.image(named: "handle"), for: .normal)
        slider.minimumTrackTintColor = .topaz
        slider.maximumTrackTintColor = .lisboaGray
        slider.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
        minimumLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        maximumLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
    }
    
    func setMinimumText(_ text: LocalizedStylableText?) {
        minimumLabel.isHidden = text == nil
        guard let text = text else { return }
        minimumLabel.set(localizedStylableText: text)
    }
    
    func setMaximumText(_ text: LocalizedStylableText?) {
        maximumLabel.isHidden = text == nil
        guard let text = text else { return }
        maximumLabel.set(localizedStylableText: text)
    }
    
    func setMinimumValue(_ value: Float) {
        slider.minimumValue = value
    }

    func setMaximumValue(_ value: Float) {
        slider.maximumValue = value
    }

    @objc func sliderValueDidChange(sender: UISlider) {
        didChangeValue?(sender.value)
    }    
    
    func setAccessibilityIdentifiers(identifier: String) {
        slider.accessibilityIdentifier = "slider_" + identifier
        minimumLabel.accessibilityIdentifier = "minLabelSlider_" + identifier
        maximumLabel.accessibilityIdentifier = "macLabelSlider_" + identifier
    }
}
