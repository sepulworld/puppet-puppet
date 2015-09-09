require 'spec_helper'

describe 'puppet::server::passenger' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts.merge({
        :concat_basedir => '/foo/bar',
        :puppetversion  => Puppet.version,
      })
    end
    let(:default_params) do {
      :app_root => '/etc/puppet/rack'
    } end

    describe 'without parameters' do
      let(:params) { default_params }
      it 'should include the puppet vhost' do
        should contain_apache__vhost('puppet').with({
          :ssl_proxyengine => false,
          :ssl_crl_check => nil,
        })
      end
    end

    describe 'with puppet ca proxy' do
      let :params do
        default_params.merge({
          :puppet_ca_proxy => 'https://ca.example.org:8140',
        })
      end

      it 'should include the puppet vhost' do
        should contain_apache__vhost('puppet').with({
          :ssl_proxyengine => true,
          :custom_fragment => "ProxyPassMatch ^/([^/]+/certificate.*)$ https://ca.example.org:8140/$1",
        })
      end
    end

    describe 'with passenger settings' do
      let :params do
        default_params.merge({
          :server_passenger_max_pool         => 12,
          :server_passenger_max_requests     => 100,
          :server_passenger_high_performance => 'Off',
          :server_passenger_pool_idle_time   => 500,
        })
      end

      it 'should include the mod passenger' do
        should_contain_apache__mod__passenger.with({
          :passenger_max_pool         => 12,
          :passenger_max_requests     => 100,
          :passenger_high_performance => 'Off',
          :passenger_pool_idle_time   => 500,
        })
      end
    end 
          

    describe 'with SSL CRL' do
      let :params do
        default_params.merge({
          :ssl_ca_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
        })
      end

      it 'should include the puppet vhost' do
        should contain_apache__vhost('puppet').with({
          :ssl_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
          :ssl_crl_check => 'chain',
        })
      end
    end
  end
end
