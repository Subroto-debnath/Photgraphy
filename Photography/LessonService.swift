//
//  LessonService.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-23.
//

import Foundation

class LessonService {
    let apiURL = "https://iphonephotographyschool.com/test-api/lessons"
    
    let cacheFileName = "lessons_cache.json"
    
    func getLessons(completion: @escaping ([Lesson]) -> Void) {
        if let cachedLessons = loadFromCache() {
            completion(cachedLessons)
        } else {
            fetchAndCacheLessons(completion: completion)
        }
    }
    
    private func fetchAndCacheLessons(completion: @escaping ([Lesson]) -> Void) {
        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let lessonsResponse = try decoder.decode(LessonsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(lessonsResponse.lessons)
                }
                self.saveToCache(lessons: lessonsResponse.lessons)
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        
        task.resume()
    }
    
    private func saveToCache(lessons: [Lesson]) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheFileURL = documentsDirectory.appendingPathComponent(cacheFileName)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(lessons)
            try data.write(to: cacheFileURL)
        } catch {
            print("Error saving lessons to cache: \(error)")
        }
    }
    
    private func loadFromCache() -> [Lesson]? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheFileURL = documentsDirectory.appendingPathComponent(cacheFileName)
        
        do {
            let data = try Data(contentsOf: cacheFileURL)
            let decoder = JSONDecoder()
            let cachedLessons = try decoder.decode([Lesson].self, from: data)
            return cachedLessons
        } catch {
            print("Error loading lessons from cache: \(error)")
            return nil
        }
    }
}

private struct LessonsResponse: Codable {
    let lessons: [Lesson]
}
