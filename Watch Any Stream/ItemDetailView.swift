//
//  ItemDetailView.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 04/12/2024.
//

import SwiftUI

struct ItemDetailView: View {
    let item: Item
    let baseURL: String
    let posterSize: String
    let backdropSize: String
    @State private var genres: String = "Loading genres..."
    @State private var providerDetails: [Provider] = []
    @State private var countryAvailability: [Int: [String]] = [:]
    @State var selectedProviders: Set<Int> // Inject this from HomeScreen
    
    var body: some View {
        ScrollView {
            VStack {
                // Backdrop and poster section
                ZStack(alignment: .topLeading) {
                    // Backdrop
                    AsyncImage(url: URL(string: "\(baseURL)\(backdropSize)\(item.backdrop_path ?? "")")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                            .overlay(Color.black.opacity(0.5))
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    }
                    
                    // Poster and details
                    HStack(alignment: .top) {
                        AsyncImage(url: URL(string: "\(baseURL)\(posterSize)\(item.poster_path ?? "")")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 180)
                                .cornerRadius(8)
                                .shadow(radius: 8)
                                .offset(y: 10)
                                .padding(.leading)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 180)
                                .offset(y: 80)
                                .padding(.leading)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title ?? "Unknown Title")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text(item.release_date ?? "Unknown Date")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text(genres)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        .padding(.leading, 8)
                    }
                }
                
                // Overview
                if let overview = item.overview {
                    Text(overview)
                        .font(.body)
                        .padding()
                }
                
                // Ratings and popularity
                HStack {
                    Text("⭐ \(String(format: "%.1f", item.vote_average ?? 0)) (\(item.vote_count ?? 0) votes)")
                    Text("🔥 Popularity: \(Int(item.popularity ?? 0))")
                }
                .font(.subheadline)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Providers Grid
                if !providerDetails.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Available On:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(providerDetails, id: \.provider_id) { provider in
                                NavigationLink(destination: ProviderDetailView(provider: provider, countries: countryAvailability[provider.provider_id] ?? [], baseURL: baseURL)) {
                                    VStack {
                                        AsyncImage(url: URL(string: "\(baseURL)original\(provider.logo_path)")) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 50, height: 50)
                                        }
                                        
                                        Text(provider.provider_name)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 20)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .padding(.top, 20)
        .onAppear {
            // Fetch genres when the view appears
            Task {
                guard let genreIDs = item.genre_ids else {
                    genres = "Unknown Genres"
                    return
                }

                // Fetch genres asynchronously
                var genreNames: [String] = []
                for id in genreIDs {
                    let genreName = await (GenreManager.shared.getGenres(
                        for: id,
                        ofType: item.media_type == "tv" ? .tv : .movie
                    ))
                    if !genreName.isEmpty {
                        genreNames.append(genreName)
                    }
                }

                genres = genreNames.joined(separator: ", ")
            }
            Task {
                await fetchWatchProviders()
            }
        }
    }
    
    private func fetchWatchProviders() async {
        do {
            let data: [String: ProviderDetails]
            if item.media_type == "tv" {
                data = try await ParseShowWatchProviders(id: item.id).data
            } else {
                data = try await ParseMovieWatchProviders(id: item.id).data
            }
            
            var filteredProviders: [Provider] = []
            var availability: [Int: [String]] = [:]
            
            for (country, details) in data {
                let providers = (details.flatrate ?? []) + (details.free ?? [])
                for provider in providers {
                    guard selectedProviders.contains(provider.provider_id) else { continue }
                    if !filteredProviders.contains(where: { $0.provider_id == provider.provider_id }) {
                        filteredProviders.append(provider)
                    }
                    availability[provider.provider_id, default: []].append(country)
                }
            }
            
            providerDetails = filteredProviders
            countryAvailability = availability
        } catch {
            print("Error fetching watch providers: \(error)")
        }
    }
}

#Preview {
    let item = Item(adult: Optional(false), backdrop_path: Optional("/wQEW3xLrQAThu1GvqpsKQyejrYS.jpg"), id: 94605, title: Optional("Arcane"), original_language: Optional("en"), original_title: Optional("Arcane"), overview: Optional("Amid the stark discord of twin cities Piltover and Zaun, two sisters fight on rival sides of a war between magic technologies and clashing convictions."), poster_path: Optional("/abf8tHznhSvl9BAElD2cQeRr7do.jpg"), media_type: Optional("tv"), genre_ids: Optional([16, 10765, 10759, 9648]), popularity: Optional(782.932), release_date: Optional("2021-11-06"), vote_average: Optional(8.77), vote_count: Optional(4506))
    ItemDetailView(item: item, baseURL: "https://image.tmdb.org/t/p/", posterSize: "original", backdropSize: "original", selectedProviders: [8])
}
