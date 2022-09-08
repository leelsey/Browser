pjRoot=$PWD
pjSrc=$pjRoot/chromium/src
pjBuild=$pjSrc/out

echo '\n • Install deopt_tools'
# Get depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$PWD/depot_tools"
# Direnv: auto run set env
echo "export PATH=\"\$PATH:\$PWD/depot_tools\"\n" > .envrc
direnv allow

echo '\n • Get the code'
# Get Chromium code
mkdir chromium
cd chromium && caffeinate fetch chromium

echo '\n • Setting up the build'
# Build gn
gn gen pjBuild=$pjSrc/out/Default
echo "is_component_build = true\nis_debug = false\nsymbol_level = 0\n" >> out/Default/args.gn
gn gen pjBuild=$pjSrc/out/ReleaseMacArm
echo "is_official_build = true\nis_debug = true\nsymbol_level = 1\n#blink_symbol_level = 0\n#v8_symbol_level = 0\n" >> out/ReleaseMacArm/args.gn
gn gen pjBuild=$pjSrc/out/ReleaseMacIntel
echo "is_official_build = true\nis_debug = true\nsymbol_level = 1\n#blink_symbol_level = 0\n#v8_symbol_level = 0\n" >> out/ReleaseMacIntel/args.gn
mkdir pjBuild=$pjSrc/out/ReleaseMacUniversal

# Release build for macOS
mv $pjRoot/chromium/.gclient ../.gclient.default
echo "solutions = [
  {
    "name": "src",
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "managed": False,
    "custom_deps": {},
    "custom_vars": {
      "checkout_pgo_profiles": True
    },
  },
]\n" > $pjRoot/chromium/.gclient
cd $pjBuild && gclient runhooks

echo '\n • Update code'
cd $pjSrc && gclient sync --with_branch_heads --with_tags
cd $pjSrc && git fetch && git fetch --tags && git checkout -f -b tags/$1
cd $pjSrc && gclient sync --with_branch_heads --with_tags
