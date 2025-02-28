import Foundation
import CryptoKit

class BloomFilter {
    private let bitmap: [Bool]
    private let size: Int
    private let hashCount: Int
    
    init(size: Int, hashCount: Int) {
        self.size = size
        self.hashCount = hashCount
        self.bitmap = Array(repeating: false, count: size)
    }
    
    // Generate multiple hash values for a word
    private func getHashValues(_ word: String) -> [Int] {
        var hashValues = [Int]()
        
        // Use MD5 to generate a base hash
        let wordData = word.data(using: .utf8)!
        let md5Hash = Insecure.MD5.hash(data: wordData)
        let hashBytes = Array(md5Hash)
        
        // Generate multiple hash values by taking different chunks of MD5 hash
        for i in 0..<hashCount {
            let startIndex = i * 2 % hashBytes.count
            let bytes = Array(hashBytes[startIndex...min(startIndex + 1, hashBytes.count - 1)])
            let hashValue = bytes.reduce(0) { $0 << 8 + Int($1) }
            hashValues.append(hashValue % size)
        }
        
        return hashValues
    }
    
    // Add a word to the filter
    func add(_ word: String) {
        let hashValues = getHashValues(word)
        for hashValue in hashValues {
            bitmap[hashValue] = true
        }
    }
    
    // Check if a word might be in the set
    func mightContain(_ word: String) -> Bool {
        let hashValues = getHashValues(word)
        return hashValues.allSatisfy { bitmap[$0] }
    }
}
