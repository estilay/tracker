import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "AppMetricaAPIKey") as? String,
            !apiKey.isEmpty,
            let configuration = AppMetricaConfiguration(apiKey: apiKey)
        else {
            assertionFailure("AppMetricaAPIKey not found in Info.plist")
            return
        }
        configuration.handleFirstActivationAsUpdate = true
        AppMetrica.activate(with: configuration)
    }

    func report(event: String, params: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}

// MARK: - Event Names
extension AnalyticsService {
    enum Event: String {
        case open
        case close
        case click
    }
    
    enum Screen: String {
        case main = "Main"
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
}

// MARK: - AnalyticsService Helper
extension AnalyticsService {
    func reportOpen(screen: Screen) {
        let name = "\(screen.rawValue.lowercased())_\(Event.open.rawValue)"
        report(
            event: name,
            params: [
                "event": Event.open.rawValue,
                "screen": screen.rawValue
            ]
        )
    }
    
    func reportClose(screen: Screen) {
        let name = "\(screen.rawValue.lowercased())_\(Event.close.rawValue)"
        report(
            event: name,
            params: [
                "event": Event.close.rawValue,
                "screen": screen.rawValue
            ]
        )
    }
    
    func reportClick(screen: Screen, item: Item) {
        let name = "\(item.rawValue)_\(Event.click.rawValue)"
        report(
            event: name,
            params: [
                "event": Event.click.rawValue,
                "screen": screen.rawValue,
                "item": item.rawValue
            ]
        )
    }
}
