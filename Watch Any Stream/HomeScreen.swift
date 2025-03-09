//
//  HomeScreen.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 27/11/2024.
//
import SwiftUI

struct HomeScreen: View {
    // Constants that need loading via ParseConfiguration()
    @State private var secureBaseURL: String = ""
    @State private var posterSize: String = ""
    @State private var logoSize: String = ""
    @State private var backdropSize: String = ""
    
    // Sections in Home Screen
    @State private var discoverMovies: [Item] = []
    @State private var discoverTVShows: [Item] = []
    @State private var trendingMovies: [Item] = []
    @State private var trendingTVShows: [Item] = []
    @State private var popularMovies: [Item] = []
    @State private var popularShows: [Item] = []
    @State private var topRatedMovies: [Item] = []
    @State private var topRatedShows: [Item] = []
    @State private var moviesInTheatre: [Item] = []
    @State private var upcomingMovies: [Item] = []
    @State private var discoverAnimeMovies: [Item] = []
    @State private var discoverAnimeShos: [Item] = []
    @State private var discoverCompetition: [Item] = []
    
    // Helper variables
    @State private var errorMessage: String?
    @State private var isLoading = true
    @State private var isSearching = false {
        didSet {
            if !isSearching {
                clearSearch()
            }
        }
    }
    @State private var searchText = ""
    @State private var searchResults: [Item] = []
    @State private var providers: [Provider] = []
    
    @AppStorage("SelectedProviders") private var selectedProvidersRaw: String = "[]"
    
    @State private var selectedProviders: Set<Int> = []
    
    init() {
        // Deserialize from JSON string to Set<Int>
        if let data = selectedProvidersRaw.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            _selectedProviders = State(initialValue: Set(decoded))
        } else {
            _selectedProviders = State(initialValue: [])
        }
    }

    func saveSelectedProviders() {
        // Serialize from Set<Int> to JSON string
        if let data = try? JSONEncoder().encode(Array(selectedProviders)),
           let jsonString = String(data: data, encoding: .utf8) {
            selectedProvidersRaw = jsonString
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if isLoading {
//                        ProgressView("Loading configuration...")
//                            .background(.clear)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                SectionView(
                                    title: "Discover Movies",
                                    items: discoverMovies,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )

                                SectionView(
                                    title: "Discover TV Shows",
                                    items: discoverTVShows,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )

                                SectionView(
                                    title: "Trending Movies",
                                    items: trendingMovies,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )

                                SectionView(
                                    title: "Trending TV Shows",
                                    items: trendingTVShows,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Popular Movies",
                                    items: popularMovies,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Popular Shows",
                                    items: popularShows,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Top Rated Movies",
                                    items: topRatedMovies,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Top Rated Shows",
                                    items: topRatedShows,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Movies In Theatres",
                                    items: moviesInTheatre,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Upcoming Movies",
                                    items: upcomingMovies,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Discover Anime Movies",
                                    items: discoverAnimeMovies,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Discover Anime Shows",
                                    items: discoverAnimeShos,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                                
                                SectionView(
                                    title: "Discover Competition Shows",
                                    items: discoverCompetition,
                                    baseURL: secureBaseURL,
                                    posterSize: posterSize,
                                    backdropSize: backdropSize,
                                    selectedProviders: selectedProviders
                                )
                            }
                            .padding(.top)
                            .padding(.bottom, 50)
                        }
                    }
                }
                .blur(radius: isSearching ? 10 : 0) // Blur everything behind
                .allowsHitTesting(!isSearching) // Disable interaction
                .onAppear {
                    Task {
                        do {
                            let configQuery = try await GlobalConfig.shared.getConfigQuery()
                            let imageDetails = configQuery.data
                            secureBaseURL = imageDetails.secure_base_url
                            posterSize = imageDetails.poster_sizes[1]
                            logoSize = imageDetails.logo_sizes[1]
                            backdropSize = imageDetails.backdrop_sizes[1]

                            discoverMovies = try await ParseDiscoverMovies().data
                            discoverTVShows = try await ParseDiscoverShows().data
                            trendingMovies = try await ParseTrendingMovies().data
                            trendingTVShows = try await ParseTrendingShows().data
                            popularMovies = try await ParsePopularMovies().data
                            popularShows = try await ParsePopularShows().data
                            topRatedMovies = try await ParseTopRatedMovies().data
                            topRatedShows = try await ParseTopRatedShows().data
                            moviesInTheatre = try await ParseMoviesInTheatres().data
                            upcomingMovies = try await ParseUpcomingMovies().data
                            discoverAnimeMovies = try await ParseDiscoverMovies(keywords: "anime").data
                            discoverAnimeShos = try await ParseDiscoverShows(keywords: "anime").data
                            discoverCompetition = try await ParseDiscoverShows(keywords: "competition").data

                            providers = try await ParseProviders().data

                            isLoading = false
                        } catch {
                            errorMessage = error.localizedDescription
                            isLoading = false
                        }
                    }
                    Task {
                        await GenreManager.shared.preloadGenres()
                    }
                }

                if isSearching {
                    Color.black.opacity(0.6) // Add dimming overlay
                        .ignoresSafeArea()

                    VStack {
                        Spacer()

                        HStack {
                            Button(action: { isSearching = false }) {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .padding(.trailing, 8)
                            }

                            TextField("Search...", text: $searchText, onCommit: search)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(height: 50)
                                .opacity(0.5)

                            Button(action: search) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title)
                                    .padding(.leading, 8)
                            }
                        }
                        .padding()
//                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)

                        Spacer()
                        
                        if !searchResults.isEmpty {
                            ScrollView {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                                    ForEach(searchResults, id: \.id) { item in
                                        NavigationLink(destination: ItemDetailView(item: item, baseURL: secureBaseURL, posterSize: posterSize, backdropSize: backdropSize, selectedProviders: selectedProviders)) {
                                            AsyncImage(url: URL(string: "\(secureBaseURL)\(posterSize)\(item.poster_path ?? "")")) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 150)
                                                    .cornerRadius(8)
                                            } placeholder: {
                                                ProgressView()
                                                    .frame(height: 150)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .background(Color(red: 38/255, green: 38/255, blue: 38/255))
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(value: "watchProviders") {
                        Image(systemName: "tv")
                            .imageScale(.medium)
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isSearching = true }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.medium)
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "watchProviders" {
                    WatchProvidersScreen(
                        providers: providers,
                        base_url: secureBaseURL,
                        logo_size: logoSize,
                        saveSelectedProviders: saveSelectedProviders, selectedProviders: $selectedProviders
                    )
                }
            }
        }
    }

    private func search() {
        Task {
            do {
                let results = try await ParseSearch(query: searchText).data
                searchResults = results.filter {$0.poster_path != nil}
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func clearSearch() {
        searchText = ""
        searchResults = []
    }
}

struct SectionView: View {
    let title: String
    let items: [Item]
    let baseURL: String
    let posterSize: String
    let backdropSize: String
    let selectedProviders: Set<Int>

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.leading)
                .foregroundStyle(.white)

            HorizontalScrollView(items: items, baseURL: baseURL, posterSize: posterSize, backdropSize: backdropSize, selectedProviders: selectedProviders)
        }
    }
}

struct HorizontalScrollView: View {
    let items: [Item]
    let baseURL: String
    let posterSize: String
    let backdropSize: String
    let selectedProviders: Set<Int>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: ItemDetailView(item: item, baseURL: baseURL, posterSize: posterSize, backdropSize: backdropSize, selectedProviders: selectedProviders)) {
                        AsyncImage(url: URL(string: "\(baseURL)\(posterSize)\(item.poster_path!)")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 180)
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 180)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeScreen()
}
