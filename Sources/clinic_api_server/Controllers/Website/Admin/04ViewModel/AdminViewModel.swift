import Vapor
import MongoDBVapor

struct AdminViewModel: AdminViewModelProtocol {
    static let base = BaseMongoViewModel<CMAppointment>()
    
    static func fetchAppointmentsList(req: Request) async throws -> Response {
        let page = req.query[Int.self, at: "page"] ?? 1
        let perPage = req.query[Int.self, at: "perPage"] ?? 20
        let skip = (page - 1) * perPage
        
        // Use generic readFilteredRawData
        // Need empty filter for "all"
        let items = try await base.readFilteredRawData(
            filters: [:],
            sortKey: "createdAt",
            ascending: false,
            skipCount: skip,
            limit: perPage,
            on: req
        )
        
        return await ResponseHandler.success(
            data: SMAdminAppointmentListResponse(items: items, page: page, hasMore: items.count == perPage),
            on: req
        )
    }
    
    static func fetchCalendarSummary(req: Request) async throws -> Response {
        // Aggregate to count by date
        // MongoDB aggregation pipeline to group by preferredDate
        // This is complex in generic BSON, simplifying for demo: fetch all future valid and group in memory or just return a mock if too complex for single file.
        // Let's do a simple aggregation if we can.
        
        /* 
           Pipeline:
           [
             { $project: { dateStr: { $dateToString: { format: "%Y-%m-%d", date: "$preferredDate" } } } },
             { $group: { _id: "$dateStr", count: { $sum: 1 } } }
           ]
        */
        
        let pipeline: [BSONDocument] = [
            ["$project": ["dateStr": ["$dateToString": ["format": "%Y-%m-%d", "date": "$preferredDate"]]]],
            ["$group": ["_id": "$dateStr", "count": ["$sum": 1]]]
        ]
        
        let results = try await base.aggregate(pipeline: pipeline, on: req)
        
        let summary = results.compactMap { doc -> SMCalendarSummaryItem? in
            guard let date = doc["_id"]?.stringValue else { return nil }
            var count: Int = 0
            if let c = doc["count"] {
                if case .int32(let i) = c { count = Int(i) }
                else if case .int64(let i) = c { count = Int(i) }
                else { return nil }
            } else { return nil }
            
            return SMCalendarSummaryItem(date: date, count: count)
        }
        
        return await ResponseHandler.success(data: summary as [SMCalendarSummaryItem], on: req)
    }
    
    static func updateStatus(req: Request) async throws -> Response {
        let input = try req.content.decode(SMUpdateStatusRequest.self)
        guard let objId = try? BSONObjectID(input.appointmentId) else {
             throw Abort(.badRequest, reason: "Invalid ID")
        }
        
        // Fetch first to verify
        guard var item = try await base.readOne(filter: ["_id": .objectID(objId)], on: req) else {
            throw Abort(.notFound)
        }
        
        item.status = input.status
        try await base.updateDocument(objectId: objId, model: item, on: req)
        
        // Send email if confirmed
        if input.status == "confirmed" {
             EmailService.sendConfirmationStub(to: item.email ?? "")
        }
        
        return await ResponseHandler.success(message: "Status updated", data: nil as ResponseHandler.EmptyData?, on: req)
    }
    
    static func rescheduleAppointment(req: Request) async throws -> Response {
        let input = try req.content.decode(SMRescheduleRequest.self)
        guard let objId = try? BSONObjectID(input.appointmentId) else {
             throw Abort(.badRequest, reason: "Invalid ID")
        }
        
        guard var item = try await base.readOne(filter: ["_id": .objectID(objId)], on: req) else {
            throw Abort(.notFound)
        }
        
        item.preferredDate = input.newDate
        item.preferredTime = input.newTime
        try await base.updateDocument(objectId: objId, model: item, on: req)
        
        return await ResponseHandler.success(message: "Rescheduled", data: nil as ResponseHandler.EmptyData?, on: req)
    }
    
    static func fetchDateAppointments(req: Request) async throws -> Response {
        guard let dateStr = req.query[String.self, at: "date"] else {
             throw Abort(.badRequest, reason: "Date required")
        }
        // Need to parse dateStr "YYYY-MM-DD" to Date range search
        // This requires date parsing logic. 
        // For simplicity, we assume we want items where DATE part matches.
        // In Mongo, stored as Date.
        // We'll use our helper or assume Exact Match if we stored just Date (but we usually store Time)
        // Range query: date >= start AND date < end
        
        guard let start = AdminHelpers.parseDate(dateStr),
              let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
             throw Abort(.badRequest, reason: "Invalid date format")
        }
        
        let filter: BSONDocument = [
            "preferredDate": [
                "$gte": .datetime(start),
                "$lt": .datetime(end)
            ]
        ]
        
        let items = try await base.readFilteredRawData(filters: filter, on: req)
        return await ResponseHandler.success(data: items, on: req)
    }
}
