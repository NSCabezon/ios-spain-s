//
//  LoadPullOffersVarsUseCaseProtocol.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 15/9/21.
//

import SANLegacyLibrary
import Foundation

public protocol LoadPullOffersVarsUseCaseProtocol: UseCase<Void, Void, StringErrorOutput> {}

final class DefaultLoadPullOffersVarsUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let vars: [String: Any] = try segmentVars() + privateBankingVars() + globalPositionTypeVars() + otherVars() + smartVars()
        let productVars: [String: Any] = try accountVars() + stockVars() + loansVars()
        let creditCardVars: [String: Any] = try cardsVars() + self.creditCardVars()
        let otherProductVars: [String: Any] = try pensionsVars() + fundsVars() + depositsVars()
        pullOffersEngine.addRules(rules: vars + productVars + creditCardVars + otherProductVars)
        return .ok()
    }
}

private extension DefaultLoadPullOffersVarsUseCase {
    
    func segmentVars() throws -> [String: Any] {
        let userSegment = try checkRepositoryResponse(provider.getBsanUserSegmentManager().getUserSegment())
        guard let segmentDTO = userSegment else { return [:] }
        return values(for: [
            "PSE": .escapedString(segmentDTO.bdpSegment?.clientSegment?.segment),
            "PSC": .escapedString(segmentDTO.commercialSegment?.clientSegment?.segment),
            "PSSOC": .boolean(segmentDTO.indCollectiveS),
            "PSSOCA": .boolean(segmentDTO.indCollectiveSFreelance),
            "PSSOCE": .boolean(segmentDTO.indCollectiveSCompanies)
        ])
    }
    
    func smartVars() throws -> [String: Any] {
        let userSegment = try checkRepositoryResponse(provider.getBsanUserSegmentManager().getUserSegment())
        return values(for: [
            "COL_SMART_PREMIUM": .boolean(userSegment?.colectivo123Smart ?? false),
            "COL_SMART_FREE": .boolean(userSegment?.colectivo123SmartFree ?? false)
        ])
    }
    
    func privateBankingVars() throws -> [String: Any] {
        let isPb = try checkRepositoryResponse(provider.getBsanSessionManager().isPB())
        guard isPb == true else { return [:] }
        return values(for: [
            "PSE": .escapedString("PB"),
            "PSC": .escapedString("PB")
        ])
    }
    
    func globalPositionTypeVars() throws -> [String: Any] {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve()
        let userPrefs = appRepository.getUserPreferences(userId: globalPosition.userId ?? "")
        switch userPrefs.pgUserPrefDTO.globalPositionOptionSelected {
        case 0:
            return [
                "PG_TYPE": "\"CLASSIC\""
            ]
        case 1:
            return [
                "PG_TYPE": "\"SIMPLE\""
            ]
        case 2:
            return [
                "PG_TYPE": "\"SMART\""
            ]
        default:
            return [
                "PG_TYPE": "\"CLASSIC\""
            ]
        }
    }
    
    func accountVars() throws -> [String: Any] {
        let counterValueForAllAccounts = globalPosition.accounts.totalOfVisibles { $0.getCounterValueAmountValue() }.doubleValue
        let valueForAllAccounts = globalPosition.accounts.totalOfVisibles { $0.availableAmount?.value }.doubleValue
        return values(for: [
            "PCN": .integer(globalPosition.accounts.all().count),
            "PCS": .double(enabledCounterValue ? counterValueForAllAccounts : valueForAllAccounts),
            "PCA": .double(globalPosition.accounts.firstSorted(by: \.currentBalanceAmount?.value).doubleValue),
            "PCB": .double(globalPosition.accounts.lastSorted(by: \.currentBalanceAmount?.value).doubleValue),
            "PCD": .escapedString(globalPosition.accounts.visibles().map({ $0.dto.alias ?? "" }).joined(separator: ";"))
        ])
    }
    
    func stockVars() throws -> [String: Any] {
        let counterValueForAllAccounts = globalPosition.stockAccounts.totalOfVisibles { $0.counterValueAmount }.doubleValue
        let valueForAllAccounts = globalPosition.stockAccounts.totalOfVisibles { $0.amount?.value }.doubleValue
        return values(for: [
            "PVN": .integer(globalPosition.stockAccounts.all().count),
            "PVS": .double(enabledCounterValue ? counterValueForAllAccounts : valueForAllAccounts),
            "PVA": .double(globalPosition.stockAccounts.firstSorted(by: \.amount?.value).doubleValue),
            "PVB": .double(globalPosition.stockAccounts.lastSorted(by: \.amount?.value).doubleValue),
            "PVD": .escapedString(globalPosition.stockAccounts.visibles().map({ $0.representable.alias ?? "" }).joined(separator: ";"))
        ])
    }
    
    func loansVars() throws -> [String: Any] {
        let counterValueForAllAccounts = globalPosition.loans.totalOfVisibles { $0.counterValueCurrentBalanceAmount }.doubleValue
        let valueForAllAccounts = globalPosition.loans.totalOfVisibles { $0.currentBalanceAmount?.value }.doubleValue
        return values(for: [
            "PRN": .integer(globalPosition.loans.all().count),
            "PRS": .double(enabledCounterValue ? counterValueForAllAccounts : valueForAllAccounts),
            "PRA": .double(globalPosition.loans.firstSorted(by: \.currentBalanceAmount?.value).doubleValue),
            "PRB": .double(globalPosition.loans.lastSorted(by: \.currentBalanceAmount?.value).doubleValue),
            "PRD": .escapedString(globalPosition.loans.visibles().map({ $0.alias ?? "" }).joined(separator: ";"))
        ])
    }
    
    func depositsVars() throws -> [String: Any] {
        let counterValueForAllAccounts = globalPosition.deposits.totalOfVisibles { $0.counterValueCurrentBalance }.doubleValue
        let valueForAllAccounts = globalPosition.deposits.totalOfVisibles { $0.amount?.value }.doubleValue
        return values(for: [
            "PDN": .integer(globalPosition.deposits.all().count),
            "PDS": .double(enabledCounterValue ? counterValueForAllAccounts : valueForAllAccounts),
            "PDA": .double(globalPosition.deposits.firstSorted(by: \.amount?.value).doubleValue),
            "PDB": .double(globalPosition.deposits.lastSorted(by: \.amount?.value).doubleValue),
            "PDD": .escapedString(globalPosition.deposits.visibles().map({ $0.dto.alias ?? "" }).joined(separator: ";"))
        ])
    }
    
    func fundsVars() throws -> [String: Any] {
        let counterValueForAllAccounts = globalPosition.funds.totalOfVisibles { $0.counterValueAmount }.doubleValue
        let valueForAllAccounts = globalPosition.funds.totalOfVisibles { $0.amount?.value }.doubleValue
        return values(for: [
            "PFN": .integer(globalPosition.funds.all().count),
            "PFS": .double(enabledCounterValue ? counterValueForAllAccounts : valueForAllAccounts),
            "PFA": .double(globalPosition.funds.firstSorted(by: \.amount?.value).doubleValue),
            "PFB": .double(globalPosition.funds.lastSorted(by: \.amount?.value).doubleValue),
            "PFD": .escapedString(globalPosition.funds.visibles().map({ $0.dto.alias ?? "" }).joined(separator: ";"))
        ])
    }
    
    func pensionsVars() throws -> [String: Any] {
        let counterValueForAllAccounts = globalPosition.pensions.totalOfVisibles { $0.counterValueAmount }.doubleValue
        let valueForAllAccounts = globalPosition.pensions.totalOfVisibles { $0.amount?.value }.doubleValue
        return values(for: [
            "PPN": .integer(globalPosition.pensions.all().count),
            "PPS": .double(enabledCounterValue ? counterValueForAllAccounts : valueForAllAccounts),
            "PPA": .double(globalPosition.pensions.firstSorted(by: \.amount?.value).doubleValue),
            "PPB": .double(globalPosition.pensions.lastSorted(by: \.amount?.value).doubleValue),
            "PPD": .escapedString(globalPosition.pensions.visibles().map({ $0.dto.alias ?? "" }).joined(separator: ";"))
        ])
    }
    
    func cardsVars() throws -> [String: Any] {
        return values(for: [
            "PTTD": .escapedString(globalPosition.cards.visibles().map({ $0.dto.alias ?? "" }).joined(separator: ";")),
            "PTTN": .integer(globalPosition.cards.all().count),
            "PTDN": .integer(globalPosition.cards.visibles().filter({ $0.isDebitCard }).count),
            "PTEN": .integer(globalPosition.cards.visibles().filter({ $0.isPrepaidCard }).count),
            "PTINAC": .integer(globalPosition.cards.visibles().filter({ $0.isInactive }).count),
            "PTEA": .double(globalPosition.cards.firstSorted(by: \.amount?.value, where: { $0.isPrepaidCard }).doubleValue),
            "PTEB": .double(globalPosition.cards.lastSorted(by: \.amount?.value, where: { $0.isPrepaidCard }).doubleValue),
            "PTES": .double(globalPosition.cards.totalOfVisibles(value: { $0.amount?.value }, where: { $0.isPrepaidCard }).doubleValue)
        ])
    }
    
    func creditCardVars() throws -> [String: Any] {
        return values(for: [
            "PTCN": .integer(globalPosition.cards.visibles().filter({ $0.isCreditCard }).count),
            "PTPL": .integer(globalPosition.cards.visibles().filter({ $0.isCreditCard && $0.allowsPayLater }).count),
            "PTDD": .integer(globalPosition.cards.visibles().filter({ $0.isCreditCard && $0.allowsDirectMoney }).count),
            "PTCA": .double(globalPosition.cards.firstSorted(by: \.amount?.value, where: { $0.isCreditCard }).doubleValue),
            "PTCB": .double(globalPosition.cards.lastSorted(by: \.amount?.value, where: { $0.isCreditCard }).doubleValue),
            "PTCS": .double(globalPosition.cards.totalOfVisibles(value: { $0.amount?.value }, where: { $0.isCreditCard }).doubleValue)
        ])
    }
    
    func otherVars() throws -> [String: Any] {
        let campaigns = try checkRepositoryResponse(provider.getBsanPullOffersManager().getCampaigns())
        let userBirthDate = globalPosition.clientBirthDate
        let calendar = Calendar(identifier: .gregorian)
        return values(for: [
            "BOTES": .array(campaigns??.map({ "\"\($0)\"" })),
            "NACDM": .integer(userBirthDate.map({ calendar.component(.day, from: $0) }) ?? 0),
            "NACMA": .integer(userBirthDate.map({ calendar.component(.month, from: $0) }) ?? 0),
            "NACMY": .integer(userBirthDate.map({ calendar.component(.year, from: $0) }) ?? 0)
        ])
    }
    
    func values(for dictionary: [String: Var]) -> [String: Any] {
        return dictionary.compactMapValues({ $0.value() })
    }
    
    enum Var {
        case string(String?)
        case escapedString(String?)
        case boolean(Bool?)
        case integer(Int)
        case double(Double)
        case array([String]?)
        
        func value() -> Any? {
            switch self {
            case .escapedString(let value):
                return value.map({ "\"\($0)\"" })
            case .boolean(let value):
                guard let boolean = value else { return nil }
                return boolean ? "true" : "false"
            case .string(let value):
                return value
            case .integer(let value):
                return value
            case .double(let value):
                return value
            case .array(let value):
                return value
            }
        }
    }
    
    var provider: BSANManagersProvider {
        return dependenciesResolver.resolve()
    }
    
    var appConfigRepository: AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    var appRepository: AppRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    var accountDescriptorRepository: AccountDescriptorRepository {
        return dependenciesResolver.resolve()
    }
    
    var servicesForYouRepository: ServicesForYouRepository {
        return dependenciesResolver.resolve()
    }
    
    var pullOffersEngine: EngineInterface {
        return dependenciesResolver.resolve()
    }
    
    var enabledCounterValue: Bool {
        return dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self).getBool("enabledCounterValue") ?? false
    }
    
    var globalPosition: GlobalPositionWithUserPrefsRepresentable {
        return dependenciesResolver.resolve()
    }
}

extension DefaultLoadPullOffersVarsUseCase: LoadPullOffersVarsUseCaseProtocol {}

private extension Dictionary where Key == String, Value == Any {
    
    static func + (lhs: Self, rhs: Self) -> [String: Any] {
        return lhs.merging(rhs, uniquingKeysWith: { first, _ in return first })
    }
}
