import Vapor

final class EncryptionResponseMiddleware: AsyncMiddleware {
    
    private let shouldEncrypt: @Sendable (Request) -> Bool
    
    init(shouldEncrypt: @Sendable @escaping (Request) -> Bool = { _ in true }) {
        self.shouldEncrypt = shouldEncrypt
    }

    func respond(to request: Request,
                 chainingTo next: any AsyncResponder) async throws -> Response {
        // Get the response from the route handler
        let response = try await next.respond(to: request)
        
        // Check if we should encrypt this response
        guard shouldEncrypt(request) else {
            return response
        }
        
        // Only encrypt urlEncodedForm responses
        guard response.headers.contentType == .json else {
            return response
        }
        
        // Get response body data
        guard let bodyData = response.body.string else {
            return response
        }
        // Encrypt the response data
        let encryptedString = try CommonFunctions.encryptParams(data: bodyData)
        
        
        // Create encrypted response wrapper
        let encryptedResponse = SMResponseData(data: encryptedString)
        
        // Create new response with encrypted data
        let encryptedResponseObject = Response(status: response.status)
        encryptedResponseObject.headers.contentType = .json
        try encryptedResponseObject.content.encode(encryptedResponse)
        
        return encryptedResponseObject
    }
}
