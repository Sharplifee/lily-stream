import Foundation

/// Who is live, backed by Supabase. Polling in v1 because it is trivially
/// reliable; the realtime channel is a drop-in replacement behind this API.
actor Presence {
    static let shared = Presence()
    private var task: Task<Void, Never>?

    func observe(_ onChange: @escaping ([LiveBroadcast]) -> Void) {
        task?.cancel()
        task = Task {
            while !Task.isCancelled {
                onChange(await fetch())
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }

    private func fetch() async -> [LiveBroadcast] {
        guard let url = URL(string: Config.supabaseURL + "/rest/v1/broadcasts?is_live=eq.true&select=*")
        else { return [] }
        var request = URLRequest(url: url)
        request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let rows = try? JSONDecoder().decode([Row].self, from: data) else { return [] }
        return rows.map { LiveBroadcast(id: $0.room_id, title: $0.title, host: $0.host, viewers: $0.viewers ?? 0) }
    }

    func announce(title: String, host: String) async {
        await write(body: [
            "room_id": DeviceIdentity.current,
            "title": title,
            "host": host,
            "is_live": true
        ])
    }

    func withdraw() async {
        await write(body: ["room_id": DeviceIdentity.current, "is_live": false])
    }

    private func write(body: [String: Any]) async {
        guard let url = URL(string: Config.supabaseURL + "/rest/v1/broadcasts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: request)
    }

    private struct Row: Decodable {
        let room_id: String
        let title: String
        let host: String
        let viewers: Int?
    }
}
