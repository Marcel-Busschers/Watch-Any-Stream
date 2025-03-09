//
//  SearchParser.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 27/11/2024.
//

import Foundation

protocol Request {
    associatedtype U
    var data: U { get }
}

final class ParseConfiguration: Request, Sendable {
    let jsonData: ConfigDetails
    let data: ImageDetails
    
    required init() async throws {
        jsonData = try await Information<ConfigDetails>(type: .Configuration).jsonData!
        data = jsonData.images
    }
}

final class ParseMovieGenres: Request, Sendable {
    let jsonData: GenreDetails
    let data: [ID]
    
    required init() async throws {
        jsonData = try await Information<GenreDetails>(type: .MovieGenres).jsonData!
        data = jsonData.genres
    }
}

final class ParseShowGenres: Request, Sendable {
    let jsonData: GenreDetails
    let data: [ID]
    
    required init() async throws {
        jsonData = try await Information<GenreDetails>(type: .ShowGenres).jsonData!
        data = jsonData.genres
    }
}

final class ParseMovieWatchProviders: Request, Sendable {
    let jsonData: CountryDetails
    let data: [String: ProviderDetails]
    
    required init(id: Int) async throws {
        jsonData = try await Information<CountryDetails>(type: .MovieWatchProviders, query: String(id)).jsonData!
        data = jsonData.results
    }
}

final class ParseShowWatchProviders: Request, Sendable {
    let jsonData: CountryDetails
    let data: [String: ProviderDetails]
    
    required init(id: Int) async throws {
        jsonData = try await Information<CountryDetails>(type: .ShowWatchProviders, query: String(id)).jsonData!
        data = jsonData.results
    }
}

final class ParseAvailableRegions: Request, Sendable {
    let jsonData: RegionDetails
    let data: [Region]
    
    required init() async throws {
        jsonData = try await Information<RegionDetails>(type: .AvailableRegions).jsonData!
        data = jsonData.results
    }
}

final class ParseSearch: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init(query: String) async throws {
        jsonData = try await Information<ItemList>(type: .Search, query: query).jsonData!
        data = jsonData.results
    }
}

final class ParseSearchKeyword: Request, Sendable {
    let jsonData: IDDetails
    let data: [ID]
    
    required init(query: String) async throws {
        jsonData = try await Information(type: .SearchKeyword, query: query).jsonData!
        data = jsonData.results
    }
}

final class ParseTrendingMovies: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .TrendingMovies).jsonData!
        data = jsonData.results
    }
}

final class ParseTrendingShows: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .TrendingShows).jsonData!
        data = jsonData.results
    }
}

final class ParseDiscoverMovies: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .DiscoverMovies).jsonData!
        data = jsonData.results
    }
    
    required init(keywords: String) async throws {
        jsonData = try await Information<ItemList>(type: .DiscoverMovies, query: keywords).jsonData!
        data = jsonData.results
    }
}

final class ParseDiscoverShows: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .DiscoverShows).jsonData!
        data = jsonData.results
    }
    
    required init(keywords: String) async throws {
        jsonData = try await Information<ItemList>(type: .DiscoverShows, query: keywords).jsonData!
        data = jsonData.results
    }
}

final class ParseTopRatedShows: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .TopRatedShows).jsonData!
        data = jsonData.results
    }
}

final class ParseTopRatedMovies: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .TopRatedMovies).jsonData!
        data = jsonData.results
    }
}

final class ParsePopularShows: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .PopularShows).jsonData!
        data = jsonData.results
    }
}

final class ParsePopularMovies: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .PopularMovies).jsonData!
        data = jsonData.results
    }
}

final class ParseUpcomingMovies: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .UpcomingMovies).jsonData!
        data = jsonData.results
    }
}

final class ParseMoviesInTheatres: Request, Sendable {
    let jsonData: ItemList
    let data: [Item]
    
    required init() async throws {
        jsonData = try await Information<ItemList>(type: .MoviesInTheatres).jsonData!
        data = jsonData.results
    }
}

final class ParseProviders: Request, Sendable {
    let movieJsonData: ProviderList
    let showJsonData: ProviderList
    let data: [Provider]
    
    required init() async throws {
        // Initialize movieJsonData and showJsonData first
        movieJsonData = try await Information<ProviderList>(type: .MovieProviders).jsonData!
        showJsonData = try await Information<ProviderList>(type: .ShowProviders).jsonData!
        
        // Now that movieJsonData and showJsonData are initialized, we can safely use them
        let movieResults = movieJsonData.results
        let showResults = showJsonData.results
        
        // Merge the results
        data = movieResults + showResults.filter { provider in
            !movieResults.contains(where: { $0.provider_id == provider.provider_id })
        }
    }
}

actor GlobalConfig {
    static let shared = GlobalConfig()
    private var configQuery: ParseConfiguration?

    func getConfigQuery() async throws -> ParseConfiguration {
        if let configQuery = configQuery {
            return configQuery
        }
        let newConfigQuery = try await ParseConfiguration()
        configQuery = newConfigQuery
        return newConfigQuery
    }
}

actor GenreManager {
    static let shared = GenreManager()
    private var movieGenres: [Int: String]?
    private var showGenres: [Int: String]?
    
    enum ItemType {
        case tv
        case movie
    }
    
    func preloadGenres() async {
        do {
            if movieGenres == nil {
                let movieData = try await ParseMovieGenres().data
                movieGenres = Dictionary(uniqueKeysWithValues: movieData.map { ($0.id, $0.name) })
            }
            if showGenres == nil {
                let showData = try await ParseShowGenres().data
                showGenres = Dictionary(uniqueKeysWithValues: showData.map { ($0.id, $0.name) })
            }
        } catch {
            print("Failed to preload genres: \(error)")
        }
    }
    
    func getGenres(for id: Int, ofType: ItemType) async -> String {
        do {
            switch ofType {
            case .movie:
                if let movieGenres = movieGenres {
                    return movieGenres[id] ?? ""
                }
                let movieData = try await ParseMovieGenres().data
                let newMovieGenres = Dictionary(uniqueKeysWithValues: movieData.map { ($0.id, $0.name) })
                movieGenres = newMovieGenres
                return movieGenres?[id] ?? ""
            case .tv:
                if let showGenres = showGenres {
                    return showGenres[id] ?? ""
                }
                let showData = try await ParseShowGenres().data
                let newShowGenres = Dictionary(uniqueKeysWithValues: showData.map { ($0.id, $0.name) })
                showGenres = newShowGenres
                return showGenres?[id] ?? ""
            }
        } catch {
            print("Failed to fetch genres: \(error)")
            return "Unknown Genre"
        }
    }
}

actor RegionManager {
    static let shared = RegionManager()
    private var regions: [String: String] = [:]

    func loadRegions() async throws {
        if regions.isEmpty {
            let data = try await ParseAvailableRegions().data
            regions = Dictionary(uniqueKeysWithValues: data.map { ($0.iso_3166_1, $0.english_name) })
        }
    }

    func getEnglishName(for isoCode: String) async throws -> String {
        if regions.isEmpty {
            try await loadRegions()
        }
        return regions[isoCode] ?? isoCode
    }
}
