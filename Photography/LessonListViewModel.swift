//
//  LessonListViewModel.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-23.
//

import SwiftUI

class LessonListViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []

    private let lessonService = LessonService()

    func fetchLessons() {
        lessonService.getLessons { lessons in
            DispatchQueue.main.async {
                self.lessons = lessons
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: URLSessionDataTask?

    func load(url: URL?) {
        guard let url = url else {
            return
        }

        cancellable = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }

        cancellable?.resume()
    }

    func cancel() {
        cancellable?.cancel()
    }
}

