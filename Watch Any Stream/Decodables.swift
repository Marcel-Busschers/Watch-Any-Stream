//
//  Item.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 27/11/2024.
//

import Foundation

/**
 Defines a single item of Movie or TV Show, and includes all information apart from 'video'.
 Note that there are some differences in the Coding Keys between Movies and TV Shows;
 for example, a movie's title is called 'title' whereas a show's title is called 'name'.
 These encodings will all be set to the first:
 `name -> title`,
 `first_air_date -> release_date`,
 `original_name -> original_title`
 */
struct Item: Decodable {
    let adult: Bool?
    let backdrop_path: String?
    let id: Int
    let title: String? // Unifies both "title" and "name"
    let original_language: String?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let media_type: String? // Used for filtering
    let genre_ids: [Int]?
    let popularity: Double?
    let release_date: String?
    let vote_average: Double?
    let vote_count: Int?

    // Custom CodingKeys to handle "title" or "name"
    enum CodingKeys: String, CodingKey {
        case adult, backdrop_path, id, original_language, overview, poster_path, media_type, genre_ids, popularity, vote_average, vote_count
        
        case title
        case name
        
        case release_date
        case first_air_date
        
        case original_title
        case original_name
    }

    // Custom initializer to handle "title" or "name", etc
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        adult = try container.decodeIfPresent(Bool.self, forKey: .adult)
        backdrop_path = try container.decodeIfPresent(String.self, forKey: .backdrop_path)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ??
                container.decodeIfPresent(String.self, forKey: .name)
        original_language = try container.decodeIfPresent(String.self, forKey: .original_language)
        original_title = try container.decodeIfPresent(String.self, forKey: .original_title) ??
        container.decodeIfPresent(String.self, forKey: .original_name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        poster_path = try container.decodeIfPresent(String.self, forKey: .poster_path)
        media_type = try container.decodeIfPresent(String.self, forKey: .media_type)
        genre_ids = try container.decodeIfPresent([Int].self, forKey: .genre_ids)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        release_date = try container.decodeIfPresent(String.self, forKey: .release_date) ??
        container.decodeIfPresent(String.self, forKey: .first_air_date)
        vote_average = try container.decodeIfPresent(Double.self, forKey: .vote_average)
        vote_count = try container.decodeIfPresent(Int.self, forKey: .vote_count)
    }
    
    init(
        adult: Bool?,
        backdrop_path: String?,
        id: Int,
        title: String?,
        original_language: String?,
        original_title: String?,
        overview: String?,
        poster_path: String?,
        media_type: String?,
        genre_ids: [Int]?,
        popularity: Double?,
        release_date: String?,
        vote_average: Double?,
        vote_count: Int?
    ) {
        self.adult = adult
        self.backdrop_path = backdrop_path
        self.id = id
        self.title = title
        self.original_language = original_language
        self.original_title = original_title
        self.overview = overview
        self.poster_path = poster_path
        self.media_type = media_type
        self.genre_ids = genre_ids
        self.popularity = popularity
        self.release_date = release_date
        self.vote_average = vote_average
        self.vote_count = vote_count
    }
}

struct Date: Decodable {
    let maximum: String
    let minimum: String
}

// Define the ResultList struct
struct ItemList: Decodable {
    let dates: Date?
    let page: Int
    let results: [Item]
    let total_pages: Int
    let total_results: Int
}

struct ImageDetails: Decodable {
    let base_url: String
    let secure_base_url: String
    let backdrop_sizes: [String]
    let logo_sizes: [String]
    let poster_sizes: [String]
    let profile_sizes: [String]
    let still_sizes: [String]
}

struct ConfigDetails: Decodable {
    let images: ImageDetails
    let change_keys: [String]
}

struct ID: Decodable {
    let id: Int
    let name: String
}

struct IDDetails: Decodable {
    let page: Int
    let results: [ID]
    let total_pages: Int
    let total_results: Int
}

struct GenreDetails: Decodable {
    let genres: [ID]
}

struct Region: Decodable {
    let iso_3166_1: String
    let english_name: String
    let native_name: String
}

struct RegionDetails: Decodable {
    let results: [Region]
}

struct Provider: Decodable {
    let display_priorities: [String: Int]?
    let logo_path: String
    let provider_id: Int
    let provider_name: String
    let display_priority: Int
}

struct ProviderList: Decodable {
    let results: [Provider]
}

struct ProviderDetails: Decodable {
    let link: String
    let flatrate: [Provider]?
    let ads: [Provider]?
    let free: [Provider]?
    let rent: [Provider]?
    let buy: [Provider]?
}

struct CountryDetails: Decodable {
    let id: Int
    let results: [String: ProviderDetails]
}

extension Provider {
    var averageDisplayPriority: Double? {
        guard let priorities = self.display_priorities else { return nil }
        let total = priorities.values.reduce(0, +)
        return Double(total) / Double(priorities.count)
    }
}
