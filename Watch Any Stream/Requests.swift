//
//  Requests.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 27/11/2024.
//

import Foundation

enum RequestType {
    case Configuration
    case MovieGenres
    case ShowGenres
    case MovieWatchProviders
    case ShowWatchProviders
    case AvailableRegions
    case MovieProviders
    case ShowProviders
    case Search
    case SearchKeyword
    case TrendingMovies
    case TrendingShows
    case DiscoverMovies
    case DiscoverShows
    case TopRatedShows
    case TopRatedMovies
    case PopularShows
    case PopularMovies
    case UpcomingMovies
    case MoviesInTheatres
}

class Information<T: Decodable> {
    var path: String?
    var queryItems: [URLQueryItem]?
    var jsonData: T?
    
    init(type: RequestType, query: String? = nil) async throws {
        
        switch type {
        case .Configuration:
            setConfigInformation()
        case .MovieGenres:
            setMovieGenreInformation()
        case .ShowGenres:
            setShowGenreInformation()
        case .Search:
            setSearchInformation(query: try parseOptional(query))
        case .TrendingMovies:
            setTrendingMoviesInformation()
        case .TrendingShows:
            setTrendingShowsInformation()
        case .DiscoverMovies:
            try await setDiscoverMoviesInformation(keywords: query)
        case .DiscoverShows:
            try await setDiscoverShowsInformation(keywords: query)
        case .MovieWatchProviders:
            setMovieProviderInformation(movieID: try parseOptional(query))
        case .ShowWatchProviders:
            setShowProviderInformation(seriesID: try parseOptional(query))
        case .AvailableRegions:
            setRegionInformation()
        case .SearchKeyword:
            setSearchKeywordInformation(keyword: try parseOptional(query))
        case .TopRatedShows:
            setTopRatedShowsInformation()
        case .TopRatedMovies:
            setTopRatedMoviesInformation()
        case .PopularShows:
            setPopularShowsInformation()
        case .PopularMovies:
            setPopularMoviesInformation()
        case .UpcomingMovies:
            setUpcomingMoviesInformation()
        case .MoviesInTheatres:
            setMoviesInTheatresInformation()
        case .MovieProviders:
            setMovieProviders()
        case .ShowProviders:
            setShowProviders()
        }
        
        try await makeQuery()
    }
    
    private func makeQuery() async throws {
        let requester = Requester(path: self.path!, queryItems: self.queryItems!)
        let data = try await requester.performRequest()
        jsonData = try JSONDecoder().decode(T.self, from: data)
    }
    
    // Used to check the query argument passed into the initializer. Parses it to a specified type.
    private func parseOptional(_ optional: String?) throws -> String {
        guard let unwrapped = optional else {
            throw NilError.nilType
        }
        return unwrapped
    }
    
    private func setSearchKeywordInformation(keyword: String) {
        path = "search/keyword"
        queryItems = [
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    
    private func setSearchInformation(query: String) {
        path = "search/multi"
        queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: "true"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
    }
    
    private func setTrendingMoviesInformation() {
        self.path = "trending/movie/day"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
    
    private func setTrendingShowsInformation() {
        self.path = "trending/tv/day"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
    
    private func setMovieGenreInformation() {
        self.path = "genre/movie/list"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
    
    private func setShowGenreInformation() {
        self.path = "genre/tv/list"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
    
    private func setConfigInformation() {
        self.path = "configuration"
        self.queryItems = []
    }
    
    private func setMovieProviderInformation(movieID: String) {
        self.path = "movie/\(movieID)/watch/providers"
        self.queryItems = []
    }
    
    private func setShowProviderInformation(seriesID: String) {
        self.path = "tv/\(seriesID)/watch/providers"
        self.queryItems = []
    }
    
    private func setRegionInformation() {
        self.path = "watch/providers/regions"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
    
    private func getKeywordIDs(keywords: String, getFirstOnly: Bool = false) async throws -> String? {
        let keywordIDs = try await Information<IDDetails>(type: .SearchKeyword, query: keywords).jsonData!.results
        if keywordIDs.isEmpty {
            return nil
        }
        if getFirstOnly {
            return String(keywordIDs.first!.id)
        }
        let ids: [Int] = keywordIDs.map { $0.id }
        let stringIDs: [String] = ids.map { String($0) }
        let idQuery: String = stringIDs.joined(separator: "%7C")
        return idQuery
    }
    
    private func setDiscoverMoviesInformation(keywords: String?) async throws {
        self.path = "discover/movie"
        self.queryItems = [
            URLQueryItem(name: "include_adult", value: "true"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        if keywords != nil {
            self.queryItems!.append(URLQueryItem(name: "with_keywords", value: try await getKeywordIDs(keywords: keywords!)))
        }
    }
    
    private func setDiscoverShowsInformation(keywords: String?) async throws {
        self.path = "discover/tv"
        self.queryItems = [
            URLQueryItem(name: "include_adult", value: "true"),
            URLQueryItem(name: "include_null_first_air_dates", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        if keywords != nil {
            self.queryItems!.append(URLQueryItem(name: "with_keywords", value: try await getKeywordIDs(keywords: keywords!)))
        }
    }
    private func setTopRatedShowsInformation() {
        self.path = "tv/top_rated"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    private func setTopRatedMoviesInformation() {
        self.path = "movie/top_rated"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    private func setPopularShowsInformation() {
        self.path = "tv/popular"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    private func setPopularMoviesInformation() {
        self.path = "movie/popular"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    private func setUpcomingMoviesInformation()  {
        self.path = "movie/upcoming"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    private func setMoviesInTheatresInformation() {
        self.path = "movie/now_playing"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
    }
    
    private func setMovieProviders() {
        self.path = "watch/providers/movie"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
    
    private func setShowProviders() {
        self.path = "watch/providers/tv"
        self.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
    }
}

class Requester {
    static let baseURL: String = "https://api.themoviedb.org/3/"
    
    let url: URL
    var components: URLComponents
    let queryItems: [URLQueryItem]
    
    init(path: String, queryItems: [URLQueryItem]) {
        self.url = URL(string: "\(Requester.baseURL)\(path)")!
        self.components = URLComponents(url: self.url, resolvingAgainstBaseURL: true)!
        self.queryItems = queryItems
    }
    
    private enum AuthType: String {
        case API = "API Key Auth"
        case AccessToken = "Access Token Auth"
    }
    
    // Function to retrieve the API key from Config.plist
    private func getAPIKey(type: AuthType) throws -> String {
        // Get the path to the Config.plist file
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            throw ConfigError.fileNotFound // Throw an error if the file is not found
        }
        
        // Load the contents of the plist file into a dictionary
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            throw ConfigError.invalidValue // Throw an error if the contents cannot be loaded
        }
        
        // Access the API key
        guard let apiKey = dict[type.rawValue] as? String else {
            throw ConfigError.keyNotFound // Throw an error if the API key is not found
        }
        
        return apiKey // Return the API key if found
    }
    
    func performRequest() async throws -> Data {
        self.components.queryItems = self.components.queryItems.map { $0 + self.queryItems } ?? self.queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        try request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(self.getAPIKey(type: .AccessToken))"
        ]

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
