//
//  Lesson.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-23.
//

import Foundation

struct Lesson: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: String
    let video_url: String
}
