import Vapor

struct SMNavLink: Content {
    let text: String
    let url: String
    let is_active: Bool
}

struct SMHeader: Content {
    let brand_name: String
    let tagline: String
    let nav_links: [SMNavLink]
    let action_button_text: String
    let action_button_link: String
}

struct SMFooterLink: Content {
    let text: String
    let url: String
}

struct SMFooterContact: Content {
    let phone: String
    let phone_link: String
    let email: String
    let email_link: String
    let address: String
    let hours: String
}

struct SMFooter: Content {
    let brand_name: String
    let brand_description: String
    let quick_links_title: String
    let quick_links: [SMFooterLink]
    let contact_info_title: String
    let contact_info: SMFooterContact
    let copyright_text: String
}

struct SMServiceSummary: Content {
    let title: String
    let description: String
    let slug: String
}

struct SMHomeInfoResponse: Content {
    struct SMHero: Content {
        struct SMButton: Content {
            let text: String
            let link: String
            let `class`: String
        }
        struct SMImage: Content {
            let src: String
            let alt: String
            let fallback_src: String
        }
        
        let title: String
        let description: String
        let buttons: [SMButton]
        let image: SMImage
    }
    
    struct SMFeatureSection: Content {
        struct SMFeatureItem: Content {
            let title: String
            let description: String
            let image: String
            let fallback_image: String
            let fallback_icon: String
            let fallback_class: String
        }
        
        let section_title: String
        let items: [SMFeatureItem]
    }
    
    struct SMServiceSection: Content {
        let section_title: String
        let section_subtitle: String
        let items: [SMServiceSummary]
    }

    struct SMContactSection: Content {
        struct SMContactItem: Content {
            let title: String
            let content: String
            let subtitle: String?
            let link: String?
            let icon: String // Emoji or icon class
        }
        
        let section_title: String
        let items: [SMContactItem]
    }

    let header: SMHeader
    let hero: SMHero
    let features: SMFeatureSection
    let services: SMServiceSection
    let contact_info: SMContactSection
    let footer: SMFooter
}
