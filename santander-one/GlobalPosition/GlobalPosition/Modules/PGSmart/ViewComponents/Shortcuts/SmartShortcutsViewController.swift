//
//  SmartShortCutsViewController.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 28/04/2020.
//

import CoreDomain
import CoreFoundationLib
import UI

class SmartShortcutsViewController: UIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
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
    @IBOutlet weak var saveChangesButtonView: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    private weak var delegate: ShortcutsDelegate?
    private var dottedBorderLayer: CAShapeLayer?
    private var gpColorMode: PGColorMode = .red
    
    var viewModels: [GpOperativesViewModel]?
    var isEditingEnable = false
    
    lazy var optionsBarTopStackView: SmartGPOptionsBar = {
        let view = SmartGPOptionsBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setPopGestureEnabled(false)
        setupOrigin()
        if !isEditingEnable {
            self.optionsBarTopStackView.setPlusButtonHidden(true, animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setPopGestureEnabled(true)
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            if self.isEditingEnable {
                self.configureSizeDottedBorder()
            } else {
                guard self.optionsBarTopStackView.containerView != nil else { return }
                self.optionsBarTopStackView.containerView.layer.cornerRadius = self.optionsBarTopStackView.containerView.frame.height / 2
            }
        }
    }
    
    func setData(delegate: ShortcutsDelegate, viewModels: [GpOperativesViewModel], gpColorMode: PGColorMode) {
        self.delegate = delegate
        self.viewModels = viewModels
        self.gpColorMode = gpColorMode
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

private extension SmartShortcutsViewController {
    
    func commonInit() {
        configureViewStyle()
        configureButtonView()
        configureBottomStackView()
        configureDataStackViews()
        configureSaveButton()
        configureDottedBorder()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .white),
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
        self.view.backgroundColor = .clear

        topContainerView?.backgroundColor = UIColor.clear
        headerBackView?.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        separationView?.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        switch gpColorMode {
        case .red:
            backgroundImage?.isHidden = false
            backgroundImage?.image = Assets.image(named: "icnRedBackground")
            backgroundImage?.contentMode = .scaleAspectFill
            
        case .black:
            backgroundImage?.isHidden = false
            backgroundImage?.image = Assets.image(named: "bgSmartBlack")
            backgroundImage?.contentMode = .scaleAspectFill
        }
    }
    
    func configureTopStackView() {
        topContainerView?.backgroundColor = .clear
        topContainerView?.addSubview(optionsBarTopStackView)
        topContainerView?.topAnchor.constraint(equalTo: optionsBarTopStackView.topAnchor, constant: 0).isActive = true
        topContainerView?.leftAnchor.constraint(equalTo: optionsBarTopStackView.leftAnchor, constant: 0).isActive = true
        topContainerView?.rightAnchor.constraint(equalTo: optionsBarTopStackView.rightAnchor, constant: 0).isActive = true
        topContainerView?.bottomAnchor.constraint(equalTo: optionsBarTopStackView.bottomAnchor, constant: 0).isActive = true
    }
    
    func configureTopEditableStackView() {
        topContainerView?.backgroundColor = gpColorMode == .red ? .rubyRed : .darkMetal
        topContainerView?.addSubview(topStackView)
        topContainerView?.topAnchor.constraint(equalTo: topStackView.topAnchor, constant: -8).isActive = true
        topContainerView?.leftAnchor.constraint(equalTo: topStackView.leftAnchor, constant: -8).isActive = true
        topContainerView?.rightAnchor.constraint(equalTo: topStackView.rightAnchor, constant: 8).isActive = true
        topContainerView?.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 8).isActive = true
        topContainerView?.layer.cornerRadius = 4
    }
    
    func configureBottomStackView() {
        containerView?.addSubview(bottomStackView)
        containerView?.topAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -8).isActive = true
        containerView?.leftAnchor.constraint(equalTo: bottomStackView.leftAnchor, constant: -8).isActive = true
        containerView?.rightAnchor.constraint(equalTo: bottomStackView.rightAnchor, constant: 8).isActive = true
        containerView?.bottomAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 0).isActive = true
    }
    
    func configureDataStackViews() {
        guard let viewModels = viewModels else { return }
        
        let topOfViewModels = Array(viewModels[0..<4])

        if isEditingEnable {
            optionsBarTopStackView.removeFromSuperview()
            topStackView.removeFromSuperview()
            configureTopEditableStackView()
            
            topStackView.addActions(topOfViewModels, usingStyle: gpColorMode == .red ? .smartShortcutSelectorStyle : .smartBlackShortcutSelectorStyle, delegate: self)
        } else {
            optionsBarTopStackView.removeFromSuperview()
            topStackView.removeFromSuperview()
            configureTopStackView()
            optionsBarTopStackView.setOptions(topOfViewModels)
        }
        
        guard viewModels.count > 4 else { return }
        let restOfViewModels = Array(viewModels[4..<viewModels.count])
        bottomStackView.addActions(restOfViewModels, usingStyle: gpColorMode == .red ? .smartShortcutSelectorStyle : .smartBlackShortcutSelectorStyle, delegate: self)
    }
    
    func configureButtonView() {
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonDidPressed)))
        configurationLabel.text = localized("pgCustomize_label_directAccess")
        buttonView.backgroundColor = .clear

        configurationImageView.image = Assets.image(named: "icnConfigurationWhite")
        configurationLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        configurationLabel.textColor = UIColor.white
    }
    
    func configureSaveButton() {
        saveChangesButtonView.isHidden = true
        
        saveChangesButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        saveChangesButton.setTitle(localized("displayOptions_button_saveChanges"), for: .normal)
        saveChangesButton.setTitleColor(.white, for: .normal)
        saveChangesButton.layer.cornerRadius = (saveChangesButton?.bounds.height ?? 0.0) / 2.0
        saveChangesButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    func configureEditableView() {
        configureEditableStackViews()
        configureEditableButtonView()
    }
    
    func configureEditableStackViews() {
        dottedBorderLayer?.isHidden = !isEditingEnable
        
        if isEditingEnable { topStackView.setDragEnabled(true) }
        bottomStackView.setDragEnabled(isEditingEnable)
    }
    
    func configureEditableButtonView() {
        buttonView.isHidden = isEditingEnable
        saveChangesButtonView.isHidden = !isEditingEnable
    }
    
    func configureDottedBorder() {
        let frameSize = topContainerView?.frame.size ?? CGSize.zero

        dottedBorderLayer = CAShapeLayer()
        dottedBorderLayer?.bounds = topContainerView?.bounds ?? CGRect.zero
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.fillColor = UIColor.clear.cgColor
        dottedBorderLayer?.strokeColor = UIColor.darkTurqLight.cgColor
        dottedBorderLayer?.lineWidth = 1.0
        dottedBorderLayer?.lineJoin = .round
        dottedBorderLayer?.lineDashPattern = [4, 4]
        dottedBorderLayer?.path = UIBezierPath(roundedRect: topContainerView?.bounds ?? CGRect.zero, cornerRadius: 5).cgPath

        topContainerView?.layer.addSublayer(dottedBorderLayer ?? CAShapeLayer())
                
        dottedBorderLayer?.isHidden = true
    }
    
    func configureSizeDottedBorder() {
        let frameSize = topContainerView?.frame.size ?? CGSize.zero
        
        dottedBorderLayer?.bounds = topContainerView?.bounds ?? CGRect.zero
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.path = UIBezierPath(roundedRect: topContainerView?.bounds ?? CGRect.zero, cornerRadius: 5).cgPath
    }
    
    func reloadButtons() {
        if isEditingEnable { topStackView.subviews.forEach { $0.removeFromSuperview() } }
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }

        configureDataStackViews()
    }
    
    // MARK: - Actions
    
    @objc func didPressClose() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func buttonDidPressed() {
        isEditingEnable = true
        reloadButtons()
        configureEditableView()
    }
    
    @objc func appWillEnterForeground() {
        configureEditableStackViews()
    }
}

extension SmartShortcutsViewController: DragButtonDelegate, DragHelper {}
