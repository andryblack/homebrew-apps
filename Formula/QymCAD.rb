class Qymcad < Formula
  desc "Parametric 3D CAD with a real B-rep kernel (OpenCASCADE)"
  homepage "https://github.com/QymIs-Tech/QymCAD"
  url "https://github.com/QymIs-Tech/QymCAD.git", branch: "main", revision: "d2949f0a7283d96212326c67452cd8759b80c03b"
  version "0.1.0-dev.20261001"
  license "AGPL-3.0"

  # The kernel is a C++ FFI bridge compiled by `cc` against OCCT headers, and the
  # resulting binary links the OCCT dylibs at runtime - so opencascade is needed
  # both at build time and when the program runs.
  depends_on "rust" => :build
  depends_on "opencascade"

  def install
    # The build script (crates/qymcad-kernel/build.rs) locates OCCT through these
    # variables, defaulting to Linux paths (/usr/include/opencascade, /usr/lib).
    occt = formula_opt_prefix("opencascade")
    ENV["OCCT_INCLUDE_DIR"] = occt/"include/opencascade"
    ENV["OCCT_LIB_DIR"] = occt/"lib"

    system "cargo", "build", "--release", "--bin", "qymcad"
    bin.install "target/release/qymcad"
  end

  test do
    assert_path_exists bin/"qymcad"
    assert_predicate bin/"qymcad", :executable?
    # The binary must carry the B-rep kernel with it: without the OCCT link the
    # program cannot start, so check the dylibs it was built against.
    assert_match(/TKernel/, shell_output("otool -L #{bin/"qymcad"}"))
  end
end
