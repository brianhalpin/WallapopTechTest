//
//  CharacterDataModel+Preview.swift .swift
//  WallaMarvel
//
//  Created by Brian Halpin on 13/04/2025.
//

import Foundation

// Used to load a local file for Preview in SwiftUI.

extension CharacterDataModel {
    static func loadFromSimpleJSON(filename: String) throws -> CharacterDataModel {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw NSError(domain: "LoadError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find \(filename)"])
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        let characters = try decoder.decode([CharacterDataModel].self, from: data)
        guard let first = characters.first else {
            throw NSError(domain: "LoadError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No characters in array."])
        }
        
        return first
    }
}
