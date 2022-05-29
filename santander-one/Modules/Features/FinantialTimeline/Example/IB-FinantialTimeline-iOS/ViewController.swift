//
//  ViewController.swift
//  IB-FinantialTimeline-iOS
//
//  Created by esepakuto on 06/24/2019.
//  Copyright (c) 2019 esepakuto. All rights reserved.
//

import UIKit
import FinantialTimeline
import SantanderUIKitLib

class ViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var timeLineButton: UIButton!
    @IBOutlet weak var timeLineLogo: UIImageView!
    @IBOutlet weak var santanderLogo: UIImageView!
    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var moduleVersionLabel: UILabel!

    var host: String? = TimeLineURL.angularURL?.absoluteString
    var isNative: Bool = true
    var language: String = Locale.current.languageCode ?? "en"
    var name: String = "IBDev"
    var maxDisplayNumberChar: Int = 4
    var maskChar: String = "***"
    var resetStorage: Bool = false
    var days = 7
    var elements = 3
    var showWidgetState = false
    
    let loginInteractor = LoginInteractor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true
        swipeGesture()
        prepareUI()
        setTimeLineButton()
        hideKeyboardWhenTappedAround()
        passwordTextField.text = "123"
        guard let navigationController = navigationController as? SantanderNavigationController else { return }
        navigationController.style = .light
    }
    
    func prepareUI() {
        separator.backgroundColor = UIColor.primary
        prepareLabels()
        prepareButton()
        prepareImages()
        prepareTextField()
    }
    
    func prepareLabels() {
        prepare(label: infoLabel, with: NSLocalizedString("about.time.line.message", comment: ""))
        prepare(label: userLabel, with:  NSLocalizedString("user", comment: ""))
        prepare(label: passwordLabel, with:  NSLocalizedString("password", comment: ""))
        prepare(label: moduleVersionLabel, with:  "v \(TimeLine.version() ?? "") (IB-\(getAppBuild()))" )

    }
    
    func prepare(label: UILabel, with text: String) {
        label.textColor = UIColor.greyishBrown
        label.text = text
    }
    
    func prepareButton() {
        timeLineButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        timeLineButton.setTitle(NSLocalizedString("title.time.line", comment: ""), for: .normal)
        timeLineButton.layer.cornerRadius = timeLineButton.bounds.height / 2
        timeLineButton.backgroundColor = UIColor.primary
        timeLineButton.tintColor = UIColor.white
    }
    
    func prepareImages() {
        prepare(imageView: santanderLogo, with: UIImage(named: "santander_logo"))
        prepare(imageView: timeLineLogo, with: UIImage(named: "ic_time_line"))
    }
    
    func prepare(imageView: UIImageView, with image: UIImage?) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.primary
    }
    
    func prepareTextField() {
        prepareTokenTF()
    }
    
    func prepareTokenTF() {
        nameTextField.text = name
        nameTextField.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        nameTextField.delegate = self
        nameTextField.enablesReturnKeyAutomatically = true
    }
    
    func setTimeLineButton() {
        if name != "" && passwordTextField.text != "" {
            timeLineButton.isEnabled = true
        }
        
    }
    
    func setTimeLine(token: String) {
        if isNative {
            Environment.setupNativeTimeLine(for: .token(token), currencySymbols: ["MXN": "$", "EUR": "€"], delegate: self, language: language)
        } else {
            guard let url = host.flatMap(URL.init(string:)) else { return }
            Environment.setupHybridTimeLine(for: .token(token), url: url, language: language)
        }
    }
}


//MARK: - Swipe
extension ViewController {
    func swipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            let vc = TimeLine.load()
            self.show(vc, sender: self)
        }
    }
    
    @IBAction func callLibraryPressed(_ sender: Any) {
        self.infoLabel.text = NSLocalizedString("connecting", comment: "")
        loginInteractor.login(user: name, password: passwordTextField.text!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.onLoginSucces(with: token)
            case .failure(let error):
                self.onLoginError(with: error)
            }
        }
    }
    
    func onLoginError(with error: Error) {
        DispatchQueue.main.async {
            self.infoLabel.text = error.localizedDescription
        }
    }
    
    func onLoginSucces(with token: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = NSLocalizedString("about.time.line.message", comment: "")
            if self.showWidgetState {
                self.openWidget(with: token)
            } else {
                self.openTimeLine(with: token)
            }
        }
    }
    
    func openTimeLine(with token: String) {
        self.setTimeLine(token: token)
        callResetStorage()
        let vc = TimeLine.load()
        self.show(vc, sender: self)
    }
    
    func openWidget(with token: String) {
        self.setTimeLine(token: token)
        let view = TimeLine.loadWidget(days: days, elements: elements)
        let vc = WidgetViewController(widgetView: view)
        self.show(vc, sender: self)
    }
    
    func callResetStorage() {
        if resetStorage {
            TimeLine.resetStorage()
        }
    }
    
    @IBAction func onConfigTap(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfigViewController") as? ConfigViewController else { return }
        vc.delegate = self
        vc.host = host
        vc.isNative = isNative
        vc.language = language
        vc.showWidgetState = showWidgetState
        self.show(vc, sender: self)
    }
}

// MARK: - ConfigControllerDelegate
extension ViewController: ConfigControllerDelegate {
    func onMaskCharChanged(_ mask: String) {
        maskChar = mask
    }
    
    func onmaxDisplayNumberCharChanged(_ maxChar: Int) {
        maxDisplayNumberChar = maxChar
    }
    
    func onTechChange(_ isNative: Bool) {
        self.isNative = isNative
        setTimeLineButton()
    }
    
    func onHostDidChange(_ host: String) {
        self.host = host
        setTimeLineButton()
    }
    
    func onLanguageDidChange(_ language: String) {
        self.language = language
        setTimeLineButton()
    }
    
    func onResetStorageDidChange(_ reset: Bool) {
        self.resetStorage = reset
        setTimeLineButton()
    }
    
    func showWidgetDidChange(_ isOn: Bool) {
        self.showWidgetState = isOn
    }
    
    func daysDidChange(_ days: Int) {
        self.days = days
    }
    
    func elementsDidChange(_ elements: Int) {
        self.elements = elements
    }
}

// MARK: - UITextField
extension ViewController: UITextFieldDelegate {
    @objc func  textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.name = text
        setTimeLineButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.name != "" {
            callLibraryPressed(self)
        }
        return true
    }
}


extension ViewController: TimeLineDelegate {
    func onTimeLineCTATap(from viewController: TimeLineDetailViewController, with action: CTAAction) {
        guard let delegateReference = action.structure?.action.delegateReference else { return }
        switch delegateReference {
        case "goToAccounts":
            openCTA(from: viewController, with: ("to Accounts"))
        case "goToCards":
            openCTA(from: viewController, with: ("to Cards"))
        default:
            break
        }
    }

    func mask(displayNumber: String, completion: @escaping (String) -> Void) {
         if displayNumber.count <= maxDisplayNumberChar {
            completion("\(maskChar)\(displayNumber)")
        } else {
            let last = displayNumber.suffix(maxDisplayNumberChar)
            completion("\(maskChar)\(last)")
        }
    }
}

extension ViewController {
    func openCTA(from controller: UIViewController, with title: String) {
        let controllerName = "CTAExampleController"
        let sb = UIStoryboard(name: controllerName, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: controllerName)
        vc.title = title
           
        controller.show(vc, sender: self)
    }
}
