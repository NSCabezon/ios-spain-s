import SANLegacyLibrary

public struct CMPSEntity {
    let cmpsDTO: CMPSDTO?

    static public func createFromDTO(dto: CMPSDTO?) -> CMPSEntity {
        return CMPSEntity(cmpsDTO: dto)
    }

    private init(cmpsDTO: CMPSDTO?) {
        self.cmpsDTO = cmpsDTO
    }

    public var isOTPExcepted: Bool {
        return cmpsDTO?.otpExceptedInd ?? false
    }
}
