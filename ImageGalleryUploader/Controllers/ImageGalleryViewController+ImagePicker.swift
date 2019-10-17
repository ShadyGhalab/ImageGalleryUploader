//
//  ImageGalleryViewController+ImagePicker.swift
//  ImageGalleryUploader 
//
//  Created by Shady Ghalab on 17.10.19.

import UIKit

private enum Constants {
    static let compressionQuality: CGFloat = 0.55
}

extension ImageGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let image = info[.editedImage] as? UIImage
        let fileUrl = info[.imageURL] as? URL
        let resourceName = fileUrl?.lastPathComponent ?? UUID().uuidString
        let resourceData = image?.jpegData(compressionQuality: Constants.compressionQuality)
        
        viewModel.inputs.uploadResource(with: resourceData, name: resourceName)
       
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
