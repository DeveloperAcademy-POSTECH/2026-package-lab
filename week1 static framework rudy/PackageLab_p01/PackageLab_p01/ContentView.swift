//
//  ContentView.swift
//  PackageLab_p01
//
//  Created by Seungjun Lee on 7/20/26.
//

import SwiftUI
import CatKit
import WhaleKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Cats.all, id: \.name) { animal in
                        AnimalRow(
                            name: animal.name,
                            imageName: animal.imageName,
                            description: animal.description,
                            bundle: CatKitResources.bundle ?? Bundle.main
                        )
                    }
                } header: {
                    SectionHeader(title: "고양이", subtitle: "CatKit (Static Framework)")
                }

                Section {
                    ForEach(Whales.all, id: \.name) { animal in
                        AnimalRow(
                            name: animal.name,
                            imageName: animal.imageName,
                            description: animal.description,
                            bundle: WhaleKitResources.bundle ?? Bundle.main
                        )
                    }
                } header: {
                    SectionHeader(title: "고래", subtitle: "WhaleKit (Dynamic Framework)")
                }
            }
            .navigationTitle("동물 도감")
        }
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct AnimalRow: View {
    let name: String
    let imageName: String
    let description: String
    let bundle: Bundle

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName, bundle: bundle)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
