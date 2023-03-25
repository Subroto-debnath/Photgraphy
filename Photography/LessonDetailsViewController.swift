//
//  LessonDetailsViewController.swift
//  Photography
//
//  Created by Subroto Debnath on 2023-03-23.
//

import UIKit
import AVKit

class LessonDetailsViewController: UIViewController, URLSessionDownloadDelegate {
    var lesson: Lesson?
    var lessons: [Lesson] = []

    private let videoPlayerViewController = AVPlayerViewController()
    var downloadTask: URLSessionDownloadTask?
    private var downloadProgressObservation: NSKeyValueObservation?

    private var downloadButton = UIBarButtonItem()
    private let cancelButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureVideoPlayer()
        configureDownloadButton()
    }
                                                                   
    private func setupUI() {
        
        addChild(videoPlayerViewController)
        videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoPlayerViewController.view)
        videoPlayerViewController.didMove(toParent: self)
        
        let titleLabel = UILabel()
        titleLabel.text = lesson?.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = lesson?.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.setTitle("Cancel download", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelDownloadButtonTapped), for: .touchUpInside)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
            
        progressView.isHidden = true
        progressView.translatesAutoresizingMaskIntoConstraints = false

        let nextLessonButton = UIButton(type: .system)
        nextLessonButton.setTitle("Next Lesson", for: .normal)
        nextLessonButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextLessonButton.semanticContentAttribute = .forceRightToLeft
        nextLessonButton.tintColor = .systemBlue
        nextLessonButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        nextLessonButton.addTarget(self, action: #selector(nextLessonButtonTapped), for: .touchUpInside)
        nextLessonButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nextLessonButton)
        view.addSubview(cancelButton)
        view.addSubview(progressView)

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: videoPlayerViewController.view.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                        
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                        
            nextLessonButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextLessonButton.centerYAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 50),

            progressView.topAnchor.constraint(equalTo: nextLessonButton.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
            cancelButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureVideoPlayer() {
        let videoURL: URL
        if let localURL = localVideoFileURL() {
            videoURL = localURL
        } else if let remoteURLString = lesson?.video_url, let remoteURL = URL(string: remoteURLString) {
            videoURL = remoteURL
        } else {
            return
        }

        let player = AVPlayer(url: videoURL)
        print("Subroo:\(videoURL)")
        videoPlayerViewController.player = player

        addChild(videoPlayerViewController)
        view.addSubview(videoPlayerViewController.view)
        videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            videoPlayerViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoPlayerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoPlayerViewController.view.heightAnchor.constraint(equalTo: videoPlayerViewController.view.widthAnchor, multiplier: 9.0/16.0)
        ])
    }

    func localVideoFileURL() -> URL? {
        let videoURLString = lesson?.video_url ?? ""
        let videoFileName = (videoURLString as NSString).lastPathComponent
        if isVideoFileDownloaded(videoFileName: videoFileName) {
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let videoFileURL = documentDirectory.appendingPathComponent(videoFileName)
            return videoFileURL
        }
        return nil
    }

    @objc func downloadButtonTapped() {
        guard let videoURLString = lesson?.video_url, let videoURL = URL(string: videoURLString) else { return }
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = session.downloadTask(with: videoURL)
        print("Subroo:\(videoURL)")
        downloadTask?.resume()
        configureDownloadButton()
    }
    @objc private func cancelDownloadButtonTapped() {
        downloadTask?.cancel()
        downloadTask = nil
        downloadProgressObservation = nil
        configureDownloadButton()
    }

    @objc private func nextLessonButtonTapped() {
        guard let currentLesson = lesson,
              let currentIndex = lessons.firstIndex(where: { $0.id == currentLesson.id }),
              currentIndex + 1 < lessons.count else {
            return
        }
        videoPlayerViewController.player?.pause()
        let nextLesson = lessons[currentIndex + 1]
        lesson = nextLesson
        updateUIForNextLesson()
        configureVideoPlayer()
    }

    private func updateUIForNextLesson() {
        guard let titleLabel = view.subviews.first(where: { $0 is UILabel }) as? UILabel,
              let descriptionLabel = view.subviews.last(where: { $0 is UILabel }) as? UILabel else {
            return
        }

        titleLabel.text = lesson?.name
        descriptionLabel.text = lesson?.description
    }
    func isVideoFileDownloaded(videoFileName: String) -> Bool {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoFileURL = documentDirectory.appendingPathComponent(videoFileName)
        return fileManager.fileExists(atPath: videoFileURL.path)
    }
    
    private func configureDownloadButton() {
        let videoURLString = lesson?.video_url ?? ""
        let videoFileName = (videoURLString as NSString).lastPathComponent

        if isVideoFileDownloaded(videoFileName: videoFileName) {
            downloadButton = UIBarButtonItem(title: "Downloaded", style: .plain, target: nil, action: nil)
            downloadButton.isEnabled = false
        } else {
            downloadButton = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadButtonTapped))
            downloadButton.isEnabled = true
        }

        if let downloadTask = downloadTask, downloadTask.state == .running {
            downloadButton.isEnabled = false
            cancelButton.isHidden = false
            progressView.isHidden = false

            downloadProgressObservation = downloadTask.progress.observe(\.fractionCompleted, options: [.initial, .new]) { [weak self] progress, _ in
                DispatchQueue.main.async {
                    self?.progressView.progress = Float(progress.fractionCompleted)
                }
            }
        } else {
            downloadButton.isEnabled = true
            cancelButton.isHidden = true
            progressView.isHidden = true
        }
        //navigationItem.rightBarButtonItem = downloadButton
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let videoURLString = lesson?.video_url ?? ""
        let videoFileName = (videoURLString as NSString).lastPathComponent
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoFileURL = documentDirectory.appendingPathComponent(videoFileName)

        do {
            if fileManager.fileExists(atPath: videoFileURL.path) {
                try fileManager.removeItem(at: videoFileURL)
            }
            try fileManager.copyItem(at: location, to: videoFileURL)
            DispatchQueue.main.async {
                self.downloadTask = nil
                self.downloadProgressObservation = nil
                self.configureDownloadButton()
            }
        } catch {
            print("Error saving video to local directory: \(error)")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Download task completed with error: \(error.localizedDescription)")
        } else {
            print("Download task completed successfully")
        }
        DispatchQueue.main.async {
            self.downloadTask = nil
            self.downloadProgressObservation = nil
            self.configureDownloadButton()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayerViewController.player?.pause()
        videoPlayerViewController.player = nil
        videoPlayerViewController.view.removeFromSuperview()
    }

}





