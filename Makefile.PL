# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'TM-IP-Documents';
all_from 'lib/TM/IP/Documents.pm';

requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Catalyst::Action::REST' => '0.71';
requires 'Catalyst::View::Mason';
requires 'HTTP::Status';
requires 'JSON';
requires 'Test::More';
requires 'HTTP::Request::Common';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
