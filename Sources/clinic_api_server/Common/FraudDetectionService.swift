import Vapor

struct FraudDetectionService {
    
    // Heuristics:
    // Repeated identical payloads (not easily tracked stateless without a store, but we can verify date sanity).
    // Date misuse.
    
    static func inspectCreate(payload: any Content, request: Request) throws {
       try commonChecks(payload: payload, request: request)
    }
    
    static func inspectUpdate(payload: any Content, request: Request) throws {
        try commonChecks(payload: payload, request: request)
    }
    
    static func inspectLog(payload: any Content, request: Request) throws {
         try commonChecks(payload: payload, request: request)
    }
    
    static func inspectDelete(payload: any Content, request: Request) throws {
         // minimal checks
    }
    
    private static func commonChecks(payload: any Content, request: Request) throws {
        // Inspect for date anomalies if the payload has date fields.
        // Since payload is generic Content, we might need to inspect it as a dictionary or specific type if known.
        // For simplicity, we assume we check known key patterns via reflection or similar, 
        // OR we just provide the hook and implement specific logic where called.
        
        // This is a placeholder for the logic described:
        // "Date misuse: start/end dates too far in the past or future"
        
        // In a real implementation we might attempt to decode to a struct with dates or inspect JSON.
    }
    
    // Helper to check a date range
    static func validateDateRange(_ date: Date, maxFutureYear: Int = 1, maxPastYear: Int = 1) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        guard let futureLimit = calendar.date(byAdding: .year, value: maxFutureYear, to: now),
              let pastLimit = calendar.date(byAdding: .year, value: -maxPastYear, to: now) else {
            return true
        }
        return date < futureLimit && date > pastLimit
    }
}
