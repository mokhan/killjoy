execute "yum update -y"
execute "yum upgrade -y"
execute "yum groupinstall -y 'Development Tools'"

file "/etc/yum.repos.d/datastax.repo" do
  content <<-CONTENT
[datastax]
name=DataStax Repo for Apache Cassandra
baseurl=http://rpm.datastax.com/community
enabled=1
gpgcheck=0
CONTENT
end

execute "rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc"

remote_file "/tmp/erlang-17.4-1.el6.x86_64.rpm" do
  source "https://www.rabbitmq.com/releases/erlang/erlang-17.4-1.el6.x86_64.rpm"
end
execute "yum install -y /tmp/erlang-17.4-1.el6.x86_64.rpm"

remote_file "/tmp/rabbitmq-server-3.5.6-1.noarch.rpm" do
  source "https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_5_6/rabbitmq-server-3.5.6-1.noarch.rpm"
end
execute "yum install -y /tmp/rabbitmq-server-3.5.6-1.noarch.rpm"

package "epel-release"
execute "yum clean all"

package %w{
  autoconf
  automake
  bison
  bzip2
  ca-certificates
  dsc21
  gcc-c++
  git
  java-1.8.0-openjdk
  libffi-devel
  libtool
  libxml2
  libxml2-devel
  libxslt
  libxslt-devel
  make
  openssl-devel
  opscenter
  patch
  pygpgme
  rabbitmq-server
  readline
  readline-devel
  statsd
  yum-utils
  zlib
  zlib-devel
}.to_a

[
  "rabbitmq_sharding-3.5.x-fe42a9b6.ez",
].each do |plugin|
  remote_file "/usr/lib/rabbitmq/lib/rabbitmq_server-3.5.6/plugins/#{plugin}" do
    source "https://www.rabbitmq.com/community-plugins/v3.5.x/#{plugin}"
  end
end

[
  "rabbitmq_consistent_hash_exchange",
  "rabbitmq_management",
  "rabbitmq_sharding",
].each do |plugin|
  execute "rabbitmq-plugins enable #{plugin}" do
    not_if "rabbitmq-plugins list -E | grep #{plugin}"
  end
end

[
  "cassandra",
  "rabbitmq-server",
].each do |service_name|
  service service_name do
    action [:start, :enable]
  end
end

git "/usr/local/rbenv" do
  repository "https://github.com/sstephenson/rbenv.git"
  action :sync
end

file "/etc/profile.d/rbenv.sh" do
  content <<-CONTENT
export RBENV_ROOT="/usr/local/rbenv"
export PATH="/usr/local/rbenv/bin:$PATH"
eval "$(rbenv init -)"
CONTENT
end

directory "/usr/local/rbenv/plugins"
git "/usr/local/rbenv/plugins/ruby-build" do
  repository "https://github.com/sstephenson/ruby-build.git"
  action :sync
end

ruby_version = "2.2.3"
bash "install_ruby" do
  user "root"
  code <<-EOH
source /etc/profile.d/rbenv.sh
rbenv install #{ruby_version}
rbenv global #{ruby_version}
EOH
end

bash "install_bundler" do
  code <<-EOH
    source /etc/profile.d/rbenv.sh
    gem install bundler --no-ri --no-rdoc
  EOH
end
