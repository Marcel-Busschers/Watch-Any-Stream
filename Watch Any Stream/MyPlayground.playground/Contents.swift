import Foundation

Task {
    
    do {
        let arcaneShow = try await ParseSearch(query: "Arcane").data.first!
        print(arcaneShow)
        print()
    } catch {
        print(error)
    }
    
}

Task {
    do {
        let data = try await ParseShowWatchProviders(id: 94605).data
        print(data.first!)
        print()
    } catch {
        print(error)
    }
}

Task {
    do {
        let data = try await ParseProviders().data
        print(data)
        print()
    } catch {
        print(error)
    }
}

Task {
    do {
        let data = try await ParseConfiguration().data
        print(data)
        print()
    } catch {
        print(error)
    }
}

