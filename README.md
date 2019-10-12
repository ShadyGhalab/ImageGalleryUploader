[![Swift 5](https://img.shields.io/badge/Swift-5-green.svg?style=flat)](https://swift.org/)

Xcode Version 11.1 (11A1027)

## Project ##
 ##allery Images Upload ##
Please provide a gallery with an image upload feature. This exercise is mostly front end with a tiny bit of back end. If you're stronger on the backend, you can try this one, but we'll definitely be looking strength on the front end. Please also ensure both the client and server side is well tested and clean code and that the code works before you submit your code.

 ##Client side ##
The client side can be either web or app. If it's web, please ensure it can be used on multiple devices. Completely up to you what frameworks you use; on our own code we use angular 2 or react for web, and all the usual libs for android and iOS that allows MVVM, MVP, and easier testing.

 ##Web Requirements ##
Provide a gallery view of all previously uploaded images
For image Upload:
mobile web, tablet - this will be a button which will prompt you to either access the camera and take a pic, or select from files on device
desktop web - will have 2 options: drag image to page to upload, or a button which allows selection of multiple files on device
super nice to see the web-views handling rotation on devices
App Requirements
For the image upload please provide:

a gallery view of all previously uploaded images
a button which can either request to take a picture, or upload from camera roll
the ability to rotate or crop images
Server side
The server side can be in whatever language you are strong with.
We mainly use js, java, and a little bit of php and go, so please try to use one of them that you're stronger with.

Don't worry too much about how this stuff should be stored and served properly on the server (such as s3 buckets, and CDNs etc). It's fine to store and serve the images locally.

If you opt for a db approach, store in whatever storage you see fit.

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
- The snapshots have been recored for iPhone 8 (iOS 13.1) only, And it has been stored in folder "ImageGalleryUploader/ImageGalleryUploaderTests/ReferenceImages_64"

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



