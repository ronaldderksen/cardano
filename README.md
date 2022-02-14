# cardano

Ronald Derksen's scripts to manage a cardano node. These scripts should not be installed on relay or block producing nodes because of cold and KEY keys. I run these scripts from an USB drive on a node, not directly connected to the internet when I need my cold key.

Please be patient. I am in early development.

### Enterprise Linux 8 RPM
I created an RPM, on Rocky linux 8, called cardano to simplify cardano-node and cardano-cli installation. The RPM can be installed with commands:

```
dnf install https://repo.derksen-it.nl/repository/yum/el/8/derksen-it-release-1-1.x86_64.rpm
dnf install cardano
```

### Derksen IT Pool (DRKSN)
If you like these scripts, please stake some ADA in my pool.
https://cardanoscan.io/pool/ba05a5e3e734b6714081a6691376b32eecfea1f55fe73cce48cfa9c3

You can also send me some ADA to sponsor this project:
addr1qxgex7gshrk609ntptnhrq8rkdj6qxcjlrzg2h7zgnmtezwfqhca25pfqggq2prsn5nqh3gwmypavm6vwn9mkm34xg2qvpsnw6
