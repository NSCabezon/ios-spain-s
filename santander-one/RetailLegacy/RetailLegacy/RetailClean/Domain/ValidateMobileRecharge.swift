import SANLegacyLibrary

struct ValidateMobileRecharge: OperativeParameter {
    let validateMobileRechargeDto: ValidateMobileRechargeDTO
    var signatureWithToken: SignatureWithToken? {
        guard let signatureDTO = validateMobileRechargeDto.signatureWithTokenDTO else {
            return nil
        }
        return SignatureWithToken(dto: signatureDTO)
    }
}
