import UI
import CoreFoundationLib
import IQKeyboardManagerSwift

final class LoanSimulatorViewBuilder {
    
    static func createSimulatorView(viewModel: LoanSimulatorViewModel,
                                    resolver: DependenciesResolver,
                                    delegate: LoanSimulatorViewDelegateProtocol) -> LoanSimulatorView {

        let presenter = LoanSimulatorPresenter(dependenciesResolver: resolver,
                                               simulatorViewModel: viewModel)
        let simulatorView = LoanSimulatorView(frame: .zero,
                                              presenter: presenter)
        simulatorView.translatesAutoresizingMaskIntoConstraints = false
        simulatorView.delegate = delegate
        presenter.view = simulatorView
        
        return simulatorView
    }
}

protocol LoanSimulatorViewProtocol: AnyObject {
    var state: LoanSimulatorViewState { get set }
    func updateDataWith(_ viewModel: LoanSimulatorViewModel)
    func showErrorWith(text: String, animated: Bool, showingTime: Float)
}

protocol LoanSimulatorViewDelegateProtocol: AnyObject {
    func sliderDidStart()
    func sliderDidFinish()
}

enum LoanSimulatorViewState {
    case data, loading, error
}

final class LoanSimulatorView: UIView {
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var amountTitleLabel: UILabel!
    @IBOutlet private weak var amountTextField: LisboaTextfield!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var minimumValueLabel: UILabel!
    @IBOutlet private weak var maximumValueLabel: UILabel!
    @IBOutlet private weak var circularSlider: CircularSlider!
    @IBOutlet private weak var openingCommissionLabel: UILabel!
    @IBOutlet private weak var tinLabel: UILabel!
    @IBOutlet private weak var taeLabel: UILabel!
    @IBOutlet private weak var moreinfoLabel: UILabel!
    @IBOutlet private weak var monthlyFeeValueLabel: UILabel!
    @IBOutlet private weak var monthlyFeeTitleLabel: UILabel!
    @IBOutlet private weak var monthsLabel: UILabel!
    @IBOutlet private weak var monthsValueTextField: UITextField!
    @IBOutlet private weak var headerView: RoundedView!
    @IBOutlet private weak var moreInfoImageView: UIImageView!
    @IBOutlet private weak var favoriteIconImageView: UIImageView!
    @IBOutlet private weak var tooltipButton: UIButton!
    @IBOutlet private weak var moreInfoContainerView: UIView!
    
    weak var delegate: LoanSimulatorViewDelegateProtocol?
    
    private let style = LoanSimulatorStyle()
    private let amountTextFieldFormatter = UIAmountTextFieldFormatter(maximumFractionDigits: 0)
    
    var viewModel: LoanSimulatorViewModel? 
    
    private var loader: BallsLoaderView?
    private var errorView: LoanSimulatorErrorView?
    private var errorViewTopconstraint: NSLayoutConstraint?
    
    private let presenter: LoanSimulatorPresenterProtocol?
    
    var state: LoanSimulatorViewState = .data {
        didSet {
            switch state {
            case .data:
                hideLoader()
            case .loading:
                hideError()
                showLoader()
            case .error:
                hideLoader()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        presenter = nil
        super.init(coder: aDecoder)
        xibSetup()
        setup()
    }
    
    override init(frame: CGRect) {
        presenter = nil
        super.init(frame: frame)
        xibSetup()
        setup()
    }
    
    init(frame: CGRect, presenter: LoanSimulatorPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: frame)
        xibSetup()
        setup()
    }
        
    private func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: LoanSimulatorView.self)
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
     private func setup() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hiddeKeyboard))
        gesture.cancelsTouchesInView = false
        addGestureRecognizer(gesture)
        reset()
        configureStyle()
        configureCircularSlider()
    }
    
    @objc private  func hiddeKeyboard() {
        endEditing(true)
    }
    
    private func configureStyle() {
        
        backgroundView.drawRoundedAndShadowedNew(borderColor: .mediumSkyGray)
        
        headerView.frameBackgroundColor = style.headerBackgroundColor.cgColor
        headerView.backgroundColor = .clear
        headerView.roundTopCorners()
        
        headerLabel.font = UIFont.santander(family: .text, size: 20.0)
        headerLabel.configureText(withKey: "simulator_title_project")
        
        // labels
        amountTitleLabel.font = style.amountTitleFont
        amountTitleLabel.textColor = style.amountTitleColor
        
        minimumValueLabel.font = style.minimumValueFont
        minimumValueLabel.textColor = style.minimumValueColor
        
        maximumValueLabel.font = style.maximumValueFont
        maximumValueLabel.textColor = style.maximumValueColor
        maximumValueLabel.textAlignment = style.maximunValueAligment
        
        monthlyFeeTitleLabel.textColor = style.monthlyFeeColor
        monthlyFeeTitleLabel.numberOfLines = 2
        
        monthlyFeeValueLabel.font = style.monthlyFeeValueFont
        monthlyFeeValueLabel.textColor = style.monthlyFeeValueColor
        monthlyFeeValueLabel.adjustsFontSizeToFitWidth = true
        
        monthsLabel.font = style.monthsFont
        monthsLabel.textColor = style.monthsColor
        
        openingCommissionLabel.font = style.openingCommissionFont
        openingCommissionLabel.textColor = style.openingComissionColor
        
        tinLabel.font = style.TINFont
        tinLabel.textColor = style.TINColor
        
        taeLabel.font = style.TAEFont
        taeLabel.textColor = style.TAEColor
        
        moreinfoLabel.font = style.moreInfoFont
        moreinfoLabel.textColor = style.moreInfoColor
        moreInfoContainerView.isUserInteractionEnabled = true
        moreInfoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action: #selector(moreInfoAction)))
        moreInfoContainerView.backgroundColor = .clear
        
        monthsValueTextField.font = style.monthsValuefont
        monthsValueTextField.textColor = style.monthsValueColor
        monthsValueTextField.tintColor = style.monthsValueColor
        monthsValueTextField.backgroundColor = style.textFieldBackgroundColor
        monthsValueTextField.borderStyle = .none
        monthsValueTextField.keyboardType = .numberPad
        
        monthsValueTextField.addTarget(self, action: #selector(monthsTextFieldDidChange),
                                             for: UIControl.Event.editingChanged)
        var lisboaTextFieldStyle = LisboaTextFieldStyle.default
        lisboaTextFieldStyle.fieldFont = style.amountValueFont
        lisboaTextFieldStyle.verticalSeparatorBackgroundColor = style.circularSliderFilledColor
        let icnCurrency = NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn()
        amountTextField.configure(with: amountTextFieldFormatter,
                                  title: "",
                                  style: lisboaTextFieldStyle,
                                  extraInfo: (image: Assets.image(named: icnCurrency), action: nil))
        amountTextField.field.keyboardType = .numberPad
        amountTextField.field.addTarget(self, action: #selector(textFieldDidChange),
                                        for: UIControl.Event.editingChanged)
        amountTextField.field.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)),
                                        for: UIControl.Event.editingDidBegin)
        amountTextField.field.addTarget(self, action: #selector(textFieldDidEndEditing(_:)),
                                        for: UIControl.Event.editingDidEnd)
        amountTextField.field.adjustsFontSizeToFitWidth = true
        configureField(amountTextField.field)
        configureField(monthsValueTextField)
        
        monthsValueTextField.delegate = amountTextFieldFormatter
        
        // sliders
        circularSlider.labelFont = style.circularSliderLabelFont
        circularSlider.labelColor = style.circularSliderLabelColor
    
        slider.minimumTrackTintColor = style.sliderMinimumTrackTintColor
        slider.maximumTrackTintColor = style.sliderMaximumTracktTintColor
        slider.setThumbImage(Assets.image(named: "handle"), for: .normal)
        slider.setThumbImage(Assets.image(named: "handle"), for: .highlighted)
        slider.addTarget(self, action: #selector(sliderValueDidChange(sender:event:)), for: .valueChanged)
        
        moreInfoImageView.image = Assets.image(named: "icnArrowLeftRed")
        favoriteIconImageView.image = Assets.image(named: "iconMarker")
        favoriteIconImageView.isUserInteractionEnabled = true
        favoriteIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action: #selector(favoriteIconAction)))
        
        tooltipButton.setImage(Assets.image(named: "icnInfoGrayBig"), for: .normal)
        tooltipButton.addTarget(self, action: #selector(showToolTip), for: .touchUpInside)
    }
    
    @objc private func showToolTip() {
        BubbleLabelView.startWith(associated: tooltipButton,
                                  localizedStyleText: localized("simulator_label_tooltip"),
                                  position: .automatic)
    }
    
    @objc private func textFieldDidChange(sender: UITextField) {
        
        if let text = sender.text,
            let value = Float(text.replacingOccurrences(of: ".", with: "")),
            let viewModel = viewModel {
                if (viewModel.amountMinimun..<viewModel.amountMaximum).contains(value) {
                    slider.value = value
                }
                if value < viewModel.amountMinimun {
                    slider.value = viewModel.amountMinimun
                }
                if value > viewModel.amountMaximum {
                    slider.value = viewModel.amountMaximum
                }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enable = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enable = true
    }
    
    @objc private func monthsTextFieldDidChange(sender: UITextField) {
        guard
            let text = sender.text,
            let value = Double(text),
            let minimum = viewModel?.monthsMinimun
        else { return }
        if value < minimum {
            circularSlider.currentValue = minimum + 1
            return
        }
        if value == minimum { return }
        circularSlider.currentValue = value
    }
    
    private func configureField(_ field: UITextField) {
        let toolBar = UIToolbar()
               toolBar.barStyle = UIBarStyle.default
               toolBar.isTranslucent = true
               toolBar.tintColor = UIColor.santanderRed
               toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"),
                                         style: UIBarButtonItem.Style.done,
                                         target: self,
                                         action: #selector(textViewDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                          target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }
    
    @objc private func sliderValueDidChange(sender: UISlider, event: UIEvent) {
        endEditing(true)
        monthlyFeeValueLabel.text = "--"
        // update amount value
        let step: Float = 100
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        amountTextField.updateData(text: String(Int(roundedValue)).insertIntegerSeparator(separator: "."))
        
        // make service request when user finish moving the slider
        guard let touchEvent = event.allTouches?.first else { return }
        switch touchEvent.phase {
        case .began:
            delegate?.sliderDidStart()
            presenter?.sliderDidStart()
        case .ended:
            delegate?.sliderDidFinish()
            presenter?.sliderDidFinish()
            didSelectNewAmount(fromSlider: true)
        default: break
        }
    }
    
    @objc private func textViewDone() {
        
        defer {
            if amountTextField.isFirstResponder {
                didSelectNewAmount(fromSlider: false)
            } else {
                didSelectNewMonth(fromSlider: false)
            }
            endEditing(true)
        }
                
        if monthsValueTextField.isFirstResponder {
            monthsTextFieldFinishWith(text: monthsValueTextField.text)
            return
        }
        
        if amountTextField.isFirstResponder {
            amountTextFieldFinishWith(text: amountTextField.text)
            return
        }
    }
    
    private func amountTextFieldFinishWith(text: String?) {
        
        guard let text = text,
              let viewModel = viewModel,
              let value = Float(text.replacingOccurrences(of: ".", with: ""))
        else { return }
        
        if text.isEmpty {
            amountTextField.updateData(text: String(viewModel.amountMinimun))
            return
        }
        
        if value < viewModel.amountMinimun {
            let text = String(viewModel.amountMinimun)
            amountTextField.updateData(text: text)
        }
        if value > viewModel.amountMaximum {
            let text = String(viewModel.amountMaximum)
            amountTextField.updateData(text: text)
        }
    }
    
    private func monthsTextFieldFinishWith(text: String?) {
        
        guard let text = text,
              let viewModel = viewModel,
              let value = Double(text)
        else { return }
        
        if text.isEmpty {
            monthsValueTextField.text = String(Int(circularSlider.minimumValue))
            return
        }
        
        if value < viewModel.monthsMinimun {
            monthsValueTextField.text = String(Int(circularSlider.minimumValue))
        }
        if value > viewModel.monthsMaximum {
            monthsValueTextField.text = String(Int(circularSlider.maximumValue))
        }
    }
    
    private func reset() {
        _ = subviews.compactMap({ $0 as? UILabel })
                    .map({ $0.text = "" })
        amountTextField.updateData(text: "")
    }
    
    @objc private func moreInfoAction() {
        presenter?.didSelectMoreInfo()
    }
    
    @objc private func favoriteIconAction() {
        showToast()
    }
    
    private func configureCircularSlider() {
        circularSlider.delegate = self
        circularSlider.maximumAngle = 330
        
        circularSlider.sliderPadding = 28
        circularSlider.lineWidth = 16
        
        circularSlider.markerCount = 5
        circularSlider.markerColor = style.circularSliderMarkerColor
        circularSlider.markerSize = style.circularSliderMarkerSize
        circularSlider.labelOffset = 48
        circularSlider.filledColor = style.circularSliderFilledColor
        circularSlider.unfilledColor = style.circularSliderUnFilledColor
        circularSlider.handleImage = Assets.image(named: "handleForCircularSlider")
        circularSlider.handleEnlargementPoints = 32
    }
    
    private func showToast() {
         Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    private func didSelectNewAmount(fromSlider: Bool) {
        guard let months = monthsValueTextField.text else { return }
        
        presenter?.didSelectAmount(months: months, amount: String(Int(slider.value)), fromSlider: fromSlider)
    }
    
    private func didSelectNewMonth(fromSlider: Bool) {
        guard let months = monthsValueTextField.text else { return }

        presenter?.didSelectMonths(months: months, amount: String(Int(slider.value)), fromSlider: fromSlider)
    }
    
    private var loaderbackground: UIView?
    private func showLoader() {
        if loader == nil {
            loader = BallsLoaderView(title: localized("loading_label_simulator"),
                                     subTitle: localized("loading_label_moment"))
        }
        
        if loaderbackground == nil {
            loaderbackground = UIView()
        }
        
        guard let loaderbackground = loaderbackground else { return }
        
        addSubview(loaderbackground)
        loaderbackground.backgroundColor = .white
        loaderbackground.alpha = 0.8
        loaderbackground.translatesAutoresizingMaskIntoConstraints = false
        loaderbackground.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        loaderbackground.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        loaderbackground.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        loaderbackground.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        guard let loader = loader else { return }
        addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        loader.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        loader.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        loader.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        loader.startAnimating()
    }
    
    private func hideLoader() {
        self.loaderbackground?.removeFromSuperview()
        self.loader?.stopAnimating()
        self.loader?.removeFromSuperview()
        self.loader = nil
        self.loaderbackground = nil
    }
}

extension LoanSimulatorView: LoanSimulatorViewProtocol {
    
    func updateDataWith(_ viewModel: LoanSimulatorViewModel) {
        self.viewModel = viewModel
        amountTitleLabel.text = viewModel.amountTitleLabelText
        minimumValueLabel.attributedText = viewModel.minimumValueLabelText
        maximumValueLabel.text = viewModel.maximumValueLabelText
        monthlyFeeValueLabel.attributedText =  viewModel.monthlyFeeValueLabelText
        monthlyFeeTitleLabel.configureText(withKey: viewModel.monthlyFeeTitleLabelText,
                                           andConfiguration: LocalizedStylableTextConfiguration(font: style.monthlyFeeFont,
                                                                                                lineHeightMultiple: 0.8))
        monthsValueTextField.text = String(Int(viewModel.monthsCurrent))
        monthsLabel.text = viewModel.monthsText
        openingCommissionLabel.text = viewModel.openingCommissionLabelText
        tinLabel.text = viewModel.tinLabelText
        taeLabel.text = viewModel.taeLabelText
        moreinfoLabel.text = viewModel.moreinfoLabelText
        
        slider.minimumValue = min(viewModel.amountMinimun, viewModel.amountMaximum)
        slider.maximumValue = max(viewModel.amountMaximum, viewModel.amountMinimun)
        slider.value = viewModel.amountCurrent
        
        amountTextField.updateData(text: viewModel.amountValueLabelText)
        
        circularSlider.maximumValue = viewModel.monthsMaximum
        circularSlider.minimumValue = viewModel.monthsMinimun
        circularSlider.currentValue = viewModel.monthsCurrent
        let monthsMinLabel = String(Int(viewModel.monthsMinimun)) + " " + localized("generic_label_months")
        let monthsMaxLabel = String(Int(viewModel.monthsMaximum)) + " " + localized("generic_label_months")
        circularSlider.labels = [monthsMinLabel, monthsMaxLabel]
    }
    
    func showErrorWith(text: String, animated: Bool, showingTime: Float) {
        if errorView == nil {
            var errorFrame = frame
            errorFrame.size.height = 56.0
            errorView = LoanSimulatorErrorView(text: text)
        }
        guard let errorView = errorView else { return }
        backgroundView.insertSubview(errorView, at: backgroundView.subviews.count - 2)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        errorView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        errorView.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        errorViewTopconstraint = errorView.topAnchor.constraint(equalTo: backgroundView.topAnchor,
                                                                constant: 0.0)
        errorViewTopconstraint?.isActive = true
        let duration = animated ? 0.3 : 0.0
        Async.after(seconds: 0.2) {
            UIView.animate(withDuration: duration, delay: 0.0,
                           options: .curveEaseOut,
                           animations: { [weak self] in
                            let headerFrame = self?.headerView.frame.size.height ?? 0.0
                            self?.errorViewTopconstraint?.constant += (headerFrame - 2.0)
                            self?.layoutIfNeeded()
                }, completion: {_ in
                    Async.after(seconds: 3.0) {
                        self.hideError()
                    }
            })
        }
    }
    
    private func hideError() {
        guard errorView != nil, errorViewTopconstraint != nil else { return }
        UIView.animate(withDuration: 0.3, delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        let headerFrame = self.headerView.frame.size.height
                        self.errorViewTopconstraint?.constant -= (headerFrame + 10.0)
                        self.layoutIfNeeded()
            }, completion: { _ in
                self.errorViewTopconstraint = nil
                self.errorView?.removeFromSuperview()
                self.errorView = nil
        })
    }
}

extension LoanSimulatorView: CircularSliderProtocol {
    
    func circularSlider(_ slider: CircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        guard fromUser else { return }
        let labelValue = String(Int(value))
        monthsValueTextField.text = labelValue
        circularSlider.currentValue = Double(value)
    }
    
    func circularSlider(_ slider: CircularSlider, startedTrackingWith value: Double) {
        monthlyFeeValueLabel.text = "--"
        delegate?.sliderDidStart()
        presenter?.sliderDidStart()
    }
    
    func circularSlider(_ slider: CircularSlider, endedTrackingWith value: Double) {
        didSelectNewMonth(fromSlider: true)
        delegate?.sliderDidFinish()
        presenter?.sliderDidFinish()
    }
    
    func circularSlider(_ slider: CircularSlider, directionChangedTo value: CircularSliderDirection) { }
    
    func circularSlider(_ slider: CircularSlider, revolutionsChangedTo value: Int) {}
}

extension LoanSimulatorView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
