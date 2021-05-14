//
//  ViewController.swift
//  MemeMe
//
//  Created by Seungyeon Kim on 2021/05/13.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
	
	// MARK: Properties
	
	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var albumButton: UIBarButtonItem!
	@IBOutlet weak var textFieldTop: UITextField!
	@IBOutlet weak var textFieldBottom: UITextField!
	@IBOutlet weak var navbar: UINavigationBar!
	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	
	let memeTextAttributes: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.strokeColor: UIColor.black,
		NSAttributedString.Key.foregroundColor: UIColor.white,
		NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSAttributedString.Key.strokeWidth:-3.0
	]
	
	
	// MARK: LifeCycle
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		subscribeToKeyboardNotifications()
		
		cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
		imagePickerView.contentMode = .scaleAspectFit

		textFieldTop.delegate = self
		textFieldBottom.delegate = self
		
		textFieldTop.text = "TOP"
		textFieldTop.textAlignment = .center
		textFieldTop.defaultTextAttributes = memeTextAttributes
		textFieldBottom.text = "BOTTOM"
		textFieldBottom.textAlignment = .center
		textFieldBottom.defaultTextAttributes = memeTextAttributes
		
		shareButton.isEnabled = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
		
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()
	}

	// MARK: ImagePicker
	
	@IBAction func pickAnImageFromAlbum(_ sender: Any) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func pickAnImageFromCamera(_ sender: Any) {
		
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .camera
		present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imagePickerView.image = image
			shareButton.isEnabled = true
		} else {
			print("not completed")
			shareButton.isEnabled = false
		}
		self.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: TextField
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == textFieldTop && textField.text == "TOP" {
			textField.text = ""
		} else if textField == textFieldBottom && textField.text == "BOTTOM" {
			textField.text = ""
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == textFieldTop && textField.text!.isEmpty {
			textField.text = "TOP"
		} else if textField == textFieldBottom && textField.text!.isEmpty {
			textField.text = "BOTTOM"
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		
		return true
	}
	
	// MARK: Keyboard
	
	@objc func keyboardWillShow(_ notification: Notification) {
		if textFieldBottom.isFirstResponder {
			view.frame.origin.y = -getKeyboardHeight(notification)
		}
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		view.frame.origin.y = 0.0
	}
	
	func getKeyboardHeight(_ notification: Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
		return keyboardSize.cgRectValue.height
	}
	
	func subscribeToKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	// MARK: Initializing a Meme ojbect
	
	func save(memeImage: UIImage) {
		let _ = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, originalImage: imagePickerView.image!, memeImage: memeImage)
	}
	
	@IBAction func share(_ sender: Any) {
		let memeImage = generateMemedImage()
		
		let vc = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
		
		vc.completionWithItemsHandler = { activity, completed, items, error in
			if completed {
				self.save(memeImage: memeImage)
				self.dismiss(animated: true, completion: nil)
			}
		}
		
		present(vc, animated: true, completion: nil)
	}
	
	@IBAction func cancel(_ sender: Any) {
		imagePickerView.image = nil
		textFieldTop.text = "TOP"
		textFieldBottom.text = "BOTTOM"
		shareButton.isEnabled = false
	}
	
	func generateMemedImage() -> UIImage {
		
		navbar.isHidden = true
		toolbar.isHidden = true
		
		UIGraphicsBeginImageContext(self.view.frame.size)
		view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
		let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		navbar.isHidden = false
		toolbar.isHidden = false
		
		return memedImage
	}
}

