Name:           cardano
Version:        _VERSION_
Release:        _RELEASE_%{?dist}
Summary:        Cardano
License:        None

%description
Cardano node and cli

%prep
true

%build
true

%install
mkdir -p %{buildroot}/opt/cardano/bin %{buildroot}/opt/cardano/config %{buildroot}/opt/cardano/keys
mkdir -p %{buildroot}/opt/cardano/run %{buildroot}/opt/cardano/data
cp -a $HOME/.local/bin/cardano-cli %{buildroot}/opt/cardano/bin
cp -a $HOME/.local/bin/cardano-node %{buildroot}/opt/cardano/bin
cp -a /usr/local/lib %{buildroot}/opt/cardano/lib
mkdir -p %{buildroot}/etc/profile.d/ %{buildroot}/etc/ld.so.conf.d/
echo 'PATH=/opt/cardano/bin:$PATH' >%{buildroot}/etc/profile.d/cardano.sh
echo 'export CARDANO_NODE_SOCKET_PATH=/opt/cardano/run/cardano-node.socket' >>%{buildroot}/etc/profile.d/cardano.sh
echo '/opt/cardano/lib' >%{buildroot}/etc/ld.so.conf.d/cardano.conf

%clean
rm -rf $RPM_BUILD_ROOT

%pre
getent group cardano &>/dev/null || groupadd cardano
getent passwd cardano &>/dev/null || useradd -g cardano cardano

%post
/usr/sbin/ldconfig

%files
%defattr(-,cardano,cardano,-)
/opt/cardano
/etc/profile.d/cardano.sh
/etc/ld.so.conf.d/cardano.conf
