import Foundation

struct ServicesHelpers {
    static func slugify(_ text: String) -> String {
        return text.lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
