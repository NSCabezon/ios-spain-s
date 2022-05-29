import AudioToolbox

public struct HapticTrigger {
    
    public static func operativeSuccess() {
        HapticTrigger.executePop()
    }
    
    public static func operativeError() {
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 1...2 {
                HapticTrigger.executePeek()
                usleep(200000)
            }
        }
    }
    
    public static func loginSuccess() {
        HapticTrigger.executePop()
    }
    
    public static func alert() {
        HapticTrigger.executePeek()
    }
    
    public static func alertMedium() {
        HapticTrigger.executeMediumVibration()
    }
    
    private static func executePeek() {
        AudioServicesPlaySystemSound(1519)
    }
    
    private static func executePop() {
        AudioServicesPlaySystemSound(1520)
    }
    
    private static func executeThree() {
        AudioServicesPlaySystemSound(1521)
    }
    
    private static func executeMediumVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private static func executeLongVibration() {
        AudioServicesPlaySystemSound(4095)
    }
    
    private static func executeSMSReceivedVibration() {
        AudioServicesPlaySystemSound(1011)
    }
    
}
