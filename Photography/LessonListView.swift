//
//  LessonListView.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-23.
//

import SwiftUI

struct LessonListView: View {
    @StateObject private var viewModel = LessonListViewModel()
    @StateObject private var controllerHolder = LessonDetailsControllerHolder()

    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.lessons) { lesson in
                    NavigationLink(destination:
                        LessonDetailsView(lesson: lesson, lessons: viewModel.lessons)
                            .environmentObject(controllerHolder)
                    ) {
                        LessonRowView(lesson: lesson)
                    }
                }
            }
            .navigationTitle("Lessons")
            .onAppear {
                viewModel.fetchLessons()
            }
        }
    }
}


struct LessonRowView: View {
    let lesson: Lesson

    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        HStack {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 60)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 60)
            }
            Text(lesson.name)
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .lineLimit(2)
                .padding(.leading, 10)
        }
        .onAppear {
            imageLoader.load(url: URL(string: lesson.thumbnail))
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}


