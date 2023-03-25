//
//  LessonDetailsViewControllerWrapper.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-24.
//

import Foundation
import UIKit
import SwiftUI

struct LessonDetailsViewControllerWrapper: UIViewControllerRepresentable {
    @EnvironmentObject var controllerHolder: LessonDetailsControllerHolder

    let lesson: Lesson
    let lessons: [Lesson]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: LessonDetailsViewControllerWrapper

        init(_ parent: LessonDetailsViewControllerWrapper) {
            self.parent = parent
        }
    }

    func makeUIViewController(context: Context) -> LessonDetailsViewController {
        let viewController = LessonDetailsViewController()
        viewController.lesson = lesson
        viewController.lessons = lessons
        controllerHolder.lessonDetailsController = viewController
        return viewController
    }

    func updateUIViewController(_ uiViewController: LessonDetailsViewController, context: Context) {
        // Nothing to update
    }
}
