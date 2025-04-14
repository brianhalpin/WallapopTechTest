//
//  HeroDetailView.swift
//  WallaMarvel
//
//  Created by Brian Halpin on 11/04/2025.
//

import SwiftUI
import Kingfisher

struct HeroDetailView: View {
    let hero: CharacterDataModel
    let imageURL: URL

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                KFImage(imageURL)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .fade(duration: 0.3)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(.white, lineWidth: 2)
                    )
                    .shadow(radius: 7)

                Text(hero.name)
                    .font(.title)

                Text(hero.description.isEmpty ? "No description available." : hero.description)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()

        }
    }
}

#Preview {
    do {
        let hero = try CharacterDataModel.loadFromSimpleJSON(filename: "CharacterPreviewData.json")
        if let imageURL = Bundle.main.url(forResource: "3d-man", withExtension: "jpg") {
            return HeroDetailView(hero: hero, imageURL: imageURL)
        } else {
            return Text("Image not found")
        }
    } catch {
        return Text("Error loading data: \(error.localizedDescription)")
    }
}
