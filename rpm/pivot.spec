Name:           pivot
Version:        1.4.0
Release:        1%{?dist}
Summary:        Apache Pivot RIA framework for Java
Summary(it):    TODO SANDRO
Summary(cn):    TODO LEO

Group:          Development/Libraries
License:        ASL 2.0
URL:            http://pivot.apache.org/
Source0:        http://www.apache.org/dist/pivot/source/apache-pivot-%{cvs_version}-src.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

BuildRequires:  java-1.6.0-openjdk-devel
BuildRequires:  ant >= 0:1.7
BuildRequires:  junit4 >= 4.3

Requires:       java-1.6.0-openjdk-devel

%description
Apache Pivot is a platform for building rich internet applications in
Java. It combines the enhanced productivity and usability features of a
modern RIA toolkit with the robustness of the industry-standard Java
platform.

%description -l it
TODO SANDRO

%description -l cn
TODO LEO

%prep
%setup -q -n apache-pivot-%{cvs_version}


%build
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(0644,root,root,0755)
%doc KEYS LICENSE NOTICE README RELEASE-NOTES
%{_javadir}/%{name}-core.jar
%{_javadir}/%{name}-core-%{version}.jar
%{_javadir}/%{name}-wtk.jar
%{_javadir}/%{name}-wtk-%{version}.jar
%{_javadir}/%{name}-wtk-terra.jar
%{_javadir}/%{name}-wtk-terra-%{version}.jar
%{_javadir}/%{name}-web.jar
%{_javadir}/%{name}-web-%{version}.jar
%{_javadir}/%{name}-web-server.jar
%{_javadir}/%{name}-web-server-%{version}.jar
%{_javadir}/%{name}-charts.jar
%{_javadir}/%{name}-charts-%{version}.jar
%{_javadir}/%{name}-tools.jar
%{_javadir}/%{name}-tools-%{version}.jar



%changelog
