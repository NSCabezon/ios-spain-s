//
//  MoneyTransferComponent.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 18/12/2019.
//

import UIKit
import CoreFoundationLib
import UI

class MoneyTransferView: UIView {
    @IBOutlet weak private var sendLabel: UILabel!
    @IBOutlet weak private var transferLabel: UILabel!
    @IBOutlet weak private var bigView: UIView!
    @IBOutlet weak private var contactsButton: UIButton!
    @IBOutlet weak private var circleView: UIView!
    @IBOutlet weak private var bizumImage: UIImageView!
    @IBOutlet weak private var newSendLabel: UILabel!
    @IBOutlet weak private var andLabel: UILabel!
    @IBOutlet weak private var addContactLabel: UILabel!
    @IBOutlet weak private var newContactLabel: UILabel!
    @IBOutlet weak private var transferView: UIView!
    @IBOutlet weak private var contactView: UIView!
    @IBOutlet weak private var newContactCircularView: UIView!
    @IBOutlet weak var newContactImageView: UIImageView!
    weak var delegate: ContactsViewDelegate?
    private var view: UIView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
        self.commonInit()
    }
    
    // MARK: - IBAction
    @IBAction func didTapOnSeeContact(_ sender: Any) {
        self.delegate?.didTapOnSeeContact()
    }
    
    @IBAction func didTapOnNewShipment(_ sender: Any) {
        self.delegate?.didTapOnNewShipment()
    }
    
    @IBAction func didTapOnNewContact(_ sender: Any) {
        self.delegate?.didTapOnNewContact()
    }
}

private extension MoneyTransferView {
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func commonInit() {
        configureHeader()
        configureTransferView()
        configureContactView()
        configureViews()
    }
    
    func configureViews() {
        self.bigView?.backgroundColor = UIColor.skyGray
        self.bizumImage.image = Assets.image(named: "icnSendMoneyMobile")
        self.addShadow(for: transferView)
        self.addShadow(for: contactView)
    }
    
    func addShadow(for contentView: UIView) {
        contentView.backgroundColor = UIColor.white
        contentView.layer.shadowOffset = CGSize(width: 1, height: 2)
        contentView.layer.shadowOpacity = 0.59
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        contentView.layer.shadowRadius = 0.0
        contentView.layer.masksToBounds = false
        contentView.clipsToBounds = false
        contentView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    // MARK: - Header
    func configureHeader() {
        sendLabel?.text = localized("transfer_title_sendTo")
        sendLabel?.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        sendLabel?.textColor = UIColor.lisboaGray
        
        contactsButton?.setTitle(localized("transfer_label_seeContacts"), for: .normal)
        contactsButton?.tintColor = UIColor.darkTorquoise
        contactsButton?.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14)
    }
    
    // MARK: - Transfer View
    func configureTransferView() {
        configureBackgroundView()
        configureTransferLabels()
    }
    
    func configureBackgroundView() {
        circleView.backgroundColor = UIColor.botonRedLight
        circleView.layer.cornerRadius = circleView.frame.size.width/2
        circleView.clipsToBounds = true
    }
    
    func configureTransferLabels() {
        newSendLabel?.text = localized("transfer_button_newSend")
        newSendLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        newSendLabel?.textColor = UIColor.lisboaGray
        
        setParagraphStyle(to: transferLabel, text: localized("transfer_text_button_newSend"))
        
        andLabel?.text = localized("generic_text_and")
        andLabel?.font = UIFont.santander(family: .text, type: .regular, size: 11.0)
        andLabel?.textColor = UIColor.mediumSanGray
    }
    
    func setParagraphStyle(to label: UILabel, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0.75
        let builder = TextStylizer.Builder(fullText: text)
        label.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setStyle(UIFont.santander(family: .text, type: .regular, size: 11)))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setParagraphStyle(paragraphStyle))
            .build()
        label.textColor = UIColor.mediumSanGray
    }
    
    // MARK: - Contact View
    func configureContactView() {
        newContactCircularView.backgroundColor = UIColor.botonRedLight
        newContactCircularView.layer.cornerRadius = circleView.frame.size.width/2
        newContactCircularView.clipsToBounds = true
        newContactImageView.image = Assets.image(named: "icnNewContact")
        newContactLabel?.text = localized("pg_label_newContacts")
        newContactLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        newContactLabel?.textColor = UIColor.lisboaGray
        setParagraphStyle(to: addContactLabel, text: localized("pg_text_addFavoriteContacts"))
    }
}
