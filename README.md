[![Swift 5](https://img.shields.io/badge/Swift-5-green.svg?style=flat)](https://swift.org/)

Xcode Version 10.2.1 (10E1001)

## Project ##
- Gallery Image Uploader - Coding Challenge for Spark Networks  
- [More Info](https://github.com/sparknetworks/coding_exercises_options/blob/master/gallery_images_upload/README.mda)


## Client Setup  ## 

 ### Dev Setup 

```
 - git clone https://github.com/ShadyGhalab/ImageUploader.git
 - carthage update --platform iOS
 - Run! 😎
```

## Dev Notes ## 


### MVVM
This project uses the MVVM software architectural pattern. 


### Dependencies
- [ReactiveCocoa Page](https://github.com/ReactiveCocoa/ReactiveCocoa)
- [ReactiveSwift Page](https://github.com/ReactiveCocoa/ReactiveSwift)
- [FBSnapshotTestCase Page](https://github.com/uber/ios-snapshot-test-case)

* Dependencies are provided by Carthage, Why Carthage over CocoaPods? 
    - Carthage does not have Xcode workspace.
    - Carthage builds framework binaries using xcodebuild.
    - Carthage has been created as a decentralized dependency manager.

* Why am i using ReactiveCocoa and ReactiveSwift?
    - UI Binding.
    - Multithreading is simplified
    - Cleaner Code and Architectures.


### Localization
- The project is configured for localization with English language.


### Unit Testing
- The project uses XCTest for unit test.


### Snapshots Testing
 [FBSnapshotTestCase Page](https://github.com/uber/ios-snapshot-test-case)
 
- The project uses FBSnapshotTestCase for snapshopt tests.
- The snapshots have been recored for iPhone 7 only, And it has been stored in folder "ImageUploader/ImageUploaderTests/ReferenceImages_64"

## Server Side Setup  ##

- The project uses Cloudinary for the server side project, Cloudinary is providing a comprehensive cloud-based image and video management platform.
- Cloudinary support these features:
   * File Upload & Storage.
   * Cloud Assest Management.
   * Image and Video Manipulation.
   * Optimization and Fast Delivery.


 ### Dev Setup 

```
 - Go to https://cloudinary.com/users/login  (**Email: shadyghalab@gmail.com, Password: SparkNetwork@1**)
 - Tap on Media Library on the menu.
 - Find all the uploaded images there! 😎
```

## Dev Notes ## 

- Cloudinary has iOS SDK that i could have used but i did not, I used their REST APIs so i can showcase my capabilities of coding.

- [More Info for their REST APIS](https://cloudinary.com/documentation/image_upload_api_reference)



