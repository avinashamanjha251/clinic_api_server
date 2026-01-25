import Vapor

extension Request {
    var clientIP: String {
        // Order: X-Forwarded-For -> X-Real-IP -> Remote Address
        if let xForwardedFor = headers.first(name: "X-Forwarded-For") {
            return xForwardedFor.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? xForwardedFor
        }
        if let xRealIP = headers.first(name: "X-Real-IP") {
            return xRealIP
        }
        return remoteAddress?.description ?? "unknown"
    }
    
    func authenticatedUserId() throws -> String {
        // Simple header check for now
        guard let userId = headers.first(name: "X-User-Id") else {
            throw Abort(.unauthorized, reason: "Missing X-User-Id header")
        }
        return userId
    }
    
    var requestId: String? {
        headers.first(name: "X-Request-Id")
    }
}

extension Request {
    /// Decodes content from decrypted body if available, otherwise from normal body
    func decodeContent<T: Decodable>(_ type: T.Type) throws -> T {
        // Check if we have decrypted data in storage
        if let decryptedBuffer = decryptedBody {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: decryptedBuffer)
        }
        
        // Fallback to normal content decoding
        return try content.decode(T.self)
    }
    
    func decodeContent<T: Decodable>(_ type: T.Type,
                                     inject additional: JSON? = nil) throws -> T {
        if let decryptedBuffer = decryptedBody {
            var obj = try JSON(decryptedBuffer)
            if let additional = additional {
                obj.merge(json: additional)
            }
            let updatedData = try obj.rawData()
            let decoder = JSONDecoder()
            return try decoder.decode(T.self,
                                      from: updatedData)
        }
        // Fallback: decode from normal request body, NO injection!
        return try content.decode(T.self)
    }
    
    // Custom decode method that uses collected body
    func decodeFromCollectedBody<T: Decodable>(_ type: T.Type) async throws -> T {
        // Check if body was already collected by middleware
        var buffer: ByteBuffer
        
        if let existingBuffer = self.collectedBody {
            // Use already collected buffer
            buffer = existingBuffer
        } else {
            // Collect body now if not already collected
            let collectedBuffer = try await body.collect(upTo: maxUploadSize)
            buffer = collectedBuffer
            // Store for future use
            self.collectedBody = buffer
        }
        
        guard let boundary = self.headers.contentType?.parameters["boundary"] else {
            throw Abort(.badRequest, reason: "Missing multipart boundary")
        }
        
        // Use MultipartKit's FormDataDecoder directly
        let decoder = FormDataDecoder()
        return try decoder.decode(T.self,
                                  from: buffer,
                                  boundary: boundary)
    }
}
