search for TODO

Documetn default software

Docker runner

Test that default software was actually installed and working

Advanced example

[18:11, 20/08/2022] Bjorn: GitHub runners customisation:

[18:13, 20/08/2022] Bjorn: Ci Features:
Cloud init validation
Deploy one instance and verify cloud init log and conn to GitHub

[18:16, 20/08/2022] Bjorn: Public IP or not
[18:16, 20/08/2022] Bjorn: Ci can connect to instance and wait for cloud init to be done
[18:54, 20/08/2022] Bjorn: Zip of cloud init file

[06:25, 24/08/2022] Bjorn: Documentation

Use ubuntu-latest for public repos

Separate test and dev requirements

Separate integration tests and unit tests

[21:34, 26/08/2022] Bjorn: Get latest runner zip file
[21:34, 26/08/2022] Bjorn: Parallel ephemeral runners
[21:34, 26/08/2022] Bjorn: Cloud watch logs for cloud init and for runner scripts
[21:36, 26/08/2022] Bjorn: Parallel of 1 would be fine for example.
[21:36, 26/08/2022] Bjorn: Auto clean up home dir after itself


[10:51, 27/08/2022] Bjorn: Change default to all
[10:52, 27/08/2022] Bjorn: Add cloud init users and write files
[10:52, 27/08/2022] Bjorn: Add no EC2 options
[10:52, 27/08/2022] Bjorn: Document recommendations Iam user
[11:01, 27/08/2022] Bjorn: Output clou yaml file
[11:05, 27/08/2022] Bjorn: A none software option
[11:05, 27/08/2022] Bjorn: Strip comments from init file
[19:55, 27/08/2022] Bjorn: Pass in security group
