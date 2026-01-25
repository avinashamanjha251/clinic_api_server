import Vapor

struct SMCalendarSummaryItem: Content {
    let date: String // YYYY-MM-DD
    let count: Int
}
