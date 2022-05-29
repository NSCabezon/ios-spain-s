import Foundation
import SANLegacyLibrary

public class BSANInsurancesManagerImplementation: BSANBaseManager, BSANInsurancesManager {
    
    private let webServicesUrlProvider: WebServicesUrlProvider
    private let sanRestServices: SanRestServices
    private let bsanAuthManager: BSANAuthManager
    
    public init(bsanDataProvider: BSANDataProvider, bsanAuthManager: BSANAuthManager, sanRestServices: SanRestServices, webServicesUrlProvider: WebServicesUrlProvider) {
        self.sanRestServices = sanRestServices
        self.bsanAuthManager = bsanAuthManager
        self.webServicesUrlProvider = webServicesUrlProvider
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    private func initManager() throws{
        _ = try bsanDataProvider.getEnvironment()
        _ = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        _ = try bsanDataProvider.getBsanHeaderData()
        if authCredentials.apiTokenCredential == nil {
            try bsanAuthManager.requestOAuth()
        }
    }
    
    public func getInsuranceData(contractId: String) throws -> BSANResponse<InsuranceDataDTO> {
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        let trimmedString = contractId.trimmingCharacters(in: CharacterSet.whitespaces)
        let insuranceData = try bsanDataProvider.get(\.insuranceInfo).insuranceData[trimmedString]
        
        if let insuranceData = insuranceData {
            return BSANOkResponse(insuranceData)
        }
        
        let insuranceDataSource = InsuranceDataSourceImpl(sanRestServices: sanRestServices)
        let insuranceDataDTOResponse = try insuranceDataSource.getInsuranceData(absoluteUrl: webServicesUrlProvider.getInsuranceDataUrl(contractId: trimmedString))
        
        if let insuranceDataDTO = try insuranceDataDTOResponse.getResponseData(){
            bsanDataProvider.storeInsuranceData(contractId: trimmedString, insuranceDataDTO: insuranceDataDTO)
        }
        
        return insuranceDataDTOResponse
    }
    
    public func getParticipants(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceParticipantDTO]> {
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        let participants = try bsanDataProvider.get(\.insuranceInfo).participants[policyId]
        
        if let participants = participants {
            return BSANOkResponse(participants)
        }
        
        let insuranceDataSource = InsuranceDataSourceImpl(sanRestServices: sanRestServices)
        let insuranceParticipantsListDTOResponse = try insuranceDataSource.getParticipants(absoluteUrl: webServicesUrlProvider.getParticipantsUrl(policyId: policyId), familyId: familyId, thirdPartyInd: thirdPartyInd, factoryPolicyNumber: factoryPolicyNumber, contractId: contractId)
        
        if insuranceParticipantsListDTOResponse.isSuccess(){
            if let insuranceParticipantsListDTO = try insuranceParticipantsListDTOResponse.getResponseData(){
                bsanDataProvider.storeInsuranceParticipants(policyId: policyId, insuranceParticipantsList: insuranceParticipantsListDTO)
            }
        }
        
        return insuranceParticipantsListDTOResponse
    }
    
    public func getBeneficiaries(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceBeneficiaryDTO]> {
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        let beneficiaries = try bsanDataProvider.get(\.insuranceInfo).beneficiaries[policyId]
        
        if let beneficiaries = beneficiaries {
            return BSANOkResponse(beneficiaries)
        }
        
        let insuranceDataSource = InsuranceDataSourceImpl(sanRestServices: sanRestServices)
        let insuranceBeneficiariesListDTOResponse = try insuranceDataSource.getBeneficiaries(absoluteUrl: webServicesUrlProvider.getBeneficiariesUrl(policyId: policyId), familyId: familyId, thirdPartyInd: thirdPartyInd, factoryPolicyNumber: factoryPolicyNumber, contractId: contractId)
        
        if insuranceBeneficiariesListDTOResponse.isSuccess(){
            if let insuranceBeneficiariesListDTO = try insuranceBeneficiariesListDTOResponse.getResponseData(){
                bsanDataProvider.storeInsuranceBeneficiaries(policyId: policyId, insuranceBeneficiariesList: insuranceBeneficiariesListDTO)
            }
        }
        
        return insuranceBeneficiariesListDTOResponse
    }
    
    public func getCoverages(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceCoverageDTO]> {
        do {
            try initManager()
        }
        catch {
            return BSANErrorResponse(nil)
        }
        
        let coverages = try bsanDataProvider.get(\.insuranceInfo).coverages[policyId]
        
        if let coverages = coverages {
            return BSANOkResponse(coverages)
        }
        
        let insuranceDataSource = InsuranceDataSourceImpl(sanRestServices: sanRestServices)
        let insuranceCoveragesListDTOResponse = try insuranceDataSource.getCoverages(absoluteUrl: webServicesUrlProvider.getCoveragesUrl(policyId: policyId), familyId: familyId, thirdPartyInd: thirdPartyInd, factoryPolicyNumber: factoryPolicyNumber, contractId: contractId)
        
        if insuranceCoveragesListDTOResponse.isSuccess(){
            if let insuranceCoveragesListDTO = try insuranceCoveragesListDTOResponse.getResponseData(){
                bsanDataProvider.storeInsuranceCoverages(policyId: policyId, insuranceCoveragesList: insuranceCoveragesListDTO)
            }
        }
        
        return insuranceCoveragesListDTOResponse
    }
}
