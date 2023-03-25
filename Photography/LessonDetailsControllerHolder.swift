//
//  ObserabeObject.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-24.
//

import Foundation

class LessonDetailsControllerHolder: ObservableObject {
    @Published var lessonDetailsController: LessonDetailsViewController?

    func configure(lesson: Lesson, lessons: [Lesson]) {
        let viewController = LessonDetailsViewController()
        viewController.lesson = lesson
        viewController.lessons = lessons
        self.lessonDetailsController = viewController
    }
}

