name "distro"
default_version "1.3.0"

dependency "python"
dependency "pip"

build do
  ship_license "https://raw.githubusercontent.com/nir0s/distro/master/LICENSE"
  pip "install --install-option=\"--install-scripts="\
      "#{windows_safe_path(install_dir)}/bin\" "\
      "#{name}==#{version}"
end
