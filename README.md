[![Swift 5](https://img.shields.io/badge/Swift-5-green.svg?style=flat)](https://swift.org/)

Xcode Version 11.1 (11A1027)

## Project ##
- Gallery Image Uploader
- [More Info](https://github.com/sparknetworks/coding_exercises_options/tree/master/gallery_images_upload)


## Client Setup  ## 

 ### Dev Setup 

```
 - Install Swiftlint using: brew install swiftlint
 - git clone https://github.com/ShadyGhalab/ImageUploader.git
 - carthage update --platform iOS
 - Wait for Swift Package Manager to update its dependencies
 - Run! 😎
```

## Dev Notes ## 


### MVVM
This project uses the MVVM software architectural pattern. 


### Dependencies
- [ReactiveCocoa Page](https://github.com/ReactiveCocoa/ReactiveCocoa)
- [ReactiveSwift Page](https://github.com/ReactiveCocoa/ReactiveSwift)
- [FBSnapshotTestCase Page](https://github.com/uber/ios-snapshot-test-case)

### Localization
- The project is configured for localization with English language.


### Unit Testing
- The project uses XCTest for unit test.


### Snapshots Testing
 [FBSnapshotTestCase Page](https://github.com/uber/ios-snapshot-test-case)
 
- The project uses FBSnapshotTest for snapshopt tests.
- The snapshots have been recored for iPhone 7 (iOS 12.2) only, And it has been stored in folder "ImageGalleryUploader/ImageGalleryUploaderTests/ReferenceImages_64"

## Server Side Setup  ##

- The project uses Cloudinary for the server side project, Cloudinary is providing a comprehensive cloud-based image and video management platform.
- Cloudinary support these features:
   * File Upload & Storage.
   * Cloud Assest Management.
   * Image and Video Manipulation.
   * Optimization and Fast Delivery.


 ### Dev Setup 

```
 - Go to https://cloudinary.com/users/login  
 
      * Email: shadyghalab@gmail.com
      * Password : SparkNetwork@1
      
 - Tap on Media Library on the menu.
 - Find all the uploaded images there! 😎
```

## Dev Notes ## 

- Cloudinary has iOS SDK that i could have used but i did not, I used their APIs so i can showcase my capabilities of coding.

- [More Info for their APIS](https://cloudinary.com/documentation/image_upload_api_reference)



