//
//  WatchProviders.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 03/12/2024.
//

import SwiftUI

struct WatchProvidersScreen: View {
    var providers: [Provider]
    var base_url: String
    var logo_size: String
    let saveSelectedProviders: () -> Void
    @Binding var selectedProviders: Set<Int> // Bind to the parent view's state
    @State private var searchText: String = ""

    var filteredProviders: [Provider] {
        if searchText.isEmpty {
            return providers
        } else {
            return providers.filter { provider in
                provider.provider_name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var sortedProviders: [Provider] {
        let selected = filteredProviders.filter { selectedProviders.contains($0.provider_id) }
        let unselected = filteredProviders.filter { !selectedProviders.contains($0.provider_id) }
        return selected + unselected
    }

    var body: some View {
        VStack {
            TextField("Search Providers...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            List(sortedProviders, id: \.provider_id) { provider in
                HStack {
                    AsyncImage(url: URL(string: "\(base_url)\(logo_size)\(provider.logo_path)")) { image in
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
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        if selectedProviders.contains(provider.provider_id) {
                            selectedProviders.remove(provider.provider_id)
                        } else {
                            selectedProviders.insert(provider.provider_id)
                        }
                        saveSelectedProviders()
                    }) {
                        Image(systemName: selectedProviders.contains(provider.provider_id) ? "checkmark.square.fill" : "square")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Watch Providers")
    }
}
func someFunc() -> Void {}

#Preview {
    let providers = [Watch_Any_Stream.Provider(display_priorities: Optional(["CA": 6, "EE": 2, "ID": 4, "CO": 4, "EG": 2, "EC": 6, "NZ": 4, "DE": 4, "CV": 11, "IN": 3, "PL": 2, "GT": 6, "HN": 5, "CH": 4, "PE": 3, "SK": 4, "BO": 4, "BR": 8, "IT": 4, "VE": 4, "BZ": 0, "BE": 6, "MU": 13, "ES": 5, "HK": 4, "MZ": 14, "MY": 4, "PH": 4, "RU": 2, "LU": 0, "BY": 0, "BG": 2, "CR": 5, "IE": 4, "SA": 1, "PT": 4, "UG": 14, "TR": 8, "FI": 8, "LT": 2, "TH": 4, "JP": 6, "LV": 2, "US": 5, "NO": 5, "AR": 3, "GR": 2, "TW": 6, "SG": 5, "NL": 9, "UA": 2, "NI": 0, "AU": 10, "IL": 24, "SI": 25, "CY": 0, "SE": 4, "AT": 4, "MX": 2, "PY": 5, "CZ": 4, "GH": 14, "DK": 5, "CL": 3, "FR": 4, "GB": 4, "ZA": 2, "AE": 1, "HU": 3]), logo_path: "/9ghgSC0MA082EL6HLCW3GalykFD.jpg", provider_id: 2, provider_name: "Apple TV", display_priority: 2), Watch_Any_Stream.Provider(display_priorities: Optional(["US": 16, "HR": 3, "JP": 8, "AU": 13, "BR": 14, "HN": 20, "BF": 0, "VE": 3, "CO": 3, "TZ": 18, "TH": 5, "MY": 5, "IE": 7, "DE": 12, "IS": 4, "TR": 7, "CZ": 5, "AT": 7, "BE": 7, "GB": 15, "KR": 7, "EG": 4, "GR": 3, "BZ": 1, "LV": 3, "ML": 1, "NO": 8, "RU": 4, "FI": 9, "LU": 1, "BO": 20, "FR": 7, "SA": 3, "PL": 4, "DK": 6, "CL": 4, "CA": 8, "PG": 0, "HK": 11, "UA": 3, "AZ": 1, "ZA": 3, "CY": 1, "CH": 5, "AO": 0, "SE": 9, "BY": 1, "EE": 3, "ZW": 1, "ID": 6, "NL": 13, "EC": 9, "IN": 9, "ES": 15, "PE": 4, "HU": 4, "LT": 3, "AE": 3, "MX": 14, "NZ": 6, "PY": 20, "GT": 21, "CR": 21, "AR": 4, "PT": 5, "SG": 6, "IT": 7, "PH": 5, "NI": 1, "SK": 6, "TW": 3]), logo_path: "/8z7rC8uIDaTM91X0ZfkRf04ydj2.jpg", provider_id: 3, provider_name: "Google Play Movies", display_priority: 1), Watch_Any_Stream.Provider(display_priorities: Optional(["US": 37]), logo_path: "/19fkcOz0xeUgCVW8tO85uOYnYK9.jpg", provider_id: 7, provider_name: "Fandango At Home", display_priority: 37), Watch_Any_Stream.Provider(display_priorities: Optional(["SN": 0, "UY": 0, "SV": 0, "IT": 0, "CA": 0, "EC": 0, "TH": 1, "LB": 0, "BA": 0, "YE": 0, "KE": 0, "AU": 1, "GH": 0, "BM": 0, "TD": 5, "ML": 5, "MY": 1, "PS": 0, "BR": 1, "PF": 0, "CY": 7, "SM": 0, "IQ": 0, "US": 0, "BE": 1, "PT": 1, "NE": 0, "ME": 4, "SK": 1, "ID": 0, "FR": 0, "PY": 0, "TR": 3, "AE": 0, "TC": 0, "VE": 0, "EE": 0, "GB": 0, "CI": 0, "DE": 0, "MC": 0, "CU": 0, "PH": 0, "CR": 0, "JP": 0, "DK": 1, "LC": 0, "TW": 0, "MT": 0, "SE": 1, "ZM": 0, "NL": 0, "DO": 0, "LU": 8, "PL": 1, "HK": 1, "KR": 0, "SC": 0, "CO": 2, "GG": 0, "MD": 0, "LY": 0, "RO": 1, "BY": 5, "MA": 0, "PK": 0, "FJ": 0, "CL": 1, "HU": 1, "DZ": 0, "UG": 0, "GR": 0, "MG": 4, "JM": 0, "GT": 0, "UA": 0, "IN": 0, "AD": 0, "BB": 0, "MZ": 0, "AT": 0, "LI": 0, "HR": 0, "SA": 0, "GF": 0, "MU": 0, "NZ": 1, "BH": 0, "IL": 0, "KW": 0, "GI": 0, "AZ": 2, "AR": 1, "IS": 0, "EG": 0, "QA": 0, "BS": 0, "NO": 1, "ES": 0, "PA": 0, "BZ": 7, "MK": 0, "ZW": 5, "JO": 0, "AG": 0, "OM": 0, "NG": 0, "CV": 0, "IE": 0, "BG": 0, "HN": 0, "FI": 1, "SG": 0, "LV": 0, "MX": 8, "AO": 4, "PE": 2, "CM": 4, "TN": 0, "CZ": 1, "GQ": 0, "TT": 0, "TZ": 0, "BO": 0, "AL": 0, "ZA": 0, "NI": 11, "RS": 0, "LT": 0, "CH": 0, "SI": 0]), logo_path: "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg", provider_id: 8, provider_name: "Netflix", display_priority: 5), Watch_Any_Stream.Provider(display_priorities: Optional(["US": 2, "AT": 1, "GB": 2, "DE": 1, "JP": 4]), logo_path: "/qGXUKTheetVXYsSs9ehYLm7rzp8.jpg", provider_id: 9, provider_name: "Amazon Prime Video", display_priority: 2), Watch_Any_Stream.Provider(display_priorities: Optional(["PL": 30, "IE": 46, "AT": 3, "IN": 43, "AU": 12, "ES": 36, "US": 15, "BR": 13, "NL": 37, "SE": 43, "CA": 59, "FR": 40, "IT": 39, "JP": 5, "BE": 49, "DE": 9, "GB": 7, "MX": 7]), logo_path: "/seGSXajazLMCKGB5hnRCidtjay1.jpg", provider_id: 10, provider_name: "Amazon Video", display_priority: 15), Watch_Any_Stream.Provider(display_priorities: Optional(["MA": 4, "LB": 5, "EC": 10, "PG": 2, "IE": 15, "MX": 15, "AL": 5, "MW": 1, "TW": 17, "BM": 4, "GY": 1, "CZ": 6, "LT": 4, "BB": 4, "BA": 5, "CY": 5, "PE": 10, "GQ": 4, "PL": 6, "UG": 4, "KR": 8, "TT": 4, "KE": 4, "OM": 4, "ZW": 3, "DZ": 4, "TC": 4, "MG": 2, "CR": 23, "MT": 5, "ZM": 4, "IS": 6, "GT": 23, "FR": 21, "TZ": 4, "US": 65, "CV": 4, "NO": 10, "PT": 10, "RS": 5, "PS": 5, "AO": 2, "GR": 4, "LU": 6, "ME": 2, "DO": 4, "HR": 5, "GB": 14, "KW": 4, "LC": 4, "CU": 4, "BH": 4, "EG": 6, "BO": 22, "VA": 3, "IN": 10, "GF": 4, "NL": 17, "BG": 4, "NZ": 10, "PA": 4, "TH": 7, "CO": 10, "BS": 4, "MZ": 4, "NE": 5, "ML": 3, "CH": 16, "DK": 9, "BZ": 5, "IQ": 5, "MD": 4, "PY": 22, "LI": 4, "AG": 4, "AD": 5, "BE": 11, "ZA": 6, "BY": 3, "SV": 4, "PH": 8, "CA": 38, "AU": 23, "UA": 5, "EE": 4, "BR": 12, "NI": 6, "PF": 4, "DE": 27, "SE": 10, "MY": 7, "SI": 5, "SM": 4, "MC": 4, "HK": 18, "LV": 4, "GG": 4, "YE": 4, "IT": 14, "PK": 4, "SG": 8, "CM": 2, "MK": 5, "AE": 4, "JP": 9, "IL": 5, "AT": 17, "FJ": 4, "RU": 5, "GI": 4, "NG": 5, "JM": 4, "BF": 2, "RO": 3, "AR": 10, "VE": 7, "ID": 9, "FI": 11, "UY": 6, "TR": 9, "SN": 4, "HU": 5, "HN": 22, "SA": 5, "GH": 4, "JO": 4, "SK": 8, "TD": 3, "CL": 10, "ES": 19, "CD": 1, "MU": 3, "SC": 4, "LY": 4, "QA": 4, "TN": 4, "CI": 5]), logo_path: "/fj9Y8iIMFUC6952HwxbGixTQPb7.jpg", provider_id: 11, provider_name: "MUBI", display_priority: 65)]
    
    let bindingVariable = Binding<Set<Int>>(
                get: { Set([8]) }, // Initial value
                set: { newValue in
                    // Handle the new value if needed
                    print("Selected numbers changed to: \(newValue)")
                }
            )
    
    WatchProvidersScreen(providers: providers, base_url: "https://image.tmdb.org/t/p/", logo_size: "original", saveSelectedProviders: someFunc, selectedProviders: bindingVariable)
}
