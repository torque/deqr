## Changelog

### [0.2.2] - 2023-06-17

#### Added

  - packaging: pre-built Python 3.11 wheels ([7980904b](https://github.com/torque/deqr/commit/7980904b97bbfee0446e4a11bff5183f77ed26b7))

#### Fixed

  - Adapt `pyproject.toml` to more recent poetry-core so that the source package should work again ([58a8c77b](https://github.com/torque/deqr/commit/58a8c77bfe34b3e8e3b42dc6a6c20be2b4105052))

#### Changed

  - Update quirc to v1.2 ([9918646d](https://github.com/torque/deqr/commit/9918646d61e2d9b71c3fc84604d5a6bec4af4c98))
  - Build dependencies: update cython to 3.0.0b3 and poetry-core to >=1.6.0,<1.7.0 (poetry-core is pinned to a narrow version range to hopefully avoid future breakage) ([a625da32](https://github.com/torque/deqr/commit/a625da32e2b8823a2a1619dc603e264cc3e86470), [58a8c77b](https://github.com/torque/deqr/commit/58a8c77bfe34b3e8e3b42dc6a6c20be2b4105052))
  - Don't package dependency source files into bdists ([2bc4a61f](https://github.com/torque/deqr/commit/2bc4a61f654f0c352fa843cfc7fd2ca5ac661e21))
  - Linux binary packages are now built to the manylinux_2_28 standard due to the manylinux_2_24 container being deprecated ([9b6e42e6](https://github.com/torque/deqr/commit/9b6e42e658cbbb3c30e149ed0f01c97d3daf3960))

#### Removed

  - Remove use of poetry-dynamic-versioning from the build process. It's convenient, but too flaky. Maintaining the version information in two places is not an unbearable maintenance burden, and CI can check for this ([5ea9a83e](https://github.com/torque/deqr/commit/5ea9a83e4e141bdd1b804cf00b8425441c7d725a))

### [0.2.1] - 2022-01-22

#### Added

  - packaging: distribute Python 3.10 wheels ([034f14b3](https://github.com/torque/deqr/commit/034f14b323103f12de2077e34133a08792e3876e))

#### Fixed

  - Fixed the sdist so that source-based installs work (note: this was later broken by a Poetry update) ([b84b3716](https://github.com/torque/deqr/commit/b84b371621db3c3f181bf2a0e53d54b93ffee3af))

### [0.2.0] - 2021-06-28

#### Added

  - Documentation. Things are now more documented than ever before.

#### Changed

  - QRdecDecoder now produces bounding box corners in clockwise order.
  - [BREAKING] Both decoders try to convert decoded data to reasonable types by default.

#### Fixed

  - binarize.binarze is now callable from Python code.
  - Decoding codes from PIL and bytes objects now actually works.
  - The sdist now contains the dependency code so it can be built.
  - Quirc decoding failures are now actually handled (by skipping them).

### [0.1.2] - 2021-06-16

#### Added
  - support more image sources, including PIL and bytes objects.

#### Changed

  - package: drop numpy dependency by trying to be clever
  - decoders: add image binarization to improve decode rate.

### [0.1.1] - 2021-06-06

#### Added

  - decoder.qrdec: expose qr code mask type
  - decoder.qrdec: compute geometric center of qr code
  - decoder.quirc: compute geometric center of qr code

### [0.1.0] - 2021-06-04

#### Added

  - Basic QR code decoding functionality
