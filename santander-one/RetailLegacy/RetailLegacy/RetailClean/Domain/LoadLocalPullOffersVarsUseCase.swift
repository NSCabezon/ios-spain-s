import CoreFoundationLib
import SANLegacyLibrary

import Foundation

class LoadLocalPullOffersVarsUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let servicesForYouRepository: ServicesForYouRepository
    private let pullOffersEngine: EngineInterface
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, servicesForYouRepository: ServicesForYouRepository, pullOffersEngine: EngineInterface, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.servicesForYouRepository = servicesForYouRepository
        self.pullOffersEngine = pullOffersEngine
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var localPullOffersVarsModifier: LocalPullOffersVarsModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: LocalPullOffersVarsModifierProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        var output = [String: Any]()
        
        //PG VARS
        if let pg = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()) {
            //GlobalPositionWrapper
            guard let pgWrapper = try GlobalPositionWrapperFactory.getWrapper(
                    bsanManagersProvider: provider,
                    appRepository: appRepository,
                    accountDescriptorRepository: accountDescriptorRepository,
                    appConfigRepository: appConfigRepository) else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let userSegmentDTO = try checkRepositoryResponse(provider.getBsanUserSegmentManager().getUserSegment())
            
            //REGLAS SEGMENTO DE CLIENTE
            if let segmentDTO = userSegmentDTO {
                if self.localPullOffersVarsModifier != nil  {
                    self.localPullOffersVarsModifier?.getClientSegmentName { clientSegment in
                        output["PT_SEG"] = self.getEscapedString(string: clientSegment)
                    }
                }
                if let clientSegment = segmentDTO.bdpSegment?.clientSegment?.segment {
                    output["PSE"] = getEscapedString(string: clientSegment)
                }
                
                if let clientSegment = segmentDTO.commercialSegment?.clientSegment?.segment {
                    output["PSC"] = getEscapedString(string: clientSegment)
                }
                
                if let indCollectiveS = segmentDTO.indCollectiveS {
                    output["PSSOC"] = indCollectiveS ? "true" : "false"
                }
                
                if let indCollectiveSFreelance = segmentDTO.indCollectiveSFreelance {
                    output["PSSOCA"] = indCollectiveSFreelance ? "true" : "false"
                }
                
                if let indCollectiveSCompanies = segmentDTO.indCollectiveSCompanies {
                    output["PSSOCE"] = indCollectiveSCompanies ? "true" : "false"
                }
            }
            
            let isPb = try checkRepositoryResponse(provider.getBsanSessionManager().isPB())
            
            if isPb == true {
                output["PSE"] = getEscapedString(string: "PB")
                output["PSC"] = getEscapedString(string: "PB")
            }
            
            //TIPO DE PG
            if let userPrefs = try appRepository.getUserPrefDTO(userId: pgWrapper.userId).getResponseData() {
                switch userPrefs.pgUserPrefDTO.globalPositionOptionSelected {
                case 0:
                    output["PG_TYPE"] = getEscapedString(string: "CLASSIC")
                case 1:
                    output["PG_TYPE"] = getEscapedString(string: "SIMPLE")
                case 2:
                    output["PG_TYPE"] = getEscapedString(string: "SMART")
                default:
                    output["PG_TYPE"] = getEscapedString(string: "CLASSIC")
                }
            }
            
            //CUENTAS
            output["PCN"] = pg.accounts?.count ?? 0
            output["PCS"] = (try? pgWrapper.accounts.getTotalAmount(nil, pgWrapper.globalPositionConfig.enableCounterValue ??  false).value?.doubleValue ?? 0) ?? 0
            output["PCA"] = pgWrapper.accounts.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PCB"] = pgWrapper.accounts.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            output["PCD"] = getEscapedString(string: pgWrapper.accounts.list.map({$0.getAlias() ?? ""}).joined(separator: ";"))
            
            //VALORES
            output["PVN"] = pg.stockAccounts?.count ?? 0
            output["PVS"] = (try? pgWrapper.stockAccounts.getTotalAmount(nil, pgWrapper.globalPositionConfig.enableCounterValue ?? false).value?.doubleValue ?? 0) ?? 0
            output["PVA"] = pgWrapper.stockAccounts.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PVB"] = pgWrapper.stockAccounts.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            output["PVD"] = getEscapedString(string: pgWrapper.stockAccounts.list.map({$0.getAlias()}).joined(separator: ";"))
            
            //PRESTAMOS
            output["PRN"] = pg.loans?.count ?? 0
            output["PRS"] = (try? pgWrapper.loans.getTotalAmount(nil, pgWrapper.globalPositionConfig.enableCounterValue ?? false).value?.doubleValue ?? 0) ?? 0
            output["PRA"] = pgWrapper.loans.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PRB"] = pgWrapper.loans.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            output["PRD"] = getEscapedString(string: pgWrapper.loans.list.map({$0.getAlias() ?? ""}).joined(separator: ";"))
            
            //DEPOSITOS
            output["PDN"] = pg.deposits?.count ?? 0
            output["PDS"] = (try? pgWrapper.deposits.getTotalAmount(nil, pgWrapper.globalPositionConfig.enableCounterValue ?? false).value?.doubleValue ?? 0) ?? 0
            output["PDA"] = pgWrapper.deposits.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PDB"] = pgWrapper.deposits.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            output["PDD"] = getEscapedString(string: pgWrapper.deposits.list.map({$0.getAlias() ?? ""}).joined(separator: ";"))
            
            //FONDOS
            output["PFN"] = pg.funds?.count ?? 0
            output["PFS"] = (try? pgWrapper.funds.getTotalAmount(nil, pgWrapper.globalPositionConfig.enableCounterValue ?? false).value?.doubleValue ?? 0) ?? 0
            output["PFA"] = pgWrapper.funds.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PFB"] = pgWrapper.funds.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            output["PFD"] = getEscapedString(string: pgWrapper.funds.list.map({$0.getAlias() ?? ""}).joined(separator: ";"))
            
            //PLANES
            output["PPN"] = pg.pensions?.count ?? 0
            output["PPS"] = (try? pgWrapper.pensions.getTotalAmount(nil, pgWrapper.globalPositionConfig.enableCounterValue ?? false).value?.doubleValue ?? 0) ?? 0
            output["PPA"] = pgWrapper.pensions.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PPB"] = pgWrapper.pensions.list.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            output["PPD"] = getEscapedString(string: pgWrapper.pensions.list.map({$0.getAlias() ?? ""}).joined(separator: ";"))
            
            //TARJETAS
            output["PTTD"] = getEscapedString(string: pgWrapper.cards.list.map({$0.getAlias()}).joined(separator: ";"))
            output["PTTN"] = pg.cards?.count ?? 0
            output["PTCN"] = pgWrapper.cards.list.filter({$0 is CreditCard}).count
            output["PTDN"] = pgWrapper.cards.list.filter({$0 is DebitCard}).count
            output["PTEN"] = pgWrapper.cards.list.filter({$0 is PrepaidCard}).count
            output["PTINAC"] = pgWrapper.cards.list.filter({$0.isInactive}).count
            output["PTPL"] = pgWrapper.cards.list.filter({$0 is CreditCard && ($0 as! CreditCard).allowPayLater}).count
            output["PTDD"] = pgWrapper.cards.list.filter({$0 is CreditCard && ($0 as! CreditCard).allowDirectMoney}).count
            output["PTCA"] = pgWrapper.cards.list.sorted(by: {($0 is CreditCard && $0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PTCB"] = pgWrapper.cards.list.sorted(by: {($0 is CreditCard && $0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            let disposed = pgWrapper.cards.list.filter({$0 is CreditCard}).map({$0.getAmountValue()?.doubleValue ?? 0})
            output["PTCS"] = disposed.reduce(0, {($0 + $1)})
            output["PTEA"] = pgWrapper.cards.list.sorted(by: {($0 is PrepaidCard && $0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
            output["PTEB"] = pgWrapper.cards.list.sorted(by: {($0 is PrepaidCard && $0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
            let availablesECash = pgWrapper.cards.list.filter({$0 is PrepaidCard}).map({$0.getAmountValue()?.doubleValue ?? 0})
            output["PTES"] = availablesECash.reduce(0, {($0 + $1)})
            
            output["COL_SMART_PREMIUM"] = userSegmentDTO?.colectivo123Smart ?? false
            output["COL_SMART_FREE"] = userSegmentDTO?.colectivo123SmartFree ?? false
            
            if let campaigns = try checkRepositoryResponse(provider.getBsanPullOffersManager().getCampaigns()) {
                output["BOTES"] = campaigns?.map { "\"\($0)\""}
            } else {
                output["BOTES"] = nil
            }
            
            // USER BIRTHDATE
            
            let calendar = Calendar(identifier: .gregorian)
            if let userBirthDate = pg.clientBirthDate {
                output["NACDM"] = calendar.component(.day, from: userBirthDate)
                output["NACMA"] = calendar.component(.month, from: userBirthDate)
                output["NACMY"] = calendar.component(.year, from: userBirthDate)
            } else {
                output["NACDM"] = 0
                output["NACMA"] = 0
                output["NACMY"] = 0
            }
        }
        pullOffersEngine.addRules(rules: output)
        return UseCaseResponse.ok()
    }
    
    private func getEscapedString(string: String) -> String {
        return "\"\(string)\""
    }
}
