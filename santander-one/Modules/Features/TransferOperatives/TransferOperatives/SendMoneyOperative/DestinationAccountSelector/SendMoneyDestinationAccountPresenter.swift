//
//  SendMoneyDestinationAccountPresenter.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 22/9/21.
//

import Operative
import CoreFoundationLib
import CoreDomain

protocol SendMoneyDestinationAccountPresenterProtocol: OperativeStepPresenterProtocol {
    var view: SendMoneyDestinationAccountView? { get set }
    var newRecipientConfiguration: NewRecipientViewConfiguration { get }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectBack()
    func didSelectClose()
    func changeOriginAccount()
    func didSelectFavoriteAccount(_ cardViewModel: OneFavoriteContactCardViewModel, isFromList: Bool)
    func didSelectSeeAllFavorites()
    func didSearchFavorite(text: String)
    func didTapAddNewContact()
    func didSelectPastTransfer(index: Int)
    func didChangeNewRecipientData(_ iban: String, name: String, alias: String)
    func didPressedFloatingButton()
    func getSubtitleInfo() -> String
    func getStepOfSteps() -> [Int]
    func didSelectOneCheckbox(_ isSelected: Bool)
    func didTapChangeCountries()
    func didSearchCountry(_ searchCountry: String)
    func didSelectCountry(_ country: String)
}

public enum SendMoneyDestinationSelectionType {
    case favorite, recent, newRecipient
}

final class SendMoneyDestinationAccountPresenter {
    enum Constants {
        enum Favorites {
            static let title: String = "sendMoney_label_favoritesNumber"
            static let maxVisible: Int = 10
        }
        enum LastTransfers {
            static let title: String = "sendMoney_label_recentTranferNumber"
            static let maxVisible: Int = 20
        }
        enum Countries {
            static let maxCarouselItems: Int = 6
        }
        static let relativeURL = "RWD/country/icons/"
        static let fileExtension = ".png"
    }
    
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    weak var view: SendMoneyDestinationAccountView?
    private lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private let dependenciesResolver: DependenciesResolver
    private var filteredFavorites: [OneFavoriteContactCardViewModel] = []
    private var lastTransfersList: [OnePastTransferViewModel]?
    private var stringLoader: StringLoader {
        self.dependenciesResolver.resolve()
    }
    private var contactsEngine: ContactsEngineProtocol {
        self.dependenciesResolver.resolve(for: ContactsEngineProtocol.self)
    }
    private var provider: SendMoneyUseCaseProviderProtocol {
        self.dependenciesResolver.resolve(for: SendMoneyUseCaseProviderProtocol.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Presenter protocol
extension SendMoneyDestinationAccountPresenter: SendMoneyDestinationAccountPresenterProtocol {
    var newRecipientConfiguration: NewRecipientViewConfiguration {
        return NewRecipientViewConfiguration(dependenciesResolver: self.dependenciesResolver, countryCode: self.operativeData.country?.code ?? "")
    }
    
    func viewDidLoad() {
        if let selectedAccountViewModel = self.getSelectedAccountViewModel() {
            self.view?.showSelectedAccount(viewModel: selectedAccountViewModel)
        }
        self.getFavorites()
        self.manageLastTransfers()
        self.trackScreen()
    }
    
    func viewWillAppear() {
        self.resetCountryCode(self.operativeData.country?.name)
        self.setCurrentOperativeData()
        self.showAliasRecipient()
        self.showBankNameAndLogo()
    }
    
    func didSelectBack() {
        self.container?.back()
    }
    
    func didSelectClose() {
        self.container?.close()
    }
    
    func changeOriginAccount() {
        self.container?.back(
            to: SendMoneyAccountSelectorPresenter.self,
            creatingAt: 0,
            step: SendMoneyAccountSelectorStep(dependenciesResolver: self.dependenciesResolver))
    }
    
    func didSelectFavoriteAccount(_ cardViewModel: OneFavoriteContactCardViewModel, isFromList: Bool) {
        guard let iban = cardViewModel.payee.ibanRepresentable,
              let name = cardViewModel.payee.payeeDisplayName
        else {
            self.updateFloattingButton()
            return
        }
        self.operativeData.selectedPayee = cardViewModel.payee
        self.operativeData.destinationName = name
        self.operativeData.destinationIBANRepresentable = iban
        self.operativeData.destinationAccount = cardViewModel.payee.destinationAccount
        if isFromList {
            self.checkFavoriteSelectedAccount()
        }
        self.setFavorites()
        if isFromList {
            self.view?.scrollToSelectedFavorite()
            self.view?.closeBottomSheet()
        }
        self.operativeData.destinationSelectionType = .favorite
        self.resetScreenOperativeData([.lastTransfer, .newRecipient])
        self.updateFloattingButton()
        
        self.trackerManager.trackEvent(screenId: SendMoneyRecipientAccountPage().page,
                                       eventId: SendMoneyRecipientAccountPage.Action.selectFavourite.rawValue,
                                       extraParameters: ["transfer_country": self.operativeData.type.trackerName])
    }
    
    func didSelectSeeAllFavorites() {
        guard let fullFavorites = self.operativeData.fullFavorites else { return }
        self.view?.showAllFavorites(fullFavorites.map { self.mapToOneFavoriteContactCardViewModel(from: $0) })
        self.trackerManager.trackEvent(screenId: SendMoneyRecipientAccountPage().page,
                                       eventId: SendMoneyRecipientAccountPage.Action.viewAllFavourites.rawValue,
                                       extraParameters: ["transfer_country": self.operativeData.type.trackerName])
    }
    
    func didSearchFavorite(text: String) {
        guard let fullFavorites = self.operativeData.fullFavorites else {
            return
        }
        let favoriteContactCardViewModels = fullFavorites.map { self.mapToOneFavoriteContactCardViewModel(from: $0) }
        guard !text.isEmpty else {
            self.view?.filterFavorites(favorites: favoriteContactCardViewModels)
            return
        }
        self.filteredFavorites = favoriteContactCardViewModels.filter { $0.name.lowercased().contains(text) }
        self.view?.filterFavorites(favorites: self.filteredFavorites)
    }
    
    func didTapAddNewContact() {
        self.resetScreenOperativeData([.newRecipient])
        self.view?.closeBottomSheet()
        self.view?.toggleViews([.newRecipient])
        self.view?.setNewRecipientCheckbox(status: .activated)
        self.trackEvent(.addNewContact, parameters: [:])
    }
    
    func didSelectPastTransfer(index: Int) {
        self.operativeData.selectedLastTransferIndex = index
        self.operativeData.destinationSelectionType = .recent
        if let selectedTransfer = self.operativeData.lastTransfers?[index] {
            self.setSelectedLastTransfer(selectedTransfer)
            self.trackerManager.trackEvent(screenId: SendMoneyRecipientAccountPage().page,
                                           eventId: SendMoneyRecipientAccountPage.Action.selectRecentTransfer.rawValue,
                                           extraParameters: ["transfer_country": self.operativeData.type.trackerName])
        }
    }
    
    func getSubtitleInfo() -> String {
        self.container?.getSubtitleInfo(presenter: self) ?? ""
    }
    
    func getStepOfSteps() -> [Int] {
        self.container?.getStepOfSteps(presenter: self) ?? []
    }
    
    func didChangeNewRecipientData(_ iban: String, name: String, alias: String) {
        let numbersCharacters = iban.rangeOfCharacter(from: .decimalDigits)
        if iban.replace(" ", "") != self.operativeData.destinationIBANRepresentable?.iban.replace(" ", "") {
           self.operativeData.updateDefaultCurrency()
        }
        guard self.validateNewRecipientData(numbersCharacters: numbersCharacters, name: name, alias: alias) else { return }
        self.operativeData.destinationName = name
        self.operativeData.destinationIBANRepresentable = IBANRepresented(ibanString: iban)
        self.operativeData.destinationAccount = String(self.operativeData.destinationIBANRepresentable?.ibanString.dropFirst(2) ?? "")
        self.operativeData.destinationSelectionType = .newRecipient
        self.updateFloattingButton()
    }
    
    func didPressedFloatingButton() {
        self.goToNextStep(withNewRecipient: self.operativeData.destinationSelectionType == .newRecipient)
    }
    
    func didSelectOneCheckbox(_ isSelected: Bool) {
        self.operativeData.saveToFavorite = isSelected
        if !isSelected {
            self.operativeData.destinationAlias = nil
            self.showAliasRecipient()
        }
        self.container?.save(self.operativeData)
        self.updateFloattingButton()
    }
    
    func didTapChangeCountries() {
        self.showCountriesSelectionList()
    }
    
    func didSearchCountry(_ searchCountry: String) {
        self.setCountriesSelectionList(searchCountry)
    }
    
    func didSelectCountry(_ country: String) {
        self.resetCountryCode(country)
        self.operativeData.destinationIBANRepresentable = nil
        self.view?.closeBottomSheet()
        self.view?.setEnabledFloattingButton(false)
    }
}

// MARK: - Private logic
private extension SendMoneyDestinationAccountPresenter {
    func showBankNameAndLogo() {
        guard self.operativeData.selectedPayee == nil,
              self.operativeData.selectedLastTransferIndex == nil,
              let destinationIBANRepresentable = self.operativeData.destinationIBANRepresentable,
              let name = self.operativeData.destinationName
        else {
            self.view?.resetNewRecipient()
            return
        }
        self.view?.showBankNameAndLogo(destinationIBANRepresentable, name: name)
    }
    
    func showAliasRecipient() {
        self.view?.showAliasRecipient(saveToFavourite: self.operativeData.saveToFavorite, alias: self.operativeData.destinationAlias)
    }
    
    func setCurrentOperativeData() {
        var openedViews: [SendMoneyDestinationAccountViewController.DestinationViews] = []
        if self.operativeData.selectedPayee != nil {
            self.setFavorites()
            openedViews.append(.favorite)
        } else if let selectedLastTransferIndex = self.operativeData.selectedLastTransferIndex,
                  let selectedLastTransfer = self.operativeData.lastTransfers?[selectedLastTransferIndex] {
            self.setSelectedLastTransfer(selectedLastTransfer)
            openedViews.append(.lastTransfer)
        } else if let iban = operativeData.destinationIBANRepresentable,
                  let name = operativeData.destinationName {
            self.view?.setNewRecipientData(iban.ibanPapel, name: name, alias: self.operativeData.destinationAlias)
            openedViews.append(.newRecipient)
        }
        if openedViews.isEmpty {
            openedViews.append(.newRecipient)
        }
        self.view?.toggleViews(openedViews)
        self.updateFloattingButton()
    }
    
    func resetScreenOperativeData(_ views: [SendMoneyDestinationAccountViewController.DestinationViews]) {
        if views.contains(.favorite) {
            self.operativeData.selectedPayee = nil
            self.setFavorites()
        }
        if views.contains(.lastTransfer) {
            self.setSelectedLastTransfer(nil)
        }
        if views.contains(.newRecipient) {
            self.operativeData.saveToFavorite = false
            self.operativeData.destinationAlias = nil
            self.view?.setNewRecipientData(nil, name: nil, alias: nil)
        }
        self.updateFloattingButton()
    }
    
    func updateFloattingButton() {
        guard self.operativeData.selectedPayee != nil ||
                self.operativeData.selectedLastTransferIndex != nil ||
                self.checkBothIBANAndNameAreNotEmpty()
        else {
            self.view?.setEnabledFloattingButton(false)
            return
        }
        self.view?.setEnabledFloattingButton(true)
    }
    
    func checkBothIBANAndNameAreNotEmpty() -> Bool {
        return self.operativeData.destinationIBANRepresentable != nil &&
        self.operativeData.destinationName != nil &&
        (!self.operativeData.saveToFavorite || self.operativeData.destinationAlias != nil)
    }
    
    func validateNewRecipientData(numbersCharacters: Range<String.Index>?, name: String, alias: String) -> Bool {
        guard numbersCharacters != nil && !name.isEmpty else {
            if name.isEmpty {
                self.operativeData.destinationName = nil
            } else if numbersCharacters == nil {
                self.operativeData.destinationIBANRepresentable = nil
            }
            self.resetScreenOperativeData([.favorite, .lastTransfer])
            return false
        }
        return self.validateNewFavoriteAlias(alias)
    }
    
    func validateNewFavoriteAlias(_ alias: String) -> Bool {
        if self.operativeData.saveToFavorite {
            guard !alias.isEmpty else {
                self.operativeData.destinationAlias = nil
                self.updateFloattingButton()
                return false
            }
            self.operativeData.destinationAlias = alias
        } else {
            self.operativeData.destinationAlias = nil
        }
        return true
    }
    
    func handleUseCaseError(_ error: UseCaseError<DestinationAccountSendMoneyUseCaseErrorOutput>) {
        switch error {
        case .error(let sendMoneyError):
            guard let sendMoneyError = sendMoneyError else {
                self.view?.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
                return
            }
            self.handleSendMoneyError(sendMoneyError)
        default:
            self.view?.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
            break
        }
    }
    
    func handleSendMoneyError(_ error: DestinationAccountSendMoneyUseCaseErrorOutput) {
        switch error.error {
        case .ibanInvalid:
            self.view?.setEnabledFloattingButton(false)
            self.view?.setNewRecipientError()
        case .duplicateIban:
            self.showAliasRecipientError(helperType: .existingAccount)
        case .duplicateAlias:
            self.showAliasRecipientError(helperType: .duplicatedAlias)
        default:
            self.view?.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
            break
        }
    }
    
    func showAliasRecipientError(helperType: NewRecipientAliasHelperViewType) {
        self.view?.showAliasHelper(helperType: helperType)
        self.operativeData.destinationAlias = nil
        self.container?.save(self.operativeData)
        self.showAliasRecipient()
        self.updateFloattingButton()
    }
    
    func trackNewRecipientSent() {
        self.trackerManager.trackEvent(screenId: SendMoneyRecipientAccountPage().page,
                                       eventId: SendMoneyRecipientAccountPage.Action.selectNewRecipient.rawValue,
                                       extraParameters: ["transfer_country":self.operativeData.type.trackerName])
    }
    
    func goToNextStep(withNewRecipient: Bool) {
        let useCase = self.provider.getDestinationUseCase()
        self.view?.showLoading()
        Scenario(useCase: useCase, input: self.operativeData)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                self.container?.save(response)
                self.container?.rebuildSteps()
                self.view?.hideLoading()
                self.container?.stepFinished(presenter: self)
                if withNewRecipient {
                    self.trackNewRecipientSent()
                }
            }
            .onError { [weak self] error in
                guard let self = self else { return }
                self.view?.hideLoading()
                self.handleUseCaseError(error)
            }
    }
    
    func resetCountryCode(_ country: String?) {
        guard let countryCode = self.countryList.first(where: { $0.name == country })?.code else {
            return
        }
        self.operativeData.countryCode = countryCode
        let bankingUtils: BankingUtilsProtocol = self.dependenciesResolver.resolve()
        let isAlphanumeric = self.operativeData.country?.isAlphanumeric
        let isSepaCountry = self.operativeData.country?.sepa
        bankingUtils.setCountryCode(countryCode, isAlphanumeric: isAlphanumeric, isSepaCountry: isSepaCountry)
    }
}

// MARK: - Selected account
private extension SendMoneyDestinationAccountPresenter {
    func getSelectedAccountViewModel() -> OneAccountsSelectedCardViewModel? {
        guard let selectedAccount = self.operativeData.selectedAccount
        else { return nil }
        var originImage: String?
        if let mainAcount = self.operativeData.mainAccount, mainAcount.equalsTo(other: selectedAccount) {
            originImage = "icnHeartTint"
        }
        let amountType = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.amountToShow ?? .currentBalance
        return OneAccountsSelectedCardViewModel(
            statusCard: .contracted,
            originAccount: selectedAccount,
            originImage: originImage,
            amountToShow: amountType
        )
    }
}

// MARK: - Favorites
private extension SendMoneyDestinationAccountPresenter {
    func getFavorites() {
        self.view?.configureFavoritesView(title: self.getFavoritesTitle(), viewStatus: .loading)
        guard self.operativeData.fullFavorites == nil else {
            self.createCarouselFavorites()
            self.setFavorites()
            self.view?.scrollToSelectedFavorite()
            return
        }
        self.contactsEngine.fetchContacts { [weak self] result in
            switch result {
            case .success(let contacts):
                guard let self = self else { return }
                let filteredContacts = contacts.filter(self.shouldIncludePayee)
                self.handleFavorites(filteredContacts)
            case .failure:
                self?.setFavorites()
            }
        }
    }
    
    func shouldIncludePayee(_ payee: PayeeRepresentable) -> Bool {
        return !(payee.ibanRepresentable?.ibanString.isEmpty ?? true && payee.destinationAccount?.isEmpty ?? true)
    }
    
    func handleFavorites(_ favorites: [PayeeRepresentable]) {
        guard !favorites.isEmpty else {
            self.setFavorites()
            return
        }
        self.operativeData.fullFavorites = favorites
        self.container?.save(self.operativeData)
        self.createCarouselFavorites()
        self.setFavorites()
    }
    
    func createCarouselFavorites() {
        guard let fullFavorites = self.operativeData.fullFavorites,
              self.operativeData.carouselFavorites == nil else { return }
        let carouselFavorites = Array(fullFavorites.prefix(Constants.Favorites.maxVisible))
        self.operativeData.carouselFavorites = carouselFavorites
    }
    
    func checkFavoriteSelectedAccount() {
        guard var carouselFavorites = self.operativeData.carouselFavorites,
              let selectedPayee = self.operativeData.selectedPayee else { return }
        if let index = carouselFavorites.firstIndex(where: { $0.equalsTo(other: selectedPayee) }) {
            carouselFavorites.remove(at: index)
        } else {
            carouselFavorites = carouselFavorites.dropLast()
        }
        carouselFavorites.insert(selectedPayee, at: .zero)
        self.operativeData.carouselFavorites = carouselFavorites
    }
    
    func setFavorites() {
        guard let fullFavorites = self.operativeData.fullFavorites,
              !fullFavorites.isEmpty,
              let carouselFavorites = self.operativeData.carouselFavorites,
              !carouselFavorites.isEmpty else {
            self.view?.configureFavoritesView(title: self.getFavoritesTitle(), viewStatus: .empty)
            return
        }
        let hasSeeAll = fullFavorites.count > Constants.Favorites.maxVisible
        let sections = SendMoneyDestinationAccountFavoritesSectionBuilder(
            cards: carouselFavorites.map { self.mapToOneFavoriteContactCardViewModel(from: $0) },
            hasSeeAll: hasSeeAll)
            .buildSections()
        self.view?.configureFavoritesView(title: self.getFavoritesTitle(), viewStatus: .filled(sections: sections))
    }
    
    func getFavoritesTitle() -> LocalizedStylableText {
        let count: Int = self.operativeData.fullFavorites?.count ?? .zero
        return self.stringLoader.getString(Constants.Favorites.title,
                                           [StringPlaceholder(.number, "\(count)")])
    }
    
    func mapToOneFavoriteContactCardViewModel(from payee: PayeeRepresentable) -> OneFavoriteContactCardViewModel {
        var checkSelectedStatus: OneFavoriteContactCardViewModel.CardStatus = .inactive
        if let selectedPayee = self.operativeData.selectedPayee,
           selectedPayee.equalsTo(other: payee) {
            checkSelectedStatus = .selected
        }
        return OneFavoriteContactCardViewModel(cardStatus: checkSelectedStatus,
                                               avatar: self.getFavoriteAvatarViewModel(from: payee),
                                               payee: payee,
                                               dependenciesResolver: self.dependenciesResolver)
    }
    
    func getFavoriteAvatarViewModel(from payee: PayeeRepresentable) -> OneAvatarViewModel {
        return OneAvatarViewModel(fullName: payee.payeeDisplayName,
                                  imageUrlString: nil,
                                  image: nil,
                                  dependenciesResolver: self.dependenciesResolver)
    }
}

// MARK: - Last Transfers List
private extension SendMoneyDestinationAccountPresenter {
    
    func getLastTransferTitle() -> LocalizedStylableText {
        let count: Int = self.operativeData.lastTransfers?.count ?? 0
        return self.stringLoader.getString(Constants.LastTransfers.title, [StringPlaceholder(.number, "\(count)")])
    }
    
    func manageLastTransfers () {
        if let lastTransfers = self.operativeData.lastTransfers {
            self.setLastTranfers(lastTransfers)
            if self.operativeData.selectedLastTransferIndex != nil {
                self.view?.scrollToSelectedLastTransfer()
            }
        } else {
            self.loadLastTransfers()
        }
    }
    
    func loadLastTransfers() {
        self.view?.configureLastTransfersView(title: self.getLastTransferTitle(), viewStatus: .loading)
        let allAccounts = self.operativeData.accountVisibles + self.operativeData.accountNotVisibles
        let useCase = self.dependenciesResolver.resolve(firstTypeOf: GetAllTypesOfTransfersUseCaseProtocol.self)
        Scenario(
            useCase: useCase,
            input: GetAllTypesOfTransfersUseCaseInput(accounts: allAccounts)
        )
        .execute(on: dependenciesResolver.resolve())
        .onSuccess({ [weak self] output in
            guard let self = self else { return }
            var filteredTransfers = self.removeDuplicateTransfers(output.transfers)
            filteredTransfers = Array(filteredTransfers.prefix(Constants.LastTransfers.maxVisible))
            self.setLastTranfers(filteredTransfers)
        })
        .onError({ [weak self] _ in
            self?.setLastTranfers([])
            self?.setSelectedLastTransfer(nil)
        })
    }
    
    func removeDuplicateTransfers(_ transfers: [TransferRepresentable]) -> [TransferRepresentable] {
        var filteredTransfers: [TransferRepresentable] = []
        transfers.forEach { transfer in
            guard let transferIban = transfer.ibanRepresentable,
                  let index = filteredTransfers.firstIndex(where: { $0.ibanRepresentable?.equalsTo(other: transferIban) ?? false })
            else {
                filteredTransfers.append(transfer)
                return
            }
            if let addedTransferDate = filteredTransfers[index].transferExecutedDate,
               let transferDate = transfer.transferExecutedDate,
               addedTransferDate < transferDate {
                filteredTransfers[index] = transfer
            }
        }
        return filteredTransfers
    }
    
    func setLastTranfers(_ lastTransfers: [TransferRepresentable]?) {
        self.operativeData.lastTransfers = lastTransfers
        let viewModels = lastTransfers?.enumerated().map { index, element in
            self.getLastTransferViewModel(from: element, index: index)
        } ?? []
        let viewStatus: SendMoneyDestinationAccountLastTransfersView.ViewStatus =
            (viewModels.count == 0) ? .empty : .filled(rows: viewModels)
        self.view?.configureLastTransfersView(title: getLastTransferTitle(), viewStatus: viewStatus)
    }
    
    func getLastTransferViewModel(from transfer: TransferRepresentable, index: Int) -> OnePastTransferViewModel {
        var cardStatus: OnePastTransferViewModel.CardStatus = .inactive
        if let selectedTransferIndex = self.operativeData.selectedLastTransferIndex,
           selectedTransferIndex == index {
            cardStatus = .selected
        }
        return OnePastTransferViewModel(
            cardStatus: cardStatus,
            transfer: transfer,
            avatar: OneAvatarViewModel(fullName: transfer.name, dependenciesResolver: self.dependenciesResolver),
            dependenciesResolver: self.dependenciesResolver
        )
    }
    
    func setSelectedLastTransfer(_ selectedLastTransfer: TransferRepresentable?) {
        if selectedLastTransfer != nil {
            self.operativeData.destinationName = selectedLastTransfer?.name
            self.operativeData.destinationIBANRepresentable = selectedLastTransfer?.ibanRepresentable
            self.resetScreenOperativeData([.favorite, .newRecipient])
        } else {
            self.operativeData.selectedLastTransferIndex = nil
        }
        self.setLastTranfers(self.operativeData.lastTransfers)
    }
}

// MARK: -Tracker

extension SendMoneyDestinationAccountPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SendMoneyRecipientAccountPage {
        return SendMoneyRecipientAccountPage()
    }
}

// MARK: - Country list

private extension SendMoneyDestinationAccountPresenter {
    
    var countryList: [CountryInfoRepresentable] {
        return self.operativeData.sepaList?.allCountriesRepresentable ?? []
    }
    
    func setCountriesSelectionList(_ countrySearch: String) {
        let formattedCountrySearch = countrySearch.lowercased().deleteAccent()
        let filteredCountries = countrySearch.isEmpty ? self.countryList : self.countryList.filter { $0.name.lowercased().deleteAccent().contains(formattedCountrySearch) }
        let sortedCountries: [CountryInfoRepresentable] = filteredCountries.sorted { $0.name < $1.name }
        self.view?.setCountries(listItems: sortedCountries.map { self.mapToSelectionListViewModel($0, highlightedText: formattedCountrySearch) },
                                carouselItems: self.getCarouselCountries().map { self.mapToSelectionListViewModel($0) })
    }
    
    func showCountriesSelectionList() {
        let sortedCountries = self.countryList.sorted { $0.name < $1.name }
        self.view?.showAllCountries(listItems: sortedCountries.map { self.mapToSelectionListViewModel($0) },
                                    carouselItems: self.getCarouselCountries().map { self.mapToSelectionListViewModel($0) })
    }
    
    func mapToSelectionListViewModel(_ countryInfoRepresentable: CountryInfoRepresentable, highlightedText: String? = nil) -> OneSmallSelectorListViewModel {
        return OneSmallSelectorListViewModel(leftTextKey: countryInfoRepresentable.name,
                                             rightAccessory: .icon(imageName: getCountryFlag(countryInfoRepresentable.code)),
                                             status: self.operativeData.country?.code == countryInfoRepresentable.code ? .activated : .inactive,
                                             highlightedText: highlightedText,
                                             accessibilitySuffix: nil)
    }
    
    func getCarouselCountries() -> [CountryInfoRepresentable] {
        var carouselCountries = Array(self.countryList.prefix(Constants.Countries.maxCarouselItems))
        guard let countryCode = self.operativeData.countryCode,
              let selectedIndex = carouselCountries.firstIndex(where: { $0.code == countryCode }) else { return carouselCountries }
        let selectedItem = carouselCountries[selectedIndex]
        carouselCountries.remove(at: selectedIndex)
        carouselCountries.insert(selectedItem, at: .zero)
        return carouselCountries
    }
    
    func getCountryFlag(_ countryCode: String) -> String {
        guard let baseUrl = dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL else {
            return ""
        }
        return String(format: "%@%@%@%@",
                      baseUrl,
                      Constants.relativeURL,
                      countryCode.lowercased(),
                      Constants.fileExtension)
    }
}
