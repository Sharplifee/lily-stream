import Foundation

/// Backend endpoints, injected at build time by CI. Nothing sensitive is
/// hardcoded in the repo and the LiveKit secret never ships in the bundle.
enum Config {
    static var supabaseURL: String { info("SUPABASE_URL") }
    static var supabaseAnonKey: String { info("SUPABASE_ANON_KEY") }
    static var tokenEndpoint: URL? { URL(string: supabaseURL + "/functions/v1/mint-stream-token") }

    private static func info(_ key: String) -> String {
        (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? ""
    }
}
