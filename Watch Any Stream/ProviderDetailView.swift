//
//  ProviderDetailView.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 04/12/2024.
//

import SwiftUI

struct ProviderDetailView: View {
    let provider: Provider
    let countries: [String]
    let baseURL: String

    @State private var countryNames: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer()
                // Logo
                AsyncImage(url: URL(string: "\(baseURL)original\(provider.logo_path)")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                        .shadow(radius: 8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }

                // Provider Name
                Text(provider.provider_name)
                    .font(.title2)
                    .bold()

                // Country Names
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available in:")
                        .font(.headline)

                    ForEach(countryNames, id: \.self) { country in
                        Text(country)
                            .font(.body)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle(provider.provider_name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchCountryNames()
        }
    }

    private func fetchCountryNames() async {
        do {
            var names: [String] = []
            for isoCode in countries {
                let name = try await RegionManager.shared.getEnglishName(for: isoCode)
                names.append(name)
            }
            countryNames = names.sorted()
        } catch {
            print("Error fetching country names: \(error)")
        }
    }
}

#Preview {
    let provider = Provider(display_priorities: Optional(["VE": 4, "HN": 5, "CL": 3, "ID": 4, "AT": 4, "AE": 1, "GB": 4, "BZ": 0, "NI": 0, "BO": 4, "BE": 6, "CA": 6, "CH": 4, "LU": 0, "CR": 5, "SE": 4, "GH": 14, "IE": 4, "FI": 8, "IT": 4, "CZ": 4, "EG": 2, "NO": 5, "MY": 4, "PE": 3, "UA": 2, "MX": 2, "BG": 2, "HU": 3, "FR": 4, "SK": 4, "TW": 6, "UG": 14, "CY": 0, "MZ": 14, "PT": 4, "GR": 2, "IL": 24, "BR": 8, "NL": 9, "JP": 6, "LT": 2, "PL": 2, "RU": 2, "TR": 8, "PH": 4, "CO": 4, "SA": 1, "DK": 5, "US": 5, "TH": 4, "NZ": 4, "EE": 2, "ES": 5, "LV": 2, "IN": 3, "AU": 10, "EC": 6, "HK": 4, "BY": 0, "AR": 3, "SG": 5, "SI": 25, "GT": 6, "MU": 13, "ZA": 2, "PY": 5, "DE": 4, "CV": 11]), logo_path: "/9ghgSC0MA082EL6HLCW3GalykFD.jpg", provider_id: 2, provider_name: "Apple TV", display_priority: 4)
    let countries = ["United States of America", "The Netherlands", "South Africa", "Uganda"]
    let baseUrl = "https://image.tmdb.org/t/p/"
    ProviderDetailView(provider: provider, countries: countries, baseURL: baseUrl)
}
