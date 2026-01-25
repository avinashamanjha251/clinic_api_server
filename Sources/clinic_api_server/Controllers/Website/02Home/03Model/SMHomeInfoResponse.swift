import Vapor

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

    let hero: SMHero
    let features: SMFeatureSection
    let services: SMServiceSection
}

struct SMServiceSummary: Content {
    let title: String
    let description: String
    let slug: String
}
