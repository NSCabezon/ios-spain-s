//
//  HelpCenterSearchView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 03/04/2020.
//

import UI
import CoreFoundationLib

public class HelpCenterSearchView: XibView {
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var searchTextField: LisboaTextfield!
    @IBOutlet weak var openGlobalSearchButton: UIButton!
    
    public weak var helpCenterDelegate: HelpCenterSearchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        labelTitle.configureText(withKey: "search_title_transactionsSearch",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 20)))
        labelTitle.textColor = UIColor.lisboaGray
        searchTextField.configure(with: nil, title: localized("search_hint_textConcept"), extraInfo: (image: Assets.image(named: "icnSearch"), action: {
            self.searchTextField.field.becomeFirstResponder() }), imageAccessibilityIdentifier: "icnSearch")
        searchTextField.setAccessibleIdentifiers(titleLabelIdentifier: "helpCenter_search_title", fieldIdentifier: "helpCenter_search_field", imageIdentifier: "helpCenter_search_image")
        setAccessibilityIdentifiers()
    }
    
    @IBAction func openGlobalSearchButtonPressed(_ sender: Any) {
        helpCenterDelegate?.didTapGlobalSearch()
    }
    
    private func setAccessibilityIdentifiers() {
        labelTitle.accessibilityIdentifier = "labelTitle"
        searchTextField.accessibilityIdentifier = "searchTextField"
    }
}
