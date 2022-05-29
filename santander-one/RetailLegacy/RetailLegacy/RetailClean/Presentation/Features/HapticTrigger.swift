import AudioToolbox

struct HapticTrigger {
    
    static func operativeSuccess() {
        HapticTrigger.executePop()
    }
    
    static func operativeError() {
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 1...2 {
                HapticTrigger.executePeek()
                usleep(200000)
            }
        }
    }
    
    static func loginSuccess() {
        HapticTrigger.executePop()
    }
    
    static func alert() {
        HapticTrigger.executePeek()
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
    
    private static func executeLongVibration() {
        AudioServicesPlaySystemSound(4095)
    }
    
    private static func executeSMSReceivedVibration() {
        AudioServicesPlaySystemSound(1011)
    }
    
}
