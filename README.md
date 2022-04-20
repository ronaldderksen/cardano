# cardano

Ronald Derksen's scripts to manage a cardano node. These scripts should not be installed on relay or block producing nodes because of cold, kes and vrf keys. I run these scripts on a system that does not run 24/7. My keys are also encrypted with GPG.

Please be patient. I am in early development.

### Enterprise Linux 8 RPM
I created an RPM, on Rocky linux 8, called cardano to simplify cardano-node and cardano-cli installation. The RPM can be installed with commands:

```
sudo dnf install https://repo.derksen-it.nl/repository/yum/el/8/derksen-it-release-1-1.x86_64.rpm
sudo dnf install cardano
. /etc/profile.d/cardano.sh # (or logout and login)
```

### Getting started
First install above RPM or make sure you have cardano-node and cardano-cli installed via own method. 
#### Clone repository
```
git clone https://github.com/ronaldderksen/cardano.git
cd cardano
```
#### Running first node
First 'create' the env file. This file is used by almost all scripts
```
cp env.example env
```
get config files needed for cardano-node
```
./node-management/get-config-files.sh
```
set environment variables used for below commands to succeed
```
# Example, adjust
REMOTE_IP=192.168.0.5 ; REMOTE_USER=cardano
```
Copy stuff to remote node
```
scp templates/run.sh ${REMOTE_USER}@${REMOTE_IP}:/opt/cardano
scp files-testnet/testnet-*json ${REMOTE_USER}@${REMOTE_IP}:/opt/cardano/config/
```

Run the node
```
# Login to the node where you want to run cardano-node on
nohup /opt/cardano/run.sh &
```

Check the log for errors
```
tail -f nohup.out
```

### Derksen IT Pool (DRKSN)
If you like these scripts, please stake some ADA in my pool.
https://cardanoscan.io/pool/ba05a5e3e734b6714081a6691376b32eecfea1f55fe73cce48cfa9c3

You can also send me some ADA to sponsor this project:
addr1qxgex7gshrk609ntptnhrq8rkdj6qxcjlrzg2h7zgnmtezwfqhca25pfqggq2prsn5nqh3gwmypavm6vwn9mkm34xg2qvpsnw6
