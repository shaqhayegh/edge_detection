//
//  ReviewViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// The `ReviewViewController` offers an interface to review the image after it
/// has been cropped and deskewed according to the passed in quadrilateral.
final class ReviewViewController: UIViewController {

    private var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)
    private var enhancedImageIsAvailable = false
    private var isCurrentlyDisplayingEnhancedImage = false

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = results.croppedScan.image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // private lazy var enhanceButton: UIBarButtonItem = {
    //     let image = UIImage(
    //         systemName: "wand.and.rays.inverse",
    //         named: "enhance",
    //         in: Bundle(for: ScannerViewController.self),
    //         compatibleWith: nil
    //     )
    //     let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleEnhancedImage))
    //     button.tintColor = .white
    //     return button
    // }()

    private lazy var rotateButton: UIBarButtonItem = {
        let image = UIImage(systemName: "rotate.right", named: "rotate", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rotateImage))
        button.tintColor = .white
        return button
    }()

    private lazy var doneButton: UIButton = {
        let title = "done"
        let doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(title, for: .normal)
        doneButton.layer.cornerRadius = 20
        let buttonColor = UIColor(red: 46/255.0, green: 101/255.0, blue: 183/255.0, alpha: 1.0)
        doneButton.backgroundColor = buttonColor
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(finishScan), for: .touchUpInside)
        return doneButton
    }()

    private lazy var parentImageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        return view
    }()


    // private lazy var doneButton: UIBarButtonItem = {
    //     let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishScan))
    //     button.tintColor = navigationController?.navigationBar.tintColor
    //     return button
    // }()

    

    private let results: ImageScannerResults

    // MARK: - Life Cycle

    init(results: ImageScannerResults) {
        self.results = results
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        enhancedImageIsAvailable = results.enhancedScan != nil
        setupViews()
        // setupToolbar()
        setupConstraints()

        title = NSLocalizedString("wescan.review.title",
                                  tableName: nil,
                                  bundle: Bundle(for: ReviewViewController.self),
                                  value: "Review",
                                  comment: "The review title of the ReviewController"
        )
        // navigationItem.rightBarButtonItem = doneButton
    }

    override func viewWillAppear(_ animated: Bool) {
        // super.viewWillAppear(animated)

        // We only show the toolbar (with the enhance button) if the enhanced image is available.
        // if enhancedImageIsAvailable {
        //     navigationController?.setToolbarHidden(false, animated: true)
        // }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // super.viewWillDisappear(animated)
        // navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: Setups

    private func setupViews() {
        view.addSubview(parentImageView)
        view.addSubview(imageView)
         view.addSubview(doneButton)

    }

    private func setupToolbar() {
        // guard enhancedImageIsAvailable else { return }

        navigationController?.toolbar.barStyle = .blackTranslucent

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [fixedSpace, flexibleSpace, rotateButton, fixedSpace]
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false


            let parentImageConstraints = [
            parentImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            parentImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            parentImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        var imageViewConstraints: [NSLayoutConstraint] = []
        if #available(iOS 11.0, *) {
            imageViewConstraints = [
                view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.topAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.bottomAnchor),
                view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.leadingAnchor)
            ]


         
            
        } else {
            imageViewConstraints = [
                view.topAnchor.constraint(equalTo: imageView.topAnchor),
                view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
            ]

        }
    let doneButtonConstraints = [
    doneButton.heightAnchor.constraint(equalToConstant: 50),
    doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
    doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    doneButton.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.45),
    ]


        NSLayoutConstraint.activate(imageViewConstraints + doneButtonConstraints + parentImageConstraints)
    }

    // MARK: - Actions

    @objc private func reloadImage() {
        if enhancedImageIsAvailable, isCurrentlyDisplayingEnhancedImage {
            imageView.image = results.enhancedScan?.image.rotated(by: rotationAngle) ?? results.enhancedScan?.image
        } else {
            imageView.image = results.croppedScan.image.rotated(by: rotationAngle) ?? results.croppedScan.image
        }
    }

    // @objc func toggleEnhancedImage() {
    //     guard enhancedImageIsAvailable else { return }

    //     isCurrentlyDisplayingEnhancedImage.toggle()
    //     reloadImage()

    //     if isCurrentlyDisplayingEnhancedImage {
    //         enhanceButton.tintColor = .yellow
    //     } else {
    //         enhanceButton.tintColor = .white
    //     }
    // }

    @objc func rotateImage() {
        rotationAngle.value += 90

        if rotationAngle.value == 360 {
            rotationAngle.value = 0
        }

        reloadImage()
    }

    @objc private func finishScan() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }

        var newResults = results
        newResults.croppedScan.rotate(by: rotationAngle)
        newResults.enhancedScan?.rotate(by: rotationAngle)
        newResults.doesUserPreferEnhancedScan = isCurrentlyDisplayingEnhancedImage
        imageScannerController.imageScannerDelegate?
            .imageScannerController(imageScannerController, didFinishScanningWithResults: newResults)
    }

}
