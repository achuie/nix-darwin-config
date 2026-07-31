let
  achuie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvUlNGPPvmAJ7eTnbAvcxESUl7gb5Uy4t+5Y63t2UY2 achuie@ach-tx-mba.local";
  achuie-florisuga = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKlscoxjg8I872jRjmH4QtkNfLf3hboUIp411kJqJcfE achuie@florisuga";

  ach-tx-mba = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJ/bqL6wl3wmC5bre5wxueLjpPDFJMBElVkQpNCKms4 root@ach-tx-mba.local";
  florisuga = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxRILEjkJjYq1wxnpmOW1NeXzdcsw+CFP4UCcEOkIkO root@florisuga";
in
{
  "anthropic-key.age".publicKeys = [ achuie ach-tx-mba achuie-florisuga florisuga ];
}
