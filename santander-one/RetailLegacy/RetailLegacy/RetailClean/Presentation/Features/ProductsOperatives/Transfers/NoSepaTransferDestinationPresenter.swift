import Foundation

class NoSepaTransferDestinationPresenter: OperativeStepPresenter<FormViewController, NoSepaNavigatorProtocol, FormPresenterProtocol> {
    private enum InputIdentifier: String {
        case name
        case account
        case favourite
        case alias
    }
    
    private enum NoSepaTransferExpensesSeletor: CustomStringConvertible, CaseIterable {
        case shared
        case beneficiary
        case payer
        
        var description: String {
            switch self {
            case .shared:
                return "sendMoney_select_sharedExpenses"
            case .beneficiary:
                return "sendMoney_select_accountBeneficiaryExpenses"
            case .payer:
                return "sendMoney_select_accountPayerExpenses"
            }
        }
        var value: NoSepaTransferExpenses {
            switch self {
            case .shared: return .shared
            case .beneficiary: return .beneficiary
            case .payer: return .payer
            }
        }
    }
    
    private var transferExpenses: NoSepaTransferExpensesSeletor = .shared
    private let pdfLink = "https://infoproductos.bancosantander.es/cssa/StaticBS?blobcol=urldata&blobheadername1=content-type&blobheadername2=Content-Disposition&blobheadervalue1=application%2Fpdf&blobheadervalue2=inline%3B+filename%3Dtransferencias_exterior.pdf&blobkey=id&blobtable=MungoBlobs&blobwhere=1320599239338&cachecontrol=immediate&ssbinary=true&maxage=3600"
    private var date: Date?
    private var isFavourite: Bool = false
    private let isFavouriteSection: Int = 2
    private var favouriteSelected: FavoriteType?
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_sendMoney")
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        infoObtained()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.NoSepaTransferDestiny().page
    }
    
    // MARK: - Private methods
    
    private func infoObtained() {
        let sectionHeader = StackSection()
        let parameter: NoSepaTransferOperativeData = containerParameter()
        let account = parameter.account
        let header = AccountHeaderStackModel(accountAlias: account.getAlias() ?? "", accountIBAN: account.getIban()?.ibanShort() ?? "", accountAmount: account.getAmount()?.getAbsFormattedAmountUI() ?? "")
        sectionHeader.add(item: header)
        
        let sectionRecipent = StackSection()
        let nameTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.name.rawValue, keyTitle: "sendMoney_label_recipients", placeholderKey: nil, characterSet: CharacterSet.custom)
        sectionRecipent.add(items: nameTextFieldModel)
        let accountTextFieldModel = getTextItems(inputIdentifier: InputIdentifier.account.rawValue, keyTitle: "sendMoney_label_destinationAccount", placeholderKey: nil, characterSet: CharacterSet.ibanNoSepa)
        sectionRecipent.add(items: accountTextFieldModel)
        
        let favourites = OnePayTransferDestinationFavoritesStackModel(title: stringLoader.getString("sendMoney_label_retrievedFavoritesRecipients"))
        favourites.valueAction = { [weak self] in
            self?.onFavoritesButtonClicked()
        }
        sectionRecipent.add(item: favourites)
        
        let favouriteChecker = CheckStackModel(inputIdentifier: InputIdentifier.favourite.rawValue, title: dependencies.stringLoader.getString("sendMoney_label_saveFavoritesRecipients"), isSelected: isFavourite, insets: Insets(left: 11, right: 11, top: 15, bottom: 14), checkChanged: { [weak self] selected in
            guard let strongSelf = self else { return }
            strongSelf.isFavourite = selected
            strongSelf.view.dataSource.removeSection(index: strongSelf.isFavouriteSection)
            let sectionAlias = StackSection()
            if strongSelf.isFavourite {
                let aliasTitle = TitleLabelStackModel(title: strongSelf.dependencies.stringLoader.getString("sendMoney_label_favoritesRecipientsAlias"))
                sectionAlias.add(item: aliasTitle)
                let alias = TextFieldStackModel(inputIdentifier: InputIdentifier.alias.rawValue, maxLength: 50)
                sectionAlias.add(item: alias)
                strongSelf.trackEvent(eventId: TrackerPagePrivate.NoSepaTransferDestiny.Action.favourite.rawValue, parameters: [:])
            }
            strongSelf.view.dataSource.insertSection(section: sectionAlias, index: strongSelf.isFavouriteSection, animated: false)
        })
        
        sectionRecipent.add(item: favouriteChecker)
        
        let aliasSection = StackSection()
        let sectionExpenses = StackSection()
        let sectionExpensesTitle = TitleLabelInfoStackModel(title: dependencies.stringLoader.getString("sendMoney_label_expensesPay"), tooltipText: dependencies.stringLoader.getString("tooltip_label_payExpenses"), tooltipTitle: dependencies.stringLoader.getString("tooltip_title_payExpenses"), actionDelegate: self)
        sectionExpenses.add(item: sectionExpensesTitle)
        let selectorExpensesModel = OptionsPickerStackModel(items: NoSepaTransferExpensesSeletor.allCases, selected: NoSepaTransferExpensesSeletor.shared, dependencies: dependencies, insets: Insets(left: 10, right: 10, top: 0, bottom: 0)) { [weak self] selected in
            self?.transferExpenses = selected
        }
        sectionExpenses.add(item: selectorExpensesModel)
        let expensePdfModel = LinkPdfStackModel(title: dependencies.stringLoader.getString("sendMoney_link_seeRates"), linkTouch: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let requestComponents = OrdinaryRequestComponents(url: strongSelf.pdfLink, params: [:], method: .get, fields: nil, cookies: [:])
            let input = GetPdfUseCaseInput(requestComponents: requestComponents, cache: false)
            strongSelf.showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: strongSelf.view, completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                UseCaseWrapper(with: strongSelf.useCaseProvider.getPdfUseCase(input: input), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] responsePdf in
                    self?.hideLoading(completion: { [weak self] in
                        self?.navigator.goToPdfViewer(pdfData: responsePdf.pdfDocument)
                    })
                    }, onError: { [weak self] _ in
                        self?.hideLoading()
                })
            })
        })
        sectionExpenses.add(item: expensePdfModel)
        
        let sections = [sectionHeader, sectionRecipent, aliasSection, sectionExpenses]
        view.dataSource.reloadSections(sections: sections)
    }
    
    private func dateEnteredForIdentifier(_ identifier: InputIdentifier) -> String? {
        return view.dataSource.findData(identifier: identifier.rawValue)
    }
    
    private func getTextItems(inputIdentifier: String, keyTitle: String, placeholderKey: String?, characterSet: CharacterSet?) -> [StackItemProtocol] {
        var items: [StackItemProtocol] = []
        let titleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString(keyTitle))
        items.append(titleHeader)
        let placeholder: LocalizedStylableText?
        if let placeholderKey = placeholderKey {
            placeholder = dependencies.stringLoader.getString(placeholderKey)
        } else {
            placeholder = nil
        }
        let textFieldModel = TextFieldStackModel(inputIdentifier: inputIdentifier, placeholder: placeholder, maxLength: 50, characterSet: characterSet)
        items.append(textFieldModel)
        return items
    }
    
    private func onFavoritesButtonClicked() {
        let parameter: NoSepaTransferOperativeData = containerParameter()
        navigator.goToFavourites(delegate: self, country: parameter.country, currency: parameter.currency)
    }
}

// MARK: - OnePayTransferDestinationDelegate

extension NoSepaTransferDestinationPresenter: OnePayTransferDestinationDelegate {
    func selectedFavourite(item: FavoriteType) {
        view.dataSource.removeSection(index: isFavouriteSection)
        let sectionAlias = StackSection()
        view.dataSource.insertSection(section: sectionAlias, index: isFavouriteSection, animated: false)
        isFavourite = false
        view.dataSource.updateData(identifier: InputIdentifier.favourite.rawValue, value: CheckStackModelValues.checkFalse.rawValue)
        view.dataSource.updateData(identifier: InputIdentifier.account.rawValue, value: item.favorite.destinationAccount ?? "")
        view.dataSource.updateData(identifier: InputIdentifier.name.rawValue, value: item.name ?? "")
        favouriteSelected = item
    }    
}

extension NoSepaTransferDestinationPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let operativeData: NoSepaTransferOperativeData = containerParameter()
        let operationDate = date ?? Date()
        let input = DestinationNoSepaTransferUseCaseInput(
            originAccount: operativeData.account,
            beneficiary: dateEnteredForIdentifier(.name) ?? "",
            beneficiaryAccountValue: dateEnteredForIdentifier(.account),
            countryInfo: operativeData.country,
            transferAmount: operativeData.amount,
            expensiveIndicator: transferExpenses.value,
            countryCode: operativeData.country.code,
            concept: operativeData.concept ?? "", 
            dateOperation: date ?? Date(),
            saveFavorites: isFavourite,
            favouriteList: operativeData.favouriteList.map { $0.favorite },
            alias: dateEnteredForIdentifier(.alias) ?? ""
        )
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getDestinationNoSepaTransferUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    operativeData.transferExpenses = strongSelf.transferExpenses.value
                    operativeData.detailTemporalAccount = result.account
                    operativeData.date = operationDate
                    operativeData.beneficiary = result.beneficiary
                    operativeData.aliasPayee = result.newAlias
                    operativeData.isNewPayee = strongSelf.isFavourite
                    if case .sepa = result.destinationNoSepaTransferUseCaseType {
                        operativeData.transferType = .sepa
                        operativeData.shouldAskForDetail = false
                        operativeData.noSepaTransferValidation = result.noSepaTransferValidation
                    } else {
                        operativeData.shouldAskForDetail = true
                    }
                    defer {
                        strongSelf.container?.rebuildSteps()
                        strongSelf.container?.saveParameter(parameter: operativeData)
                        strongSelf.container?.stepFinished(presenter: strongSelf)
                    }
                    guard
                        let item = self?.favouriteSelected,
                        operativeData.favouriteList.contains(where: { $0.name == result.beneficiary && $0.favorite.formattedAccount == result.account }),
                        item.noSepaPayee?.swiftCode != nil || item.noSepaPayee?.bankName != nil
                    else {
                        operativeData.favouriteSelected = nil
                        return
                    }
                    operativeData.favouriteSelected = item
                    
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    switch error?.error {
                    case .destinationAccounts?:
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_destinationAccounts")
                    case .noToName?:
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_nameRecipients")
                    case .noAlias?:
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_alias")
                    case .duplicateAlias(let alias)?:
                        let acceptComponents = DialogButtonComponents(titled: strongSelf.localized(key: "generic_button_accept"), does: nil)
                        Dialog.alert(title: strongSelf.localized(key: "generic_alert_title_errorData"), body: strongSelf.localized(key: "onePay_alert_valueAlias", stringPlaceHolder: [StringPlaceholder(.value, alias)]), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: strongSelf.view)
                    case .serviceError(let errorDesc)?:
                        strongSelf.showError(keyDesc: errorDesc)
                    case .none:
                        break
                    }
                }
            }
        )
    }
}

// MARK: - TooltipTextFieldActionDelegate

extension NoSepaTransferDestinationPresenter: TooltipTextFieldActionDelegate {
    func auxiliaryButtonAction(completion: (TooltipTextFieldAuxiliaryAction) -> Void) {
        completion(.toolTip(delegate: view))
    }
}

extension NoSepaTransferDestinationPresenter: DateFieldStackModelDelegate {
    func dateChanged(inputIdentifier: String, date: Date?) {
        self.date = date
    }
}
