import Foundation

import Foundation

struct CharacterDataContainer: Decodable {
    let count: Int
    let limit: Int
    let offset: Int
    let characters: [CharacterDataModel]

    enum CodingKeys: String, CodingKey {
        case count, limit, offset
        case characters = "results"
    }
}

struct CharacterDataWrapper: Decodable {
    let data: CharacterDataContainer
}

