require_relative '../spec_helper'

describe command('su -c "docker version" ubuntu') do
  its(:stdout) { should match /Version:.*1/ }
  its(:exit_status) { should eq 0 }
end
