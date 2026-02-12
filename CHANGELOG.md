# Changelog

All notable changes to this project will be documented in this file.

## [3.8.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.7.0...v3.8.0) (2026-02-12)


### Features

* Add privileged_mode variable to CodeBuild project configuration ([#102](https://github.com/cloudandthings/terraform-aws-github-runners/issues/102)) ([b1ea6ac](https://github.com/cloudandthings/terraform-aws-github-runners/commit/b1ea6acd4c561641f5b3ba754c57b85c4dc27dab))

## [3.7.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.6.0...v3.7.0) (2025-12-29)


### Features

* Add Cloudwatch group output ([#100](https://github.com/cloudandthings/terraform-aws-github-runners/issues/100)) ([5811d49](https://github.com/cloudandthings/terraform-aws-github-runners/commit/5811d49954635a31291527a83ddac5a918c20555))

## [3.6.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.5.0...v3.6.0) (2025-12-09)


### Features

* Add support for org-level runners ([#58](https://github.com/cloudandthings/terraform-aws-github-runners/issues/58)) ([f8c498a](https://github.com/cloudandthings/terraform-aws-github-runners/commit/f8c498a28b99954f320f9bc95195700bec27c2f6))

## [3.5.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.4.0...v3.5.0) (2025-12-05)


### Features

* Add IAM role path variable ([c3280e5](https://github.com/cloudandthings/terraform-aws-github-runners/commit/c3280e50d71001d487ea4886c70920665cec72d1))
* Add IAM role path variable ([f66e3da](https://github.com/cloudandthings/terraform-aws-github-runners/commit/f66e3da0a2beb258094f0fabf25ba551eb84c75d))

## [3.4.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.3.1...v3.4.0) (2025-11-17)


### Features

* Add custom ingress rules for security group ([66fd3ba](https://github.com/cloudandthings/terraform-aws-github-runners/commit/66fd3bac186f7108c7e02f40f29b742cd8153ac4))

## [3.3.1](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.3.0...v3.3.1) (2025-11-17)


### Bug Fixes

* remove github-runner-label tag to avoid invalid characters ([ef726ad](https://github.com/cloudandthings/terraform-aws-github-runners/commit/ef726ad800ec847c1a86dc0a21378a29b786c997))

## [3.3.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.2.0...v3.3.0) (2025-11-06)


### Features

* Add default description and custom tags ([55663c9](https://github.com/cloudandthings/terraform-aws-github-runners/commit/55663c9f6c621a2e3a4de9a95b9101d66cbbcef1))
* Use dynamic AWS partition for ARNs ([a8ac068](https://github.com/cloudandthings/terraform-aws-github-runners/commit/a8ac06830f785167f80a3ec4acfa7b916396ed51))

## [3.2.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.1.1...v3.2.0) (2025-10-21)


### Features

* Add comprehensive repository improvements including documentation and templates ([ca0835c](https://github.com/cloudandthings/terraform-aws-github-runners/commit/ca0835cba368f6dbaace78037e792d1a8aa404fa))
* Add source_auth variable to override default CodeBuild credential ([fb8efdc](https://github.com/cloudandthings/terraform-aws-github-runners/commit/fb8efdcca130461f0679800d0de70e31a72c3c5a))
* Support SecretsManager secrets ([cd74bb8](https://github.com/cloudandthings/terraform-aws-github-runners/commit/cd74bb8c01190e4f5f0c3976303f22a084f4e3b2))


### Bug Fixes

* Add period to validation error message to comply with Terraform requirements ([13403cb](https://github.com/cloudandthings/terraform-aws-github-runners/commit/13403cbf2b4f6eee23ba279b76834efba1db01f2))
* Remove trailing whitespace from feature_request.yml to pass pre-commit checks ([5a0b160](https://github.com/cloudandthings/terraform-aws-github-runners/commit/5a0b160e5d7892f50e7815cb6dc5f17610444994))
* Remove trailing whitespace from TROUBLESHOOTING.md to pass pre-commit checks ([c8fb9fc](https://github.com/cloudandthings/terraform-aws-github-runners/commit/c8fb9fc21ab97f9097f611e76d41481458fe9dbf))
* Rename secretsmanager variable ([a763923](https://github.com/cloudandthings/terraform-aws-github-runners/commit/a763923fc752b38fd2250e8c9840aeb80fceb680))

## [3.1.1](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.1.0...v3.1.1) (2025-08-19)


### Bug Fixes

* **versions:** Bump aws provider version to allow v6 ([97d5f14](https://github.com/cloudandthings/terraform-aws-github-runners/commit/97d5f14117335d5ec46a94576640c1d2d879dfa1))

## [3.1.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.0.1...v3.1.0) (2025-07-30)


### Features

* Add support for GitHub App CodeConnection ([#64](https://github.com/cloudandthings/terraform-aws-github-runners/issues/64)) ([9772d72](https://github.com/cloudandthings/terraform-aws-github-runners/commit/9772d72961a8cda346cf253f50323245700b4a90))


### Bug Fixes

* Add condition to IAM assume role policy ([b8e2b3b](https://github.com/cloudandthings/terraform-aws-github-runners/commit/b8e2b3b9fb3ccd9ed52e14bdd4b359ab7f57fca7))

## [3.0.1](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v3.0.0...v3.0.1) (2025-01-06)


### Bug Fixes

* Minor update to examples ([f7c185a](https://github.com/cloudandthings/terraform-aws-github-runners/commit/f7c185a196055aacc2021ff8819a75555a005b89))

## [3.0.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v2.0.1...v3.0.0) (2024-12-11)


### ⚠ BREAKING CHANGES

* Allow custom ECR, rename var.use_ecr_image, and cleanup

### Features

* Allow custom ECR, rename var.use_ecr_image, and cleanup ([a6bb3f8](https://github.com/cloudandthings/terraform-aws-github-runners/commit/a6bb3f865299d6194f6ac5106c9a13f4b07224c2))


### Bug Fixes

* Fix README and provide more details on custom image ([#53](https://github.com/cloudandthings/terraform-aws-github-runners/issues/53)) ([1df2713](https://github.com/cloudandthings/terraform-aws-github-runners/commit/1df2713d71be2faa71167ba630842cdf7b38b2e1))

## [2.0.1](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v2.0.0...v2.0.1) (2024-12-05)


### Bug Fixes

* Update aws_iam_role_policy_attachment and make codebuild role output optional ([#49](https://github.com/cloudandthings/terraform-aws-github-runners/issues/49)) ([212957a](https://github.com/cloudandthings/terraform-aws-github-runners/commit/212957a6487733e222c286b89c2ea584a120c3b8))
* Update basic example ([#46](https://github.com/cloudandthings/terraform-aws-github-runners/issues/46)) ([3fb16d8](https://github.com/cloudandthings/terraform-aws-github-runners/commit/3fb16d894795e4769581a97927a4e73b68be765e))

## [2.0.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v1.2.0...v2.0.0) (2024-11-27)


### ⚠ BREAKING CHANGES

* Replace EC2+Autoscaling with AWS CodeBuild

### Features

* finalise and test codebuild runner ([52e65f3](https://github.com/cloudandthings/terraform-aws-github-runners/commit/52e65f36b2cb31389e2d875e4d4c47291e683cd5))
* Replace EC2+Autoscaling with AWS CodeBuild ([e1a7059](https://github.com/cloudandthings/terraform-aws-github-runners/commit/e1a70595e31cff5c62ab429ef20fa71e0d2754c0))

## [1.2.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v1.1.1...v1.2.0) (2023-02-10)


### Features

* Add `create_instance_profile` ([#38](https://github.com/cloudandthings/terraform-aws-github-runners/issues/38)) ([b3c278d](https://github.com/cloudandthings/terraform-aws-github-runners/commit/b3c278d568ec5ad575e7e1a5ce659067bcedf9b1))
* Add BASE_PACKAGES software pack ([6dbee94](https://github.com/cloudandthings/terraform-aws-github-runners/commit/6dbee94e533ec03517cf054b988bcbeed0a5b416))
* Add iam_policy_arns variable ([9037423](https://github.com/cloudandthings/terraform-aws-github-runners/commit/9037423ad4bdfc4cd402c15abc8a2b0162686f17))


### Bug Fixes

* Improved default concurrency ([bc3821d](https://github.com/cloudandthings/terraform-aws-github-runners/commit/bc3821d66df152a07d0c89811e6e4258d6e32892))

### [1.1.1](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v1.1.0...v1.1.1) (2022-12-14)


### Bug Fixes

* **python3:** Add python-dev-is-python3 package ([#34](https://github.com/cloudandthings/terraform-aws-github-runners/issues/34)) ([e74b64a](https://github.com/cloudandthings/terraform-aws-github-runners/commit/e74b64a983a0dca8455c2752fe0d7ffe949dbfcb))

## [1.1.0](https://github.com/cloudandthings/terraform-aws-github-runners/compare/v1.0.1...v1.1.0) (2022-12-08)


### Features

* **software:** Added tfsec ([#33](https://github.com/cloudandthings/terraform-aws-github-runners/issues/33)) ([1e73b96](https://github.com/cloudandthings/terraform-aws-github-runners/commit/1e73b964669e9ba41772e5e910811af6fb009958))

## 1.0.0 (2022-09-30)


### Features

* Initial commit ([4fb431b](https://github.com/cloudandthings/terraform-aws-github-runners/commit/4fb431bf4666acbbcb36ac4eceea0304b226e54f))
* Initial commit ([c7bdca2](https://github.com/cloudandthings/terraform-aws-github-runners/commit/c7bdca2a69e4c06ef3cee669a6523e8f0936fb93))


### Bug Fixes

* Auto release process ([#30](https://github.com/cloudandthings/terraform-aws-github-runners/issues/30)) ([c18832d](https://github.com/cloudandthings/terraform-aws-github-runners/commit/c18832d8601e41276027ba4f63482d078703cd99))

### Features

### Bug Fixes
