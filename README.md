# CatCafe（擼貓吧）

<p align= "center">
<img src="https://i.imgur.com/xPgv12f.png" width="150" height="150">
</p>

<p align="center" style="margin:0px 50px 0px 60px">
A community for cat lovers to search for cat cafés in Taipei, share photos, or host social gatherings to meet new people.
</p>

<p align= "center">
<a href="https://apps.apple.com/tw/app/%E6%93%BC%E8%B2%93%E5%90%A7/id1630740681"><img src="https://user-images.githubusercontent.com/77667003/170689371-cf5b869d-5748-4683-b336-96010464b568.png" width="120" height="40" border="0"></a>
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS15+-blue.svg">
    <img src="https://img.shields.io/badge/license-MIT-green.svg">
    <img src="https://img.shields.io/badge/release-v1.0.2-red">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat">
</p>

## Main Features

* Browse all featured cat catés on the map.
 
<p align= "center">
    <img src="https://i.imgur.com/VTcoIIS.png" width="300"/> 
    <img src="https://i.imgur.com/4yQp98i.png" width="300"/>
</p>

* Post photos with filters to your feed that you want to show on your profile.

<p align= "center">
    <img src="https://i.imgur.com/Mh71994.png" width="200"/> 
    <img src="https://i.imgur.com/tDStJkS.png" width="200"/>
    <img src="https://i.imgur.com/odA3ZOr.png" width="200"/>
</p>

* You can meet friends by hosting or joining a social gathering in a specific cat caté, time and purpose to meet new people.

<p align= "center">
    <img src="https://i.imgur.com/02LKNU5.png" width="200"/> 
    <img src="https://i.imgur.com/29xYGjm.png" width="200"/>
    <img src="https://i.imgur.com/b52LvAZ.png" width="200"/>
</p>

* Message your friends with Messenger.

<p align= "center">
    <img src="https://i.imgur.com/PdvL6hO.png" width="300"/> 
    <img src="https://i.imgur.com/tDdwzDL.png" width="300"/>
</p>

## Techniques

* Applied **MetalPetal** image processing framework to implement Instagram-like filters.
* Used **PhotoKit** to access and modify photos inside a customized photo album.
* Built a custom camera with **AVFoundation** that allows users to take photos inside the App.
* Created map view and annotations using **MapKit** and a two-stage restaurant list without using third-party libraries. 
* Implemented chat function using **MessageKit** that allows users to send text, photo or video messages to others. 
* Followed **MVVM** pattern to structure the code base and utilized **Firebase** as database to perform CRUD operations.
* Constructed the entire UI **without interface builder**.

## Libraries

* <a href="https://github.com/realm/SwiftLint"> SwiftLint</a>
* <a href="https://github.com/MetalPetal/MetalPetal"> MetalPetal</a>
* <a href="https://github.com/onevcat/Kingfisher"> Kingfisher</a>
* <a href="https://github.com/JonasGessner/JGProgressHUD"> JGProgressHUD</a>
* <a href="https://github.com/relatedcode/ProgressHUD"> ProgressHUD</a>
* <a href="https://github.com/MessageKit/MessageKit"> MessageKit</a>
* <a href="https://github.com/suzuki-0000/SKPhotoBrowser"> SKPhotoBrowser</a>
* <a href="https://github.com/hyperoslo/Gallery"> Gallery</a>

## Requirement

* Xcode 13.0 or later
* iOS 15.0 or later
* Swift 5

## Version

1.0.2

## Release Notes

| Version | Date | Notes |
|:-------------:|:-------------:|:-------------:|
| 1.0.2 | 2022.07.19 | Crash issue fixed |
| 1.0.1 | 2022.07.17 | Bug fixed |
| 1.0.0 | 2022.07.16 | Released on App Store |

## Author

Chi-Wen Chen | rubato.cw@gmail.com

## License 
Copyright © 2022 Ethan Chen

CatCafe is released under the MIT license. See [License]() for detail.