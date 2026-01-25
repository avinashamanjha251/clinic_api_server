import Vapor
import MultipartKit
import NIOCore

final class DecryptionMiddleware: AsyncMiddleware {
        
    func respond(to request: Request,
                 chainingTo next: any AsyncResponder) async throws -> Response {
        switch request.method {
        case .GET:
            let requesData = try request.query.decode(SMRequestData.self)
            let decryptedData = try CommonFunctions.decryptData(data: requesData.data)
            request.decryptedBody = decryptedData
        default:
            // Check if request has encrypted data
            if request.headers.contentType == .urlEncodedForm {
                let requesData = try request.content.decode(SMRequestData.self)
                let decryptedData = try CommonFunctions.decryptData(data: requesData.data)
                request.decryptedBody = decryptedData
//            } else if request.headers.contentType == .formData {
//                let requesData = try await request.decodeFromCollectedBody(SMMultipartUploadPayload.self)
//                let decryptedData = try CommonFunctions.decryptData(data: requesData.data)
//                request.decryptedBody = decryptedData
            } else {
                throw Abort(.badRequest,
                            reason: "Data should be encrypted",
                            identifier: request.requestId)
            }
        }
        return try await next.respond(to: request)
    }
}
