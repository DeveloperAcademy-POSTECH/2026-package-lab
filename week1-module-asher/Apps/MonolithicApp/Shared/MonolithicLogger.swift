import Foundation

enum MonolithicLogger {
    static func log(_ message: String, category: String) {
        print("[Monolith/\(category)] \(message)")
    }
}

