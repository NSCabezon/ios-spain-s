import SANLegacyLibrary

struct SignatureData {
    let signatureDataDTO: SignatureDataDTO
    
    func isSignatureActivationPending() -> Bool {
        let isConsultive = signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "C"
        let isConsultiveUserType = signatureDataDTO.list?.first?.advisoryUserInd == "6"
        let caseA4 = signatureDataDTO.signatureActivityStatusInd?.uppercased() == "A" && signatureDataDTO.signaturePhaseStatusInd == "4"
        let caseI1 = signatureDataDTO.signatureActivityStatusInd?.uppercased() == "I" && signatureDataDTO.signaturePhaseStatusInd == "1"
        return (caseA4 || caseI1) && isConsultive && isConsultiveUserType
    }
}
