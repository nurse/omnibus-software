name "datadog-gohai"
default_version "last-stable"

always_build true

dependency "go"

env = {
  "GOPATH" => "#{Omnibus::Config.cache_dir}/src/#{name}",
}

if ohai["platform_family"] == "mac_os_x"
  gobin = "/usr/local/bin/go"
elsif ohai["platform"] == "windows"
  gobin = "C:/Go/bin/go"
else
  env["GOROOT"] = "/usr/local/go"
  gobin = "/usr/local/go/bin/go"
end

build do
  ship_license "https://raw.githubusercontent.com/DataDog/gohai/#{version}/LICENSE"
  ship_license "https://raw.githubusercontent.com/DataDog/gohai/#{version}/THIRD_PARTY_LICENSES.md"
  # Checkout gohai's deps
  command "#{gobin} get github.com/shirou/gopsutil", :env => env
  command "git checkout v2.0.0", :env => env, :cwd => "#{Omnibus::Config.cache_dir}/src/datadog-gohai/src/github.com/shirou/gopsutil"
  command "#{gobin} get github.com/cihub/seelog", :env => env
  command "git checkout v2.6", :env => env, :cwd => "#{Omnibus::Config.cache_dir}/src/datadog-gohai/src/github.com/cihub/seelog"
  # Windows depends on the registry, go get that.
  if ohai["platform"] == "windows"
    command "#{gobin} get -d golang.org/x/sys/windows/registry", :env => env
    command "git checkout 5f54ce54270977bfbd7353a37e64c13d6bd6c9c9", :env => env, :cwd => "#{Omnibus::Config.cache_dir}/src/datadog-gohai/src/golang.org/x/sys/windows/registry"
  end
  # Checkout and build gohai
  command "#{gobin} get -d github.com/DataDog/gohai", :env => env # No need to pull latest from remote with `-u` here since the next command checks out and pulls latest
  command "git checkout #{version} && git pull", :env => env, :cwd => "#{Omnibus::Config.cache_dir}/src/datadog-gohai/src/github.com/DataDog/gohai"
  command "#{gobin} run make.go #{gobin}", :env => env, :cwd => "#{env['GOPATH']}/src/github.com/DataDog/gohai"
  move "#{env['GOPATH']}/src/github.com/DataDog/gohai/gohai", "#{install_dir}/bin/gohai"
end
