import Foundation

// Helper function to read dictionary file
func readDictionary(from path: String) -> [String] {
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        print("Error reading dictionary file")
        return []
    }
    return content.components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { $0.lowercased() }
}

// Main program
func main() {
    // Initialize Bloom Filter with reasonable size and hash count
    // Size is set to about 1MB (8 million bits) and 7 hash functions
    let bloomFilter = BloomFilter(size: 8_000_000, hashCount: 7)
    
    // Read dictionary
    let dictionaryPath = "/usr/share/dict/words" // Adjust path as needed
    let dictionary = readDictionary(from: dictionaryPath)
    
    // Add all words to the Bloom Filter
    for word in dictionary {
        bloomFilter.add(word)
    }
    
    // Interactive spell checking
    print("Enter words to spell check (press Ctrl+D to exit):")
    while let word = readLine()?.lowercased() {
        let exists = bloomFilter.mightContain(word)
        if exists {
            print("\"\(word)\" might be in the dictionary")
        } else {
            print("\"\(word)\" is definitely not in the dictionary")
        }
    }
}

// Add this function to test false positives
func testFalsePositives(bloomFilter: BloomFilter, dictionary: Set<String>, testCount: Int = 10000) {
    let letters = "abcdefghijklmnopqrstuvwxyz"
    var falsePositives = 0
    
    for _ in 0..<testCount {
        // Generate random 5-letter word
        let randomWord = String((0..<5).map { _ in 
            letters.randomElement()! 
        })
        
        if bloomFilter.mightContain(randomWord) && !dictionary.contains(randomWord) {
            falsePositives += 1
        }
    }
    
    print("False positive rate: \(Double(falsePositives) / Double(testCount) * 100)%")
}

main()
