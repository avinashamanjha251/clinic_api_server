import Vapor

struct SecurityLogging {
    static func log(_ message: String, request: Request, level: Logger.Level = .info) {
        let ip = request.clientIP
        let userId = (try? request.authenticateUserId()) ?? "guest"
        let path = request.url.path
        
        request.logger.log(level: level, "[\(level)][\(ip)][User:\(userId)][\(path)] \(message)")
    }
    
    static func logFraud(message: String, request: Request, payloadSummary: String? = nil) {
         let ip = request.clientIP
         let userId = (try? request.authenticateUserId()) ?? "guest"
         let path = request.url.path
         let summary = payloadSummary ?? ""
         request.logger.warning("[FRAUD-DETECTED][\(ip)][User:\(userId)][\(path)] \(message) | Payload: \(summary)")
    }
}
