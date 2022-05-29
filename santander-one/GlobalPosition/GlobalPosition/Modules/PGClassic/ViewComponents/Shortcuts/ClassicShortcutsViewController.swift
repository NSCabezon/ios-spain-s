//
//  ClassicShortcutsViewController.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 30/04/2020.
//

import CoreFoundationLib
import UI

protocol ShortcutsDelegate: AnyObject {
    func didSaveChanges(viewModels: [GpOperativesViewModel])
}

final class ClassicShortcutsViewController: UIViewController {
    @IBOutlet weak var headerBackView: UIView!
    @IBOutlet weak var separationView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var configurationImageView: UIImageView!
    @IBOutlet weak var configurationLabel: UILabel!
    @IBOutlet weak var dragContainer: DragContainer!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var viewModelsScrollView: UIScrollView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveChangedButtonView: UIView!
    
    private weak var delegate: ShortcutsDelegate?
    private var dottedBorderLayer: CAShapeLayer?
    private let animationDelay = 0.3
    
    var viewModels: [GpOperativesViewModel]?
    var isEditingEnable = false

    lazy var topStackView: ActionButtonsStackView<GpOperativesViewModel> = {
        let stackView = ActionButtonsStackView<GpOperativesViewModel>()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var bottomStackView: ActionButtonsStackView<GpOperativesViewModel> = {
        let stackView = ActionButtonsStackView<GpOperativesViewModel>()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        self.setAccessibilityLabels()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        setPopGestureEnabled(false)
        if #available(iOS 11.0, *) { setupOrigin() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.configureSizeDottedBorder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateStackView {
            UIView.animate(withDuration: self.animationDelay, animations: {
                self.buttonView.alpha = 1
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.setHidesBackButton(false, animated: false)
        setPopGestureEnabled(true)
    }
    
    func setData(delegate: ShortcutsDelegate, viewModels: [GpOperativesViewModel]) {
        self.delegate = delegate
        self.viewModels = viewModels
    }
    
    @IBAction func saveChangesButtonDidPressed(_ sender: Any) {
        isEditingEnable = false
        reloadButtons()
        configureEditableView()
        dragContainer.resetView()

        guard let viewModels = self.viewModels else { return }
        delegate?.didSaveChanges(viewModels: viewModels)
    }
}

// MARK: - Private methods

private extension ClassicShortcutsViewController {
    
    func commonInit() {
        configureViewStyle()
        configureButtonView()
        configureTopStackView()
        configureBottomStackView()
        configureDataStackViews()
        configureSaveButton()
        configureDottedBorder()
        configureBottomStackAnimation()
        self.setButtonsGestureEvent()
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "pg_title_modalFrequentOperative")
        )
        builder.setRightActions(.close(action: #selector(didPressClose)))
        builder.build(on: self, with: nil)
    }
    
    func setupOrigin() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0.0
        topConstraint.constant = self.view.bounds.origin.y + statusBarHeight + navigationBarHeight
    }
    
    func configureViewStyle() {
        view.backgroundColor = UIColor.white
        topContainerView.backgroundColor = UIColor.skyGray
        headerBackView.backgroundColor = UIColor.skyGray
        separationView.backgroundColor = UIColor.mediumSkyGray
    }
    
    func configureTopStackView() {
        topContainerView.addSubview(topStackView)
        topContainerView.topAnchor.constraint(equalTo: topStackView.topAnchor, constant: -6).isActive = true
        topContainerView.leftAnchor.constraint(equalTo: topStackView.leftAnchor, constant: -8).isActive = true
        topContainerView.rightAnchor.constraint(equalTo: topStackView.rightAnchor, constant: 8).isActive = true
        topContainerView.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 8).isActive = true
        topContainerView.layer.cornerRadius = 4
    }
    
    func configureBottomStackView() {
        containerView.addSubview(bottomStackView)
        containerView.topAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -8).isActive = true
        containerView.leftAnchor.constraint(equalTo: bottomStackView.leftAnchor, constant: -8).isActive = true
        containerView.rightAnchor.constraint(equalTo: bottomStackView.rightAnchor, constant: 8).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 0).isActive = true
    }
    
    func configureDataStackViews() {
        guard let viewModels = viewModels else { return }
        let topOfViewModels = Array(viewModels[0..<4])
        topStackView.addActions(topOfViewModels, delegate: self)
        guard viewModels.count > 4 else { return }
        let restOfViewModels = Array(viewModels[4..<viewModels.count])
        bottomStackView.addActions(restOfViewModels, delegate: self)
    }
    
    func configureBottomStackAnimation() {
        bottomStackView.setAlphaArrangedSubViews(0.0)
    }
    
    func reloadButtons() {
        topStackView.subviews.forEach { $0.removeFromSuperview() }
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }

        configureDataStackViews()
    }
    
    func configureButtonView() {
        configurationLabel.text = localized("pgCustomize_label_directAccess")
        buttonView.backgroundColor = UIColor.white
        buttonView.alpha = 0
        configurationImageView.image = Assets.image(named: "icnConfiguration")
        configurationLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        configurationLabel.textColor = UIColor.darkTorquoise
    }

    func configureSaveButton() {
        saveChangedButtonView.isHidden = true
        
        saveChangesButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        saveChangesButton.setTitle(localized("displayOptions_button_saveChanges"), for: .normal)
        saveChangesButton.setTitleColor(.santanderRed, for: .normal)
        saveChangesButton.layer.borderWidth = 1
        saveChangesButton.layer.cornerRadius = (saveChangesButton?.bounds.height ?? 0.0) / 2.0
        saveChangesButton.layer.borderColor = UIColor.santanderRed.cgColor
        saveChangesButton.backgroundColor = .clear
    }
    
    func animateStackView(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.bottomStackView.setAlphaArrangedSubViewsAnimated(alpha: 1.0, delay: animationDelay, completion: { [weak self] in
            self?.animateExtraLabelStackView()
        })
        self.bottomStackView.setAlphaArrangedSubViewsAnimated(alpha: 1.0, delay: animationDelay)
        CATransaction.commit()
    }
    
    func animateExtraLabelStackView() {
        let buttonsLists = self.bottomStackView.arrangedSubviews
        var delay = animationDelay
        
        buttonsLists.compactMap({$0 as? UIStackView}).forEach { (stack) in
            CATransaction.begin()
            for button in stack.arrangedSubviews {
                (button as? ActionButton)?.animateExtraLabelContent(withDelay: animationDelay, offset: delay)
            }
            CATransaction.commit()
            delay += animationDelay
        }
    }
    
    func configureEditableView() {
        configureEditableStackViews()
        configureEditableButtonView()
    }
    
    func configureEditableStackViews() {
        topContainerView.backgroundColor = isEditingEnable ? UIColor.darkTurqLight.withAlphaComponent(0.21) : UIColor.clear
        dottedBorderLayer?.isHidden = !isEditingEnable
        
        topStackView.setDragEnabled(isEditingEnable)
        bottomStackView.setDragEnabled(isEditingEnable)
    }
    
    func configureEditableButtonView() {
        buttonView.isHidden = isEditingEnable
        saveChangedButtonView.isHidden = !isEditingEnable
    }
    
    func configureDottedBorder() {
        let frameSize = topContainerView.frame.size
        dottedBorderLayer = CAShapeLayer()
        dottedBorderLayer?.bounds = topContainerView.bounds
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.fillColor = UIColor.clear.cgColor
        dottedBorderLayer?.strokeColor = UIColor.darkTurqLight.cgColor
        dottedBorderLayer?.lineWidth = 1.0
        dottedBorderLayer?.lineJoin = .round
        dottedBorderLayer?.lineDashPattern = [4, 4]
        dottedBorderLayer?.path = UIBezierPath(roundedRect: topContainerView.bounds, cornerRadius: 5).cgPath

        topContainerView.layer.addSublayer(dottedBorderLayer ?? CAShapeLayer())
                
        dottedBorderLayer?.isHidden = true
    }
    
    func configureSizeDottedBorder() {
        let frameSize = topContainerView.frame.size
        dottedBorderLayer?.bounds = topContainerView.bounds
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.path = UIBezierPath(roundedRect: topContainerView.bounds, cornerRadius: 5).cgPath
    }
    
    @objc func didPressClose() { navigationController?.popToRootViewController(animated: true) }
    
    @objc func buttonDidPressed() {
        isEditingEnable = true
        reloadButtons()
        configureEditableView()
    }
    
    @objc func appWillEnterForeground() {
        configureEditableStackViews()
    }
    
    func setButtonsGestureEvent() {
        let shortcutsGesture = UITapGestureRecognizer(target: self, action: #selector(buttonDidPressed))
        self.buttonView.addGestureRecognizer(shortcutsGesture)
    }
    
    func setAccessibilityLabels() {
        self.configurationLabel.accessibilityLabel = localized(AccessibilityShortcuts.pgLabelDirectAccess)
        self.buttonView.accessibilityLabel = localized(AccessibilityShortcuts.pgLabelDirectAccess)
    }
}

extension ClassicShortcutsViewController: DragButtonDelegate, DragHelper {}
