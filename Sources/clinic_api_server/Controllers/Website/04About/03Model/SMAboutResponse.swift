import Vapor

struct SMAboutResponse: Content {
    
    struct SMPageHeader: Content {
        let title: String
        let subtitle: String
    }
    
    struct SMMission: Content {
        let title: String
        let content: [String]
    }
    
    struct SMStory: Content {
        let title: String
        let content: [String]
    }
    
    struct SMValueItem: Content {
        let icon: String
        let title: String
        let description: String
    }
    
    struct SMValues: Content {
        let title: String
        let items: [SMValueItem]
    }
    
    struct SMTeamMember: Content {
        let photo_placeholder: String
        let name: String
        let role: String
        let bio: String
        let credentials: [String]
    }
    
    struct SMTeam: Content {
        let title: String
        let members: [SMTeamMember]
    }
    
    struct SMFacility: Content {
        let title: String
        let description: String
        let technology_title: String
        let technology_list: [String]
        let comfort_title: String
        let comfort_list: [String]
    }
    
    struct SMCommunityActivity: Content {
        let title: String
        let description: String
    }
    
    struct SMCommunity: Content {
        let title: String
        let description: String
        let activities: [SMCommunityActivity]
    }
    
    struct SMAboutCTA: Content {
        let title: String
        let description: String
        let button_text: String
        let button_link: String
    }

    let header: SMHeader
    let page_header: SMPageHeader
    let mission: SMMission
    let story: SMStory
    let values: SMValues
    let team: SMTeam
    let facility: SMFacility
    let community: SMCommunity
    let cta: SMAboutCTA
    let footer: SMFooter
}
