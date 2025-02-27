use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::error::Error;
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use clap::{Parser};

struct BloomFilter {
    bitmap: Vec<bool>,
    hash_functions: usize,
}

impl BloomFilter {
    fn new(size: usize, hash_functions: usize) -> Self {
        BloomFilter {
            bitmap: vec![false; size],
            hash_functions,
        }
    }

    fn add(&mut self, word: &str) {
        for i in 0..self.hash_functions {
            let hash = self.calculate_hash(word, i);
            let index = hash as usize % self.bitmap.len();
            self.bitmap[index] = true;
        }
    }

    fn contains(&self, word: &str) -> bool {
        for i in 0..self.hash_functions {
            let hash = self.calculate_hash(word, i);
            let index = hash as usize % self.bitmap.len();
            if !self.bitmap[index] {
                return false;
            }
        }
        true
    }

    fn calculate_hash(&self, word: &str, seed: usize) -> u64 {
        let mut hasher = DefaultHasher::new();
        word.hash(&mut hasher);
        seed.hash(&mut hasher);
        hasher.finish()
    }
}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Size of the bitmap
    #[arg(short, long, default_value = "1000000")]
    size: usize,

    /// Number of hash functions to use
    #[arg(short = 'f', long, default_value = "5")]
    hash_functions: usize,

    /// Word to check in the Bloom Filter
    #[arg(short, long)]
    word: String,
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();
    let bitmap_size = args.size;
    let hash_functions = args.hash_functions;
    let word = args.word;

    let bloom_filter = load_dictionary("words.txt", bitmap_size, hash_functions)
        .expect("Failed to initialize bloom filter");

    match bloom_filter.contains(word.to_lowercase().as_str()) {
        true => println!("La palabra '{}' puede que esté en el diccionario", word),
        false => println!("La palabra '{}' no está en el diccionario", word)
    }

    Ok(())
}

fn load_dictionary<P>(filepath: P, bitmap_size: usize, hash_functions: usize) -> Result<BloomFilter, io::Error>
where
    P: AsRef<Path>,
{
    let mut bloom_filter = BloomFilter::new(bitmap_size, hash_functions);

    let file = File::open(filepath)?;
    io::BufReader::new(file).lines().for_each(|word| {
        match word {
            Ok(word) => bloom_filter.add(&word.to_lowercase()),
            Err(e) => println!("Error reading word: {}", e),
        }
    });

    Ok(bloom_filter)
}