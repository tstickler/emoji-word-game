//
//  DailyGenerator.swift
//  emojiWords
//
//  Created by Tyler Stickler on 1/29/22.
//  Copyright © 2022 Tyler Stickler. All rights reserved.
//

import Foundation
import TrueTime

class DailyGenerator {
    enum DailyGeneratorError: Error {
        case unableToGetTime
        case unableToGenerateLevel
    }

    private let trueTimeClient: TrueTimeClient
    private(set) var fetchedDateString: String?

    init() {
        trueTimeClient = TrueTimeClient.sharedInstance
    }

    func generate(completion: @escaping (Result<String, DailyGeneratorError>) -> Void) {

        trueTimeClient.fetchIfNeeded(completion: { timeResult in
            switch timeResult {
            case .success(let referenceTime):
                self.generateDailyLevel(date: referenceTime.now()) { levelResult in
                    completion(levelResult)
                }
            case .failure:
                completion(.failure(.unableToGetTime))
            }
        })
    }

    private func generateDailyLevel(date: Date, completion: (Result<String, DailyGeneratorError>) -> Void) {
        let dateString = getDateString(fromDate: date)
        fetchedDateString = dateString
        let words = generateDailyWords(fromDateString: dateString)

        let generatedLevel = EmojiWordsGenerator.init(wordBank: words,
                                                      sectorCount: 6).generate()

        guard let generatedLevel = generatedLevel,
        generatedLevel.words.count == 5 else {
            completion(.failure(.unableToGenerateLevel))
            return
        }

        completion(.success(generatedLevel.gameString))
    }

    private func getDateString(fromDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    private func generateDailyWords(fromDateString dateString: String) -> [String] {
        let master = initializeMasterList()
        let byteArr = Hasher.SHA1(string: dateString)
        let dailyWordIndices = Hasher.makeIndices(hashNums: byteArr, wordCount: master.count)
        return dailyWordIndices.compactMap { master[$0]["Phrase"] }
    }

    private func initializeMasterList() -> Array<Dictionary<String, String>> {
        if let path = Bundle.main.path(forResource: "master", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let master = jsonResult as? Array<Dictionary<String, String>> {
                    // do stuff
                    return master
                }
            } catch {
                // handle error
            }
        }

        return []
    }

}
