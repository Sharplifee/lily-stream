import Foundation

struct StreamCredentials: Decodable {
    let url: String
    let token: String
}

/// Calls the Supabase edge function that holds the LiveKit API secret.
enum TokenService {
    static func mint(roomID: String, publish: Bool) async throws -> StreamCredentials {
        guard let endpoint = Config.tokenEndpoint else {
            throw NSError(domain: "LilyStream", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Missing SUPABASE_URL"])
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "room": roomID,
            "publish": publish,
            "identity": DeviceIdentity.current
        ])
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(StreamCredentials.self, from: data)
    }
}

enum DeviceIdentity {
    static var current: String {
        if let existing = UserDefaults.standard.string(forKey: "device.identity") { return existing }
        let fresh = UUID().uuidString
        UserDefaults.standard.set(fresh, forKey: "device.identity")
        return fresh
    }

    static var displayName: String {
        get { UserDefaults.standard.string(forKey: "device.name") ?? UIDeviceName.current }
        set { UserDefaults.standard.set(newValue, forKey: "device.name") }
    }
}

import UIKit
enum UIDeviceName { static var current: String { UIDevice.current.name } }
