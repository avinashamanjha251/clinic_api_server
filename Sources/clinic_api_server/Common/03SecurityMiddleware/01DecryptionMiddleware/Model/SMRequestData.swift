import Vapor
import Foundation

struct SMRequestData: Content {
    let data: String
        
//    init(from request: Request) throws {
//        self = try request.content.decode(SMRequestData.self)
//    }
}

struct SMMultipartUploadPayload: Content {
    var data: String        // Encrypted JSON field
    var file: File         // Single file upload (common field name)
}
