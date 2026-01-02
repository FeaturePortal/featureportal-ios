// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "featureportal-ios-dev",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .visionOS(.v1)
  ],
  products: [
    .library(
      name: "FeaturePortal", targets: ["FeaturePortal"]),
  ],
  targets: [
    .target(
      name: "FeaturePortal"),
    .testTarget(
      name: "FeaturePortalTests",
      dependencies: ["FeaturePortal"]
    ),
  ]
)
