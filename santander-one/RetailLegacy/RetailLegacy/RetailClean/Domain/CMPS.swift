import SANLegacyLibrary

struct CMPS {

    let cmpsDTO: CMPSDTO?

    static func createFromDTO(dto: CMPSDTO?) -> CMPS {
        return CMPS(cmpsDTO: dto)
    }

    private init(cmpsDTO: CMPSDTO?) {
        self.cmpsDTO = cmpsDTO
    }

    var isOTPExcepted: Bool {
        return cmpsDTO?.otpExceptedInd ?? false
    }

}
