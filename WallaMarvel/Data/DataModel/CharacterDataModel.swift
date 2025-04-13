import Foundation

struct CharacterDataModel: Decodable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Thumbnail
    let series: Series
    let comics: Comics
}

struct Comics: Decodable {
    let items: [ReferenceItem]
}

struct Series: Decodable {
    let items: [ReferenceItem]
}

struct ReferenceItem: Decodable {
    let resourceURI: String
    let name: String
}
