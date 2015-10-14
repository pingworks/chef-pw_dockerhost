require_relative '../spec_helper'

describe file('/usr/local/bin/docker-enter') do
  it { should be_executable }
end

describe file('/usr/local/bin/nsenter') do
  it { should be_executable }
end

describe file('/usr/local/bin/docker-mount.sh') do
  it { should be_executable }
end
