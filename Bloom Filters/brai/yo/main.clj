(ns main
  (:require [clojure.java.io :as io]))

(def read-words
  (memoize
   (fn []
     (with-open [rdr (io/reader "words.txt")]
       (into [] (line-seq rdr))))))

(def dictionary-size 10000)

(defn modded-hash [word]
  (-> word hash (mod dictionary-size)))

(def hash-dictionary
  (atom (vec (repeat dictionary-size false))))

(doseq [word (read-words)]
  (let [hash (modded-hash word)]
    (swap! hash-dictionary assoc hash true)))

(defn spell-check [word]
  (let [hash (modded-hash word)
        value (get @hash-dictionary hash)]
    value))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TESTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def words-set (set (read-words)))

(defn true-spell-check [word]
  (contains? words-set word))

(defn generate-random-word []
  (let [chars "abcdefghijklmnopqrstuvwxyz"
        length (rand-int 20)]
    (->> chars
         seq
         shuffle
         (take length)
         (apply str))))

(defn false-positives [tests]
  (let [random-words (repeatedly tests generate-random-word)
        positives (count (filter spell-check random-words))
        true-positives (count (filter true-spell-check random-words))]
    (- positives true-positives)))

(false-positives 100)

(spell-check "hola")

(defn benchmark-spell-checks [n]
  (let [words (repeatedly n generate-random-word)
        bloom-start (System/nanoTime)
        _ (doall (map spell-check words))
        bloom-end (System/nanoTime)
        true-start (System/nanoTime)
        _ (doall (map true-spell-check words))
        true-end (System/nanoTime)]
    (println "Testing" n "words:")
    (println "Bloom filter time:" (/ (- bloom-end bloom-start) 1000000.0) "ms")
    (println "True check time:" (/ (- true-end true-start) 1000000.0) "ms")))

(benchmark-spell-checks 1000000)
