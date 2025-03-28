//
//  CreateWishVC.swift
//  wishkit-ios
//
//  Created by Martin Lasek on 2/9/23.
//  Copyright © 2023 Martin Lasek. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import WishKitShared

final class CreateWishVC: UIViewController {

    weak var delegate: CreateWishDelegate?

    private var safeArea: UILayoutGuide!

    private let viewModel = CreateWishVM()

    private let scrollView = UIScrollView()

    private let wishTitleSectionLabel = UILabel(WishKit.config.localization.title)

    private let wishTitleCharacterCountLabel = UILabel()

    private let wishTitleTF = WKTextField(padding: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))

    private let wishDescriptionSectionLabel = UILabel(WishKit.config.localization.description)

    private let wishDescriptionCharacterCountLabel = UILabel()

    private let wishDescriptionTV = TextView()

    private let saveButton = SaveButton(title: WishKit.config.localization.save)

    private let toolbar = UIToolbar()

    private let doneContainer = UIView()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(WishKit.config.localization.done, for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        button.layer.opacity = 0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wishTitleTF.becomeFirstResponder()
        updateDoneButton()
    }
}

// MARK: - Logic

extension CreateWishVC {

    private func updateSaveButton() {
        saveButton.backgroundColor = UIColor(WishKit.theme.primaryColor)
        saveButton.configure(state: viewModel.canSave() ? .active : .disabled)
    }

    private func updateCharacterCountLabels() {
        wishDescriptionCharacterCountLabel.text = "\(viewModel.characterCount(of: .description))/\(viewModel.characterLimit(of: .description))"
        wishTitleCharacterCountLabel.text = "\(viewModel.characterCount(of: .title))/\(viewModel.characterLimit(of: .title))"
    }

    private func sendCreateRequest(_ createRequest: CreateWishRequest) {
        saveButton.configure(state: .loading)

        WishApi.createWish(createRequest: createRequest) { result in
            DispatchQueue.main.async {
                self.saveButton.configure(state: .active)

                switch result {
                case .success(let response):
                    self.handleCreateSuccess(response: response)
                case .failure(let error):
                    self.handleApiError(error: error)
                }
            }
        }
    }

    private func handleCreateSuccess(response: CreateWishResponse) {
        AlertManager.showMessage(on: self, message: "\(WishKit.config.localization.successfullyCreated)!") {
            if let delegate = self.delegate {
                delegate.newWishWasSuccessfullyCreated()
            } else {
                printError(self, "Missing delegate.")
            }

            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }

    private func handleApiError(error: ApiError) {
        AlertManager.showMessage(on: self, message: error.reason.description) {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
}

// MARK: - Setup

extension CreateWishVC {
    private func setupView() {
        safeArea = view.layoutMarginsGuide

        setupTheme()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        setupKeyboardManager()
        setupKeyboardToolbar()

        setupScrollView()

        setupDoneButton()

        setupWishTitleSectionLabel()
        setupWishTitleCharacterCountLabel()
        setupWishTitleTV()

        setupWishDescriptionSectionLabel()
        setupWishDescriptionCharacterCountLabel()
        setupWishDescriptionTV()

        setupSaveButton()
    }

    private func setupTheme() {
        if let color = WishKit.theme.tertiaryColor {
            if traitCollection.userInterfaceStyle == .light {
                view.backgroundColor = UIColor(color.light)
            }

            if traitCollection.userInterfaceStyle == .dark {
                view.backgroundColor = UIColor(color.dark)
            }
        } else {
            view.backgroundColor = .secondarySystemBackground
        }

        // Background
        if let color = WishKit.theme.secondaryColor {
            if traitCollection.userInterfaceStyle == .light {
                wishTitleTF.backgroundColor = UIColor(color.light)
                wishDescriptionTV.backgroundColor = UIColor(color.light)
            }

            if traitCollection.userInterfaceStyle == .dark {
                wishTitleTF.backgroundColor = UIColor(color.dark)
                wishDescriptionTV.backgroundColor = UIColor(color.dark)
            }
        }

        // Title & Description
        if let color = WishKit.theme.textColor {
            if traitCollection.userInterfaceStyle == .light {
                wishTitleTF.textColor = UIColor(color.light)
                wishDescriptionTV.textColor = UIColor(color.light)
            }

            if traitCollection.userInterfaceStyle == .dark {
                wishTitleTF.textColor = UIColor(color.dark)
                wishDescriptionTV.textColor = UIColor(color.dark)
            }
        }
    }

    private func setupKeyboardToolbar() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: WishKit.config.localization.done, style: .plain, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()

        wishTitleTF.inputAccessoryView = toolbar
        wishDescriptionTV.inputAccessoryView = toolbar
    }

    private func setupDoneButton() {
        scrollView.addSubview(doneContainer)
        doneContainer.addSubview(doneButton)

        doneContainer.anchor(
            top: scrollView.topAnchor,
            trailing: view.trailingAnchor,
            size: CGSize(width: 0, height: 35)
        )

        doneButton.anchor(
            top: doneContainer.topAnchor,
            leading: doneContainer.leadingAnchor,
            bottom: doneContainer.bottomAnchor,
            trailing: doneContainer.trailingAnchor,
            padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 65)
        )
    }

    private func setupScrollView() {
        view.addSubview(scrollView)

        scrollView.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: safeArea.bottomAnchor,
            trailing: view.trailingAnchor
        )

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
    }

    private func setupWishTitleSectionLabel() {
        scrollView.addSubview(wishTitleSectionLabel)

        wishTitleSectionLabel.anchor(
            top: doneContainer.bottomAnchor,
            leading: safeArea.leadingAnchor,
            trailing: safeArea.trailingAnchor,
            padding: UIEdgeInsets(top: 15, left: 7, bottom: 0, right: 0)
        )

        wishTitleSectionLabel.font = .boldSystemFont(ofSize: 10)
    }

    private func setupWishTitleCharacterCountLabel() {
        scrollView.addSubview(wishTitleCharacterCountLabel)

        wishTitleCharacterCountLabel.anchor(
            top: wishTitleSectionLabel.topAnchor,
            trailing: safeArea.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        )

        wishTitleCharacterCountLabel.font = .boldSystemFont(ofSize: 10)
        wishTitleCharacterCountLabel.textAlignment = .right

        updateCharacterCountLabels()
    }

    private func setupWishTitleTV() {
        scrollView.addSubview(wishTitleTF)

        wishTitleTF.anchor(
            top: wishTitleSectionLabel.bottomAnchor,
            leading: safeArea.leadingAnchor,
            trailing: safeArea.trailingAnchor,
            padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        )

        wishTitleTF.addTarget(viewModel, action: #selector(viewModel.titleHasChangedAction), for: .editingChanged)
    }

    private func setupWishDescriptionSectionLabel() {
        scrollView.addSubview(wishDescriptionSectionLabel)

        wishDescriptionSectionLabel.anchor(
            top: wishTitleTF.bottomAnchor,
            leading: safeArea.leadingAnchor,
            padding: UIEdgeInsets(top: 15, left: 7, bottom: 0, right: 0)
        )

        wishDescriptionSectionLabel.font = .boldSystemFont(ofSize: 10)
    }

    private func setupWishDescriptionCharacterCountLabel() {
        scrollView.addSubview(wishDescriptionCharacterCountLabel)

        wishDescriptionCharacterCountLabel.anchor(
            top: wishDescriptionSectionLabel.topAnchor,
            trailing: safeArea.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        )

        wishDescriptionCharacterCountLabel.font = .boldSystemFont(ofSize: 10)
        wishDescriptionCharacterCountLabel.textAlignment = .right

        updateCharacterCountLabels()
    }

    private func setupWishDescriptionTV() {
        scrollView.addSubview(wishDescriptionTV)

        wishDescriptionTV.anchor(
            top: wishDescriptionSectionLabel.bottomAnchor,
            leading: safeArea.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: safeArea.trailingAnchor,
            padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0),
            size: CGSize(width: 0, height: 260)
        )

        wishDescriptionTV.delegate = viewModel
        wishDescriptionTV.font = .systemFont(ofSize: UIFont.labelFontSize)
    }

    private func setupSaveButton() {
        scrollView.addSubview(saveButton)

        saveButton.anchor(
            top: wishDescriptionTV.bottomAnchor,
            centerX: wishDescriptionTV.centerXAnchor,
            padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0),
            size: CGSize(width: 200, height: 45)
        )

        saveButton.setTitleColor(WishKit.config.buttons.voteButton.tintColor, for: .normal)

        saveButton.layer.cornerRadius = 12
        saveButton.layer.cornerCurve = .continuous
        saveButton.addTarget(self, action: #selector(saveWishAction), for: .touchUpInside)

        updateSaveButton()
    }

    private func setupKeyboardManager() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - Actions

extension CreateWishVC {

    @objc private func dismissAction() {
        if viewModel.showDiscardWarning() {
            AlertManager.confirmAction(on: self, message: "Discard changes?", action: { self.dismiss(animated: true) })
        } else {
            dismiss(animated: true)
        }
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard
            let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - 35,
                right: 0
            )
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveWishAction() {
        dismissKeyboard()

        let request = viewModel.makeRequest()

        switch request {
        case .create(let createRequest):
            sendCreateRequest(createRequest)
        }
    }
}

// MARK: - Landscape

extension CreateWishVC {

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateDoneButton()
    }

    func updateDoneButton() {
        guard let bounds = view.window?.screen.bounds else {
            return
        }

        if bounds.width > bounds.height {
            UIView.animate(withDuration: 1/6) {
                self.doneButton.layer.opacity = 1
            }
        } else {
            UIView.animate(withDuration: 1/6) {
                self.doneButton.layer.opacity = 0
            }
        }
    }
}

// MARK: - CreateWishVMDelegate

extension CreateWishVC: CreateWishVMDelegate {
    func stateHasChanged() {
        updateCharacterCountLabels()
        updateSaveButton()
    }
}

// MARK: - Dark Mode

extension CreateWishVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            let previousTraitCollection = previousTraitCollection
        else {
            return
        }

        if let color = WishKit.theme.secondaryColor {
            // Needed this case where it's the same, there's a weird behaviour otherwise.
            if traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle {
                if previousTraitCollection.userInterfaceStyle == .light {
                    wishTitleTF.backgroundColor = UIColor(color.light)
                    wishDescriptionTV.backgroundColor = UIColor(color.light)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    wishTitleTF.backgroundColor = UIColor(color.dark)
                    wishDescriptionTV.backgroundColor = UIColor(color.dark)
                }
            } else {
                if previousTraitCollection.userInterfaceStyle == .light {
                    wishTitleTF.backgroundColor = UIColor(color.dark)
                    wishDescriptionTV.backgroundColor = UIColor(color.dark)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    wishTitleTF.backgroundColor = UIColor(color.light)
                    wishDescriptionTV.backgroundColor = UIColor(color.light)
                }
            }
        }
        
        if let color = WishKit.theme.tertiaryColor {
            // Needed this case where it's the same, there's a weird behaviour otherwise.
            if traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle {
                if previousTraitCollection.userInterfaceStyle == .light {
                    view.backgroundColor = UIColor(color.light)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    view.backgroundColor = UIColor(color.dark)
                }
            } else {
                if previousTraitCollection.userInterfaceStyle == .light {
                    view.backgroundColor = UIColor(color.dark)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    view.backgroundColor = UIColor(color.light)
                }
            }
        }

        // Title & Description
        if let color = WishKit.theme.textColor {
            // Needed this case where it's the same, there's a weird behaviour otherwise.
            if traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle {
                if previousTraitCollection.userInterfaceStyle == .light {
                    wishTitleTF.textColor = UIColor(color.light)
                    wishDescriptionTV.textColor = UIColor(color.light)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    wishTitleTF.textColor = UIColor(color.dark)
                    wishDescriptionTV.textColor = UIColor(color.dark)
                }
            } else {
                if previousTraitCollection.userInterfaceStyle == .light {
                    wishTitleTF.textColor = UIColor(color.dark)
                    wishDescriptionTV.textColor = UIColor(color.dark)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    wishTitleTF.textColor = UIColor(color.light)
                    wishDescriptionTV.textColor = UIColor(color.light)
                }
            }
        }

        let textColor = WishKit.config.buttons.saveButton.textColor
        if traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle {
            if previousTraitCollection.userInterfaceStyle == .light {
                saveButton.setTitleColor(UIColor(textColor.light), for: .normal)
            }

            if previousTraitCollection.userInterfaceStyle == .dark {
                saveButton.setTitleColor(UIColor(textColor.dark), for: .normal)
            }
        } else {
            if previousTraitCollection.userInterfaceStyle == .light {
                saveButton.setTitleColor(UIColor(textColor.dark), for: .normal)
            }

            if previousTraitCollection.userInterfaceStyle == .dark {
                saveButton.setTitleColor(UIColor(textColor.light), for: .normal)
            }
        }
    }
}
#endif
