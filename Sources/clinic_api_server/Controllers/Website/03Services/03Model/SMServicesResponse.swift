import Vapor

struct SMServicesResponse: Content {
    struct SMPageHeader: Content {
        let title: String
        let subtitle: String
    }
    
    struct SMServiceCategory: Content {
        struct SMServiceItem: Content {
            let title: String
            let description: String
            let features: [String]
        }
        
        let title: String
        let items: [SMServiceItem]
    }
    
    struct SMServicesCTA: Content {
        let title: String
        let description: String
        let button_text: String
        let button_link: String
    }
    
    let header: SMHeader
    let page_header: SMPageHeader
    let services_categories: [SMServiceCategory]
    let cta_section: SMServicesCTA
    let footer: SMFooter
}
