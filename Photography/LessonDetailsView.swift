//
//  LessonDetailsView.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-24.
//

import SwiftUI

struct LessonDetailsView: View {
    let lesson: Lesson
    let lessons: [Lesson]
    @EnvironmentObject var controllerHolder: LessonDetailsControllerHolder

    var body: some View {
        VStack{
            LessonDetailsViewControllerWrapper(lesson: lesson, lessons: lessons)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(trailing:
            Button(action: {
                controllerHolder.lessonDetailsController?.downloadButtonTapped()
            }) {
                HStack {
                    Image("download")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("Download")
                }
            }
        )
    }
}
