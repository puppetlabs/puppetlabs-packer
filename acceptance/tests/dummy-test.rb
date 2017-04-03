test_name 'Beaker hello world test' do
  step 'Trivial hello world test' do
    hosts.each do |host|
      on(host, "echo hello") { assert_equal(0, exit_code) }
    end
  end
end
