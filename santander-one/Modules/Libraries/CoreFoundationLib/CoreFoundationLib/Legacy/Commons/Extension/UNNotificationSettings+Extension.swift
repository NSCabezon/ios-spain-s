import UserNotifications

public extension UNNotificationSettings {
    var isAnySettingAvailable: Bool {
        return [self.alertSetting, self.badgeSetting, self.lockScreenSetting, self.notificationCenterSetting, self.soundSetting].contains(.enabled)
    }
}
