//
//  GlobileSlider.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

enum GlobileSliderColor {
    case red
    case turquoise
}

protocol GlobileSliderDelegate: class {
    func globileSlider(_ slider: GlobileSlider, didChange minimumValue: Float, maximumValue: Float)
}

class GlobileSlider: UIView {

    // MARK: - Public properties
    
    /// The object that acts as the delegate for the slider.
    weak var delegate: GlobileSliderDelegate?

    /// The tint color to apply to the slider's track line and thumbs.
    var color: GlobileSliderColor = .red {
        didSet {
            switch color {
            case .red:
                slider.colorBetweenHandles = .sanRed
                slider.handleImage = UIImage(fromModuleWithName: "thumb_red")
            case .turquoise:
                slider.colorBetweenHandles = .turquoise
                slider.handleImage = UIImage(fromModuleWithName: "thumb_turquoise")
            }
        }
    }
    
    /// The minimum value of the slider.
    var minimumValue: Float {
        get {
            return Float(slider.minValue)
        }
        set {
            slider.minValue = CGFloat(newValue)
        }
    }
    
    /// The maximum value of the slider.
    var maximumValue: Float {
        get {
            return Float(slider.maxValue)
        }
        set {
            slider.maxValue = CGFloat(newValue)
        }
    }
    
    /// The selected minimum value.
    var selectedMinimumValue: Float {
        get {
            return Float(slider.selectedMinValue)
        }
        set {
            slider.selectedMinValue = CGFloat(newValue)
        }
    }
    
    /// The selected maximum value.
    var selectedMaximumValue: Float {
        get {
            return Float(slider.selectedMaxValue)
        }
        set {
            slider.selectedMaxValue = CGFloat(newValue)
        }
    }
    
    /// A Boolean value indicating whether changes in the slider's value generate continuous update events.
    var isContinuous: Bool {
        get {
            return !slider.enableStep
        }
        set {
            slider.enableStep = !newValue
        }
    }
    
    // The step value when the slider is not continous. The default value is 0.
    var step: Float {
        get {
            return Float(slider.step)
        }
        set {
            slider.step = CGFloat(newValue)
        }
    }
    
    /// A Boolean value indicating whether the slider is a range. When set to false, use the selectedMaximumValue to get the current selected value. The default value is false.
    var isRangeable: Bool {
        get {
            return !slider.disableRange
        }
        set {
            slider.disableRange = !newValue
        }
    }
    
    /// The current text that is displayed by the minimum label.
    var minimumText: String? {
        didSet {
            minLabel.text = minimumText
        }
    }
    
    /// The current text that is displayed by the maximum label.
    var maximumText: String? {
        didSet {
            maxLabel.text = maximumText
        }
    }

    // MARK: - View components
    
    private var slider: RangeSlider = {
        let slider = RangeSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.hideLabels = true
        slider.labelsFixed = true
        slider.lineHeight = 3.0
        slider.selectedHandleDiameterMultiplier = 1.0
        slider.tintColor = .lightGray
        return slider
    }()
    
    private var minLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .santanderText(type: .regular, with: 16)
        label.textColor = .mediumSanGray
        label.text = "0€"
        return label
    }()
    
    private var maxLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .right
        label.font = .santanderText(type: .regular, with: 16)
        label.textColor = .mediumSanGray
        label.text = "5€"
        return label
    }()
    
    // MARK: - Intializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }
    
    // MARK: - Private
    
    private func addSubviews() {
        addSubview(slider)
        addSubview(minLabel)
        addSubview(maxLabel)
        
        setupLayout()
        setupView()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: topAnchor),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            minLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: -4.0),
            minLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            minLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0)
        ])
        
        NSLayoutConstraint.activate([
            maxLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: -4.0),
            maxLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            maxLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0)
        ])
    }
    
    private func setupView() {
        color = .red
        isRangeable = false
        slider.delegate = self
    }
    
}

extension GlobileSlider: RangeSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        delegate?.globileSlider(self, didChange: Float(minValue), maximumValue: Float(maxValue))
    }
}
