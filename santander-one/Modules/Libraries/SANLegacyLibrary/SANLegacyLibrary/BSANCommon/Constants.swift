import Foundation

public class Constants {
    // OAuth
    public static let SCOPE: String = "core.read core.change";
    public static let GRANT_TYPE: String = "password";
    public static let TICKER_IBEX: String = "IBEX";
    public static let NAME_IBEX: String = "IBEX 35";
    public static let TICKER_SAN: String = "SAN S";
    public static let NAME_SAN: String = "SANTANDER";

    // Http Errors
    public static let UNAUTHORIZED: Int = 401;

}

public struct OTPErrorMessages {
    public static let otpFailed1 = "clave de otp erronea"
    public static let otpFailed2 = "clave otp erronea"
    public static let otpFailed3 = "clave de otp incorrecta"
    public static let otpFailed4 = "el codigo de otp no es valido"
    public static let otpFailed5 = "la clave otp es erronea"
    public static let otpFailed6 = "security otp is not ok"
    public static let otpFailed7 = "sca operation invalid"
    public static let otpRevoked = "la clave otp esta revocada"
    public static let otpExpired = "la clave otp ha expirado"
}
