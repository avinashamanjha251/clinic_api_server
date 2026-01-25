import Vapor

struct SMContactResponse: Content {
    
    struct SMPageHeader: Content {
        let title: String
        let subtitle: String
    }
    
    struct SMContactInfoItem: Content {
        let title: String
        let content: String
        let link: String?
        let icon: String
        let subtitle: String?
    }
    
    struct SMEmergencyCard: Content {
        let title: String
        let description: String
        let phone: String
        let phone_link: String
        let subtitle: String
    }
    
    struct SMContactInfo: Content {
        let section_title: String
        let description: String
        let items: [SMContactInfoItem]
        let emergency_card: SMEmergencyCard
    }
    
    struct SMMapContent: Content {
        let title: String
        let address: String
        let note: String
        let features: [String]
    }
    
    struct SMMapSection: Content {
        let title: String
        let content: SMMapContent
    }
    
    struct SMServiceOption: Content {
        let value: String
        let label: String
    }

    let header: SMHeader
    let page_header: SMPageHeader
    let contact_info: SMContactInfo
    let map_section: SMMapSection
    let services: [SMServiceOption]
    let time_slots: [String]
    let footer: SMFooter
}
