import Foundation

struct AdminHelpers {
    static func parseDate(_ str: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = Date.DateFormat.ddMMyyyy.rawValue
        return fmt.date(from: str)
    }
}
