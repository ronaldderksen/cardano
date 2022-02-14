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
mkdir -p %{buildroot}/opt/cardano/bin
cp -a $HOME/.local/bin/cardano-cli %{buildroot}/opt/cardano/bin
cp -a $HOME/.local/bin/cardano-node %{buildroot}/opt/cardano/bin
cp -a /usr/local/lib %{buildroot}/opt/cardano/lib

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/opt/cardano
