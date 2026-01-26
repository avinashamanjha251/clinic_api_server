import Vapor

struct SMAdminRegisterRequest: Content, Validatable {
    @Trimmed var name: String
    @Trimmed var username: String
    @Trimmed var password: String
    
    static func validations(_ validations: inout Validations) {
        // Name validation
        validations.add(apiKey: ApiKey.name,
                        as: String.self,
                        is: !.empty && .count(2...100),
                        customFailureDescription: AdminRegistrationError.nameNotAllowedToBeEmpty)
        
        // Username validation
        validations.add(apiKey: ApiKey.username,
                        as: String.self,
                        is: !.empty && .count(3...50),
                        customFailureDescription: AdminRegistrationError.usernameNotAllowedToBeEmpty)
        
        // Password validation
        validations.add(apiKey: ApiKey.password,
                        as: String.self,
                        is: !.empty && .count(6...100),
                        customFailureDescription: AdminRegistrationError.passwordNotAllowedToBeEmpty)
    }
}
