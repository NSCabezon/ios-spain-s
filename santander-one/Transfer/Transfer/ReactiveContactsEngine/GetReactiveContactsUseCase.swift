import CoreFoundationLib
import OpenCombine
import CoreDomain
import RxCombine

public protocol GetReactiveContactsUseCase {
    func fetchContacts() -> AnyPublisher<[PayeeRepresentable], Error>
}

struct DefaultGetReactiveContactsUseCase {
    private let dependencies: GetReactiveContactsUseCaseDependenciesResolver
    private let appRepositoryProtocol: AppRepositoryProtocol
    private let gpRepository: GlobalPositionDataRepository
    private let transfersRepository: TransfersRepository
    
    init(dependencies: GetReactiveContactsUseCaseDependenciesResolver) {
        self.dependencies = dependencies
        self.appRepositoryProtocol = dependencies.resolve()
        self.gpRepository = dependencies.resolve()
        self.transfersRepository = dependencies.resolve()
    }
}

extension DefaultGetReactiveContactsUseCase: GetReactiveContactsUseCase {
    func fetchContacts() -> AnyPublisher<[PayeeRepresentable], Error> {
        return loadContacts()
            .flatMap(createPublishers)
            .map(getFavoritesSorted)
            .eraseToAnyPublisher()
    }
}

// MARK: Load Contacts and Ordered Alias
private extension DefaultGetReactiveContactsUseCase {
    func loadContacts() -> AnyPublisher<(unorderedPayees: [PayeeRepresentable], orderedAlias: [String]?), Error> {
        return Publishers.Zip(
            transfersRepository.loadAllUsualTransfers(),
            loadUserPrefContacts()
        )
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    func loadUserPrefContacts() -> AnyPublisher<[String]?, Error> {
        return gpRepository
            .getGlobalPosition()
            .flatMap { globalPosition -> AnyPublisher<[String]?, Error> in
                if let userId = globalPosition.userId {
                    return appRepositoryProtocol
                        .getReactiveUserPreferences(userId: userId)
                        .map(\.pgUserPrefDTO.favoriteContacts)
                        .eraseToAnyPublisher()
                } else {
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func createPublishers(unorderedPayees: [PayeeRepresentable], orderedAlias: [String]?) -> AnyPublisher<(payees: [PayeeRepresentable], orderedAlias: [String]?), Never> {
        let list = unorderedPayees.map(self.fetchPayeeInfo)
        return Publishers.MergeMany(list)
            .collect()
            .map { list in
                return (list.compactMap { $0 }, orderedAlias)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchPayeeInfo(_ payee: PayeeRepresentable) -> AnyPublisher<PayeeRepresentable?, Never> {
        let publisher: AnyPublisher<PayeeRepresentable?, Never>
        if payee.isNoSepa {
            publisher = fetchNoSepaDetail(of: payee)
        } else {
            publisher = Just(payee).eraseToAnyPublisher()
        }
        return publisher
    }
}

// MARK: No Sepa Detail Fetcher
private extension DefaultGetReactiveContactsUseCase {
    
    /// Fetch the detail of the contact
    /// - Parameter contact: The contact to load the No Sepa Detail
    func fetchNoSepaDetail(of contact: PayeeRepresentable) -> AnyPublisher<PayeeRepresentable?, Never> {
        return transfersRepository.noSepaPayeeDetail(
            of: contact.payeeAlias ?? "",
            recipientType: contact.recipientType ?? ""
        )
            .compactMap(\.payeeRepresentable)
            .map { noSepaDetail in
                return handleNoSepaPayeeDetail(noSepaDetail, of: contact)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    /// Method to handle the result of the No Sepa Detail request. Once we have the result, we have to update the `countryCode` of the Favorite.
    /// - Parameters:
    ///   - contact: The contact
    ///   - result: The result of the detail request
    func handleNoSepaPayeeDetail(_ result: NoSepaPayeeRepresentable, of contact: PayeeRepresentable) -> PayeeRepresentable {
        let destinationCountryCode: String = {
            guard let bankCountryCode = result.bankCountryCode,
                  !bankCountryCode.isEmpty
            else { return result.countryCode ?? "" }
            return bankCountryCode
        }()
        var contact = contact
        contact.countryCode = destinationCountryCode
        return contact
    }
}

// MARK: Sorting
private extension DefaultGetReactiveContactsUseCase {
    func getFavoritesSorted(favorites: [PayeeRepresentable], favoriteContacts: [String]?) -> [PayeeRepresentable] {
        guard let favoriteContacts = favoriteContacts else { return favorites }
        let favoriteContactsNotEmpty =  favoriteContacts.filter {!$0.isEmpty}
        let sortedFavorites = favoriteContactsNotEmpty.compactMap { (contact) -> PayeeRepresentable? in
            return favorites.first { contact == $0.payeeAlias }
        }
        let restFavorites = favorites.filter { favorite in return !sortedFavorites.contains { favorite.payeeAlias == $0.payeeAlias } }
        return sortedFavorites + restFavorites
    }
}
